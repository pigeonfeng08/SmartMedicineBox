/*
 * Copyright (c) 2024 iSoftStone Education Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdio.h>
#include <stdbool.h>

#include "los_task.h"
#include "ohos_init.h"
#include "cmsis_os.h"
#include "config_network.h"
#include "smart_home.h"
#include "smart_home_event.h"
#include "su_03t.h"
#include "iot.h"
#include "lcd.h"
#include "picture.h"
#include "adc_key.h"

// 添加MQ2气体传感器和蜂鸣器相关头文件
#include "iot_errno.h"
#include "iot_pwm.h"
#include "iot_adc.h"
#include <math.h>
#include <unistd.h>

#define ROUTE_SSID      "P1ge0n_"          // WiFi账号
#define ROUTE_PASSWORD "10086123456789"       // WiFi密码

#define MSG_QUEUE_LENGTH                                16
#define BUFFER_LEN                                      50

// MQ2气体传感器相关定义
#define CAL_PPM 20 // 校准环境中PPM值
#define RL 1       // RL阻值
#define MQ2_ADC_CHANNEL 4

// 蜂鸣器相关定义
#define BEEP_PORT EPWMDEV_PWM5_M0

// 气体传感器全局变量
static float m_r0; // 元件在干净空气中的阻值
static bool gas_alarm_active = false; // 气体报警状态

// 蜂鸣器音乐相关数据
static const uint16_t g_tuneFreqs[] = {
    0, // 160M Hz 对应的分频系数：
    4186,// 1046.5
    4700, // 1174.7
    5276, // 1318.5
    5588,// 1396.9
    6272,// 1568
    7040,// 1760
    7902,// 1975.5
    3136// 5_ 783.99 // 第一个八度的 5
};
// 曲谱音符
static const uint8_t g_scoreNotes[] = {
    1, 1, 1, 1, 1, 1,  6, 6, 6, 6, 6, 6,  1, 1, 1, 1, 1, 1,   
    6, 6, 6, 6, 6, 6,  1, 1, 1, 1, 1, 1,  6, 6, 6, 6, 6, 6, 
};
// 曲谱时值
static const uint8_t g_scoreDurations[] = {
    4, 4, 4, 4, 4, 4,  4, 4, 4, 4, 4, 4,  4, 4, 4, 4, 4, 4,
    4, 4, 4, 4, 4, 4,  4, 4, 4, 4, 4, 4,  4, 4, 4, 4, 4, 4,
};

/***************************************************************
* 函数名称: mq2_dev_init
* 说    明: 初始化ADC
* 参    数: 无
* 返 回 值: 0为成功，反之为失败
***************************************************************/
unsigned int mq2_dev_init(void)
{
    unsigned int ret = 0;

    ret = IoTAdcInit(MQ2_ADC_CHANNEL);

    if(ret != IOT_SUCCESS)
    {
        printf("%s, %s, %d: ADC Init fail\n", __FILE__, __func__, __LINE__);
    }

    return 0;
}

/***************************************************************
* 函数名称: adc_get_voltage
* 说    明: 获取ADC电压值
* 参    数: 无
* 返 回 值: 电压值
***************************************************************/
static float adc_get_voltage(void)
{
    unsigned int ret = IOT_SUCCESS;
    unsigned int data = 0;

    ret = IoTAdcGetVal(MQ2_ADC_CHANNEL, &data);

    if (ret != IOT_SUCCESS)
    {
        printf("%s, %s, %d: ADC Read Fail\n", __FILE__, __func__, __LINE__);
        return 0.0;
    }

    return (float)(data * 3.3 / 1024.0);
}

/***************************************************************
 * 函数名称: mq2_ppm_calibration
 * 说    明: 传感器校准函数
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
void mq2_ppm_calibration(void) 
{
  float voltage = adc_get_voltage();
  float rs = (5 - voltage) / voltage * RL;

  m_r0 = rs / powf(CAL_PPM / 613.9f, 1 / -2.074f);
}

/***************************************************************
 * 函数名称: get_mq2_ppm
 * 说    明: 获取PPM函数
 * 参    数: 无
 * 返 回 值: ppm
 ***************************************************************/
float get_mq2_ppm(void) 
{
  float voltage, rs, ppm;

  voltage = adc_get_voltage();
  rs = (5 - voltage) / voltage * RL;      // 计算rs
  ppm = 613.9f * powf(rs / m_r0, -2.074f); // 计算ppm
  return ppm;
}

/***************************************************************
* 函数名称: beep_play_music
* 说    明: 播放两只老虎音乐
* 参    数: 无
* 返 回 值: 无
***************************************************************/
void beep_play_music()
{
    printf("Gas alarm! Playing music...\r\n");
    int count = sizeof(g_scoreNotes)/sizeof(g_scoreNotes[0]);
    for (size_t i = 0; i < count; i++) {
        // 音符
        uint32_t tune = g_scoreNotes[i]; 
        uint16_t freqDivisor = g_tuneFreqs[tune];
        // 音符时间
        uint32_t tuneInterval = g_scoreDurations[i] * (125*1000); 
        
        IoTPwmStart(BEEP_PORT, 50, freqDivisor);
        usleep(tuneInterval);
        IoTPwmStop(BEEP_PORT);
        usleep(50000); // 音符间隔
    }
}

/***************************************************************
 * 函数名称: iot_thread
 * 说    明: iot线程
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
void iot_thread(void *args) {
  uint8_t mac_address[12] = {0x00, 0xdc, 0xb6, 0x90, 0x01, 0x00,0};

  char ssid[32]=ROUTE_SSID;
  char password[32]=ROUTE_PASSWORD;
  char mac_addr[32]={0};

  FlashDeinit();
  FlashInit();

  VendorSet(VENDOR_ID_WIFI_MODE, "STA", 3); // 配置为Wifi STA模式
  VendorSet(VENDOR_ID_MAC, mac_address, 6); // 多人同时做该实验，请修改各自不同的WiFi MAC地址
  VendorSet(VENDOR_ID_WIFI_ROUTE_SSID, ssid, sizeof(ssid));
  VendorSet(VENDOR_ID_WIFI_ROUTE_PASSWD, password,sizeof(password));

reconnect:
  SetWifiModeOff();
  int ret = SetWifiModeOn();
  if(ret != 0){
    printf("wifi connect failed,please check wifi config and the AP!\n");
    return;
  }
  mqtt_init();

  while (1) {
    if (!wait_message()) {
      goto reconnect;
    }
    LOS_Msleep(1);
  }
}


/***************************************************************
 * 函数名称: smart_home_thread
 * 说    明: 智慧家居主线程
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
void smart_home_thread(void *arg)
{
    double *data_ptr = NULL;

    double illumination_range = 50.0;
    double temperature_range = 35.0;
    double humidity_range = 80.0;

    e_iot_data iot_data = {0};

    i2c_dev_init();
    lcd_dev_init();
    motor_dev_init();
    light_dev_init();
    su03t_init();
    
    // 初始化MQ2气体传感器和蜂鸣器
    mq2_dev_init();
    IoTPwmInit(BEEP_PORT);
    
    LOS_Msleep(1000);
    
    // 传感器校准
    mq2_ppm_calibration();
    printf("MQ2 sensor calibrated\r\n");

    // lcd_load_ui();
    lcd_show_ui();

    while(1)
    {
        event_info_t event_info = {0};
        //等待事件触发,如有触发,则立即处理对应事件,如未等到,则执行默认的代码逻辑,更新屏幕
        int ret = smart_home_event_wait(&event_info,3000);
        if(ret == LOS_OK){
            //收到指令
            printf("event recv %d ,%d\n",event_info.event,event_info.data.iot_data);
            switch (event_info.event)
            {
                case event_key_press:
                    smart_home_key_process(event_info.data.key_no);
                    
                    break;
                case event_iot_cmd:
                    smart_home_iot_cmd_process(event_info.data.iot_data);
                    break;
                case event_su03t:
                    smart_home_su03t_cmd_process(event_info.data.su03t_data);
                    break;
               default:break;
            }

        }

        double temp,humi,lum;
        float gas_ppm;

        sht30_read_data(&temp,&humi);
        bh1750_read_data(&lum);
        
        // 读取气体传感器数据
        gas_ppm = get_mq2_ppm();
        // printf("Gas PPM: %.3f\r\n", gas_ppm);
        
        // 检查气体浓度是否超过阈值 - 修改阈值从1500.0改为100.0
        if (gas_ppm > 100.0) {
            if (!gas_alarm_active) {
                gas_alarm_active = true;
                printf("Gas concentration exceeded threshold! PPM: %.3f\r\n", gas_ppm);
                beep_play_music();
            }
        } else {
            gas_alarm_active = false;
        }

        lcd_set_illumination(lum);
        lcd_set_temperature(temp);
        lcd_set_humidity(humi);
        if (mqtt_is_connected()) 
        {
            // 发送iot数据
            iot_data.illumination = lum;
            iot_data.temperature = temp;
            iot_data.humidity = humi;
            iot_data.gas_ppm = gas_ppm;           // 添加气体浓度数据
            iot_data.light_state = get_light_state();
            iot_data.motor_state = get_motor_state();
            // iot_data.auto_state = auto_state;
            send_msg_to_mqtt(&iot_data);

            lcd_set_network_state(true);
        }else{  
            lcd_set_network_state(false);
        }

        lcd_show_ui();
    }
}

/***************************************************************
 * 函数名称: device_read_thraed
 * 说    明: 设备读取线程
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
// void device_read_thraed(void *arg)
// {
//     double read_data[3] = {0};

//     i2c_dev_init();

//     while(1)
//     {
//         bh1750_read_data(&read_data[0]);
//         sht30_read_data(&read_data[1]);
//         LOS_QueueWrite(m_msg_queue, (void *)&read_data, sizeof(read_data), LOS_WAIT_FOREVER);
//         LOS_QueueWrite(m_su03_msg_queue, (void *)&read_data, sizeof(read_data), LOS_WAIT_FOREVER);
//         LOS_Msleep(500);
//     }
// }

/***************************************************************
 * 函数名称: iot_smart_hone_example
 * 说    明: 开机自启动调用函数
 * 参    数: 无
 * 返 回 值: 无
 ***************************************************************/
void iot_smart_home_example()
{
    unsigned int thread_id_1;
    unsigned int thread_id_2;
    unsigned int thread_id_3;
    TSK_INIT_PARAM_S task_1 = {0};
    TSK_INIT_PARAM_S task_2 = {0};
    TSK_INIT_PARAM_S task_3 = {0};
    unsigned int ret = LOS_OK;
    
    smart_home_event_init();
    
    // ret = LOS_QueueCreate("su03_queue", MSG_QUEUE_LENGTH, &m_su03_msg_queue, 0, BUFFER_LEN);
    // if (ret != LOS_OK)
    // {
    //     printf("Falied to create Message Queue ret:0x%x\n", ret);
    //     return;
    // }

    task_1.pfnTaskEntry = (TSK_ENTRY_FUNC)smart_home_thread;
    task_1.uwStackSize = 2048;
    task_1.pcName = "smart hone thread";
    task_1.usTaskPrio = 24;
    
    ret = LOS_TaskCreate(&thread_id_1, &task_1);
    if (ret != LOS_OK)
    {
        printf("Falied to create task ret:0x%x\n", ret);
        return;
    }

    task_2.pfnTaskEntry = (TSK_ENTRY_FUNC)adc_key_thread;
    task_2.uwStackSize = 2048;
    task_2.pcName = "key thread";
    task_2.usTaskPrio = 24;
    ret = LOS_TaskCreate(&thread_id_2, &task_2);
    if (ret != LOS_OK)
    {
        printf("Falied to create task ret:0x%x\n", ret);
        return;
    }

    task_3.pfnTaskEntry = (TSK_ENTRY_FUNC)iot_thread;
    task_3.uwStackSize = 20480*5;
    task_3.pcName = "iot thread";
    task_3.usTaskPrio = 24;
    ret = LOS_TaskCreate(&thread_id_3, &task_3);
    if (ret != LOS_OK)
    {
        printf("Falied to create task ret:0x%x\n", ret);
        return;
    }
}

APP_FEATURE_INIT(iot_smart_home_example);
