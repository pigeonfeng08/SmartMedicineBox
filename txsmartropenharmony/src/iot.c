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
#include <stdlib.h>

#include "MQTTClient.h"
#include "cJSON.h"
#include "cmsis_os2.h"
#include "config_network.h"
#include "iot.h"
#include "los_task.h"
#include "ohos_init.h"
#include "smart_home_event.h"

#define MQTT_DEVICES_PWD "f7970363b1119b6a02f7cca20fce14a7b75e9d3f05c770629035442b0c7fb957"

#define HOST_ADDR "61357a1900.st1.iotda-device.cn-north-4.myhuaweicloud.com"
#define USERNAME "685f8b5ed582f2001835e760_Smart_Medicien_Box"
#define DEVICE_ID "685f8b5ed582f2001835e760_Smart_Medicien_Box_0_0_2025062915"

#define PUBLISH_TOPIC "$oc/devices/" USERNAME "/sys/properties/report"
#define SUBCRIB_TOPIC                                                          \
  "$oc/devices/" USERNAME "/sys/commands/#" /// request_id={request_id}"
#define RESPONSE_TOPIC                                                         \
  "$oc/devices/" USERNAME "/sys/commands/response" /// request_id={request_id}"

#define MAX_BUFFER_LENGTH 512
#define MAX_STRING_LENGTH 64

static unsigned char sendBuf[MAX_BUFFER_LENGTH];
static unsigned char readBuf[MAX_BUFFER_LENGTH];

Network network;
MQTTClient client;

static char mqtt_devid[64]=DEVICE_ID;
static char mqtt_pwd[72]=MQTT_DEVICES_PWD;
static char mqtt_username[64]=USERNAME;
static char mqtt_hostaddr[64]=HOST_ADDR;

static char publish_topic[128] = PUBLISH_TOPIC;
static char subcribe_topic[128] = SUBCRIB_TOPIC;
static char response_topic[128] = RESPONSE_TOPIC;

static unsigned int mqttConnectFlag = 0;

// 添加MqttTest变量
static char MqttTest[64] = {0};

extern bool motor_state;
extern bool light_state;
extern bool auto_state;


extern void beep_play_music(void);

/***************************************************************
* 函数名称: send_msg_to_mqtt
* 说    明: 发送信息到iot
* 参    数: e_iot_data *iot_data：数据
* 返 回 值: 无
***************************************************************/
void send_msg_to_mqtt(e_iot_data *iot_data) {
  int rc;
  MQTTMessage message;
  char payload[MAX_BUFFER_LENGTH] = {0};
  char str[MAX_STRING_LENGTH] = {0};

  if (mqttConnectFlag == 0) {
    printf("mqtt not connect\n");
    return;
  }
  
  cJSON *root = cJSON_CreateObject();
  if (root != NULL) {
    cJSON *serv_arr = cJSON_AddArrayToObject(root, "services");
    cJSON *arr_item = cJSON_CreateObject();
    cJSON_AddStringToObject(arr_item, "service_id", "IntelligentCookpit");
    cJSON *pro_obj = cJSON_CreateObject();
    cJSON_AddItemToObject(arr_item, "properties", pro_obj);

    memset(str, 0, MAX_BUFFER_LENGTH);
    // 光照强度
    sprintf(str, "%5.2f", iot_data->illumination);
    cJSON_AddStringToObject(pro_obj, "illumination", str);
    
    // 温度
    sprintf(str, "%5.2f", iot_data->temperature);
    cJSON_AddStringToObject(pro_obj, "temperature", str);
    
    // 湿度
    sprintf(str, "%5.2f%", iot_data->humidity);
    cJSON_AddStringToObject(pro_obj, "humidity", str);
    
    // 气体浓度 - 新添加
    sprintf(str, "%.3f", iot_data->gas_ppm);
    cJSON_AddStringToObject(pro_obj, "gas", str);
    // 电机状态
    if (iot_data->motor_state == true) {
      cJSON_AddStringToObject(pro_obj, "motorStatus", "ON");
    } else {
      cJSON_AddStringToObject(pro_obj, "motorStatus", "OFF");
    }
    // 灯光状态
    if (iot_data->light_state == true) {
      cJSON_AddStringToObject(pro_obj, "lightStatus", "ON");
    } else {
      cJSON_AddStringToObject(pro_obj, "lightStatus", "OFF");
    }
    // 自动状态模式
    if (iot_data->auto_state == true) {
      cJSON_AddStringToObject(pro_obj, "autoStatus", "ON");
    } else {
      cJSON_AddStringToObject(pro_obj, "autoStatus", "OFF");
    }
    
    // 添加MqttTest数据上传
    if (strlen(MqttTest) > 0) {
      printf("准备上传MqttTest数据: %s\n", MqttTest);
      cJSON_AddStringToObject(pro_obj, "MqttTest", MqttTest);
    } else {
      printf("MqttTest为空，不上传\n");
    }

    cJSON_AddItemToArray(serv_arr, arr_item);

    char *palyload_str = cJSON_PrintUnformatted(root);
    strcpy(payload, palyload_str);

    cJSON_free(palyload_str);
    cJSON_Delete(root);
  }

  message.qos = 0;
  message.retained = 0;
  message.payload = payload;
  message.payloadlen = strlen(payload);

  sprintf(publish_topic,"$oc/devices/%s/sys/properties/report",mqtt_devid);
  if ((rc = MQTTPublish(&client, publish_topic, &message)) != 0) {
    // printf("Return code from MQTT publish is %d\n", rc);
    mqttConnectFlag = 0;
  } else {
    // printf("mqtt publish success:%s\n", payload);
  }
}

/***************************************************************
* 函数名称: set_light_state
* 说    明: 设置灯状态
* 参    数: cJSON *root
* 返 回 值: 无
***************************************************************/
void set_light_state(cJSON *root) {
  cJSON *para_obj = NULL;
  cJSON *status_obj = NULL;
  char *value = NULL;

  event_info_t event={0};
  event.event=event_iot_cmd;

  para_obj = cJSON_GetObjectItem(root, "paras");
  status_obj = cJSON_GetObjectItem(para_obj, "onoff");
  if (status_obj != NULL) {
    value = cJSON_GetStringValue(status_obj);
    if (!strcmp(value, "ON")) {
      event.data.iot_data = IOT_CMD_LIGHT_ON;
      // light_state = true;
    } else if (!strcmp(value, "OFF")) {
      event.data.iot_data = IOT_CMD_LIGHT_OFF;
      // light_state = false;
    }
    smart_home_event_send(&event);
  }
}

/***************************************************************
* 函数名称: set_motor_state
* 说    明: 设置电机状态
* 参    数: cJSON *root
* 返 回 值: 无
***************************************************************/
void set_motor_state(cJSON *root) {
  cJSON *para_obj = NULL;
  cJSON *status_obj = NULL;
  char *value = NULL;

  event_info_t event={0};
  event.event=event_iot_cmd;

  para_obj = cJSON_GetObjectItem(root, "paras");
  status_obj = cJSON_GetObjectItem(para_obj, "onoff");
  if (status_obj != NULL) {
    value = cJSON_GetStringValue(status_obj);
    if (!strcmp(value, "ON")) {
      // motor_state = true;
      event.data.iot_data = IOT_CMD_MOTOR_ON;
    } else if (!strcmp(value, "OFF")) {
      // motor_state = false;
      event.data.iot_data = IOT_CMD_MOTOR_OFF;
    }
    smart_home_event_send(&event);
  }
}

/***************************************************************
* 函数名称: set_light_state
* 说    明: 设置自动模式状态
* 参    数: cJSON *root
* 返 回 值: 无
***************************************************************/
void set_auto_state(cJSON *root) {
  cJSON *para_obj = NULL;
  cJSON *status_obj = NULL;
  char *value = NULL;

  para_obj = cJSON_GetObjectItem(root, "paras");
  status_obj = cJSON_GetObjectItem(para_obj, "onoff");
  if (status_obj != NULL) {
    value = cJSON_GetStringValue(status_obj);
    if (!strcmp(value, "ON")) {
      // auto_state = true;
    } else if (!strcmp(value, "OFF")) {
      // auto_state = false;
    }
  }
}

/***************************************************************
* 函数名称: set_light_state_new
* 说    明: 设置灯状态（新格式）
* 参    数: char *value - 灯光状态值
* 返 回 值: 无
***************************************************************/
void set_light_state_new(char *value) {
  event_info_t event={0};
  event.event=event_iot_cmd;

  if (value != NULL) {
    if (!strcmp(value, "ON")) {
      event.data.iot_data = IOT_CMD_LIGHT_ON;
    } else if (!strcmp(value, "OFF")) {
      event.data.iot_data = IOT_CMD_LIGHT_OFF;
    }
    smart_home_event_send(&event);
  }
}

/***************************************************************
* 函数名称: handle_mqtt_control
* 说    明: 处理mqtt_control命令
* 参    数: char *value - 控制参数值
* 返 回 值: 无
***************************************************************/
void handle_mqtt_control(char *value) {
  if (value != NULL) {
    printf("接收到mqtt_control命令，参数: %s\n", value);
    
    // 打印更新前的MqttTest值
    printf("更新前MqttTest值: %s\n", MqttTest);
    
    // 将接收到的数据赋值给MqttTest
    strncpy(MqttTest, value, sizeof(MqttTest) - 1);
    MqttTest[sizeof(MqttTest) - 1] = '\0';  // 确保字符串结束
    
    // 打印更新后的MqttTest值
    printf("更新后MqttTest值: %s\n", MqttTest);
    
    // 这里可以根据不同的参数值执行不同的操作
    if (strncmp(value, "A", 1) == 0) {
      printf("执行A类操作: %s\n", value);
      // 可以在这里添加A1, A2, A3的具体处理逻辑
    } else if (strncmp(value, "B", 1) == 0) {
      printf("执行B类操作: %s\n", value);
      // 可以在这里添加B1, B2, B3的具体处理逻辑
    }
  }
}

/***************************************************************
* 函数名称: set_motor_state_new
* 说    明: 设置电机状态（新格式）
* 参    数: char *value - 电机状态值
* 返 回 值: 无
***************************************************************/
void set_motor_state_new(char *value) {
  event_info_t event={0};
  event.event=event_iot_cmd;

  if (value != NULL) {
    if (!strcmp(value, "ON")) {
      event.data.iot_data = IOT_CMD_MOTOR_ON;
    } else if (!strcmp(value, "OFF")) {
      event.data.iot_data = IOT_CMD_MOTOR_OFF;
    }
    smart_home_event_send(&event);
  }
}


/***************************************************************
* 函数名称: mqtt_message_arrived
* 说    明: 接收mqtt数据
* 参    数: MessageData *data
* 返 回 值: 无
***************************************************************/
void mqtt_message_arrived(MessageData *data) {
  int rc;
  cJSON *root = NULL;
  char *request_id_idx = NULL;
  char request_id[40] = {0};
  MQTTMessage message;
  char payload[MAX_BUFFER_LENGTH];
  char rsptopic[128] = {0};

  printf("=== MQTT消息接收调试 ===\n");
  printf("Topic: %.*s\n", data->topicName->lenstring.len, data->topicName->lenstring.data);
  printf("Payload长度: %d\n", data->message->payloadlen);
  printf("Payload内容: %.*s\n", data->message->payloadlen, (char*)data->message->payload);
  printf("当前MqttTest值: %s\n", MqttTest);
  printf("========================\n");

  // get request id
  request_id_idx = strstr(data->topicName->lenstring.data, "request_id=");
  if (request_id_idx != NULL) {
    strncpy(request_id, request_id_idx + 11, 19);
    printf("提取到request_id: %s\n", request_id);
    
    // create response topic
    sprintf(rsptopic, "%s/request_id=%s", response_topic, request_id);
    printf("响应Topic: %s\n", rsptopic);

    // response message
    message.qos = 0;
    message.retained = 0;
    message.payload = payload;
    sprintf(payload, "{ \\
      \"result_code\": 0, \\
      \"response_name\": \"COMMAND_RESPONSE\", \\
      \"paras\": { \\
          \"result\": \"success\" \\
      } \\
      }");
    message.payloadlen = strlen(payload);

    // publish the msg to response topic
    if ((rc = MQTTPublish(&client, rsptopic, &message)) != 0) {
      printf("MQTT响应发布失败，错误码: %d\n", rc);
      mqttConnectFlag = 0;
    } else {
      printf("MQTT响应发布成功\n");
    }
  } else {
    printf("未找到request_id，可能是属性上报或其他类型消息\n");
  }

  // 解析旧的JSON格式: {"command_name": "mqtt_control", "paras": {"value": "A1"}}
  printf("开始解析JSON数据...\n");
  root = cJSON_ParseWithLength(data->message->payload, data->message->payloadlen);
  if (root != NULL) {
    printf("JSON解析成功\n");
    
    // 打印完整的JSON结构用于调试
    char *json_string = cJSON_Print(root);
    if (json_string) {
      printf("解析后的JSON结构:\n%s\n", json_string);
      free(json_string);
    }
    
    // 解析旧的command_name格式
    cJSON *cmd_name = cJSON_GetObjectItem(root, "command_name");
    if (cmd_name != NULL) {
      char *cmd_name_str = cJSON_GetStringValue(cmd_name);
      printf("找到command_name: %s\n", cmd_name_str);
      
      if (!strcmp(cmd_name_str, "light_control")) {
        printf("处理灯光控制命令\n");
        set_light_state(root);
      } else if (!strcmp(cmd_name_str, "motor_control")) {
        printf("处理电机控制命令\n");
        set_motor_state(root);
      } else if (!strcmp(cmd_name_str, "auto_control")) {
        printf("处理自动控制命令\n");
        set_auto_state(root);
      } else if (!strcmp(cmd_name_str, "mqtt_control")) {
        printf("处理mqtt_control命令\n");
        // 解析mqtt_control的参数
        cJSON *para_obj = cJSON_GetObjectItem(root, "paras");
        if (para_obj != NULL) {
          cJSON *value_obj = cJSON_GetObjectItem(para_obj, "value");
          if (value_obj != NULL) {
            char *mqtt_control_value = cJSON_GetStringValue(value_obj);
            if (mqtt_control_value != NULL) {
              printf("mqtt_control参数: %s\n", mqtt_control_value);
              printf("调用handle_mqtt_control函数...\n");
              handle_mqtt_control(mqtt_control_value);
              printf("handle_mqtt_control函数调用完成\n");
              printf("处理后MqttTest值: %s\n", MqttTest);
            } else {
              printf("mqtt_control的value值为空\n");
            }
          } else {
            printf("未找到mqtt_control的value参数\n");
          }
        } else {
          printf("未找到mqtt_control的paras对象\n");
        }
      } else if (!strcmp(cmd_name_str, "beep_control")) {
        printf("处理蜂鸣器控制命令\n");
        // 解析beep_control的参数
        cJSON *para_obj = cJSON_GetObjectItem(root, "paras");
        if (para_obj != NULL) {
          cJSON *onoff_obj = cJSON_GetObjectItem(para_obj, "onoff");
          if (onoff_obj != NULL) {
            char *onoff_value = cJSON_GetStringValue(onoff_obj);
            if (onoff_value != NULL) {
              printf("beep_control参数: %s\n", onoff_value);
              if (!strcmp(onoff_value, "ON")) {
                printf("启动蜂鸣器播放音乐\n");
                beep_play_music();  // 直接调用播放函数
              } else if (!strcmp(onoff_value, "OFF")) {
                printf("收到停止蜂鸣器命令\n");
                // 注意：当前的beep_play_music是一次性播放，无法中途停止
                // 如需停止功能，需要重新设计蜂鸣器播放逻辑
              }
            } else {
              printf("beep_control的onoff值为空\n");
            }
          } else {
            printf("未找到beep_control的onoff参数\n");
          }
        } else {
          printf("未找到beep_control的paras对象\n");
        }
      } else {
        printf("未知的command_name: %s\n", cmd_name_str);
      }
    } else {
      printf("未找到command_name字段\n");
    }
  } else {
    printf("JSON解析失败！\n");
  }

  printf("=== MQTT消息处理完成 ===\n\n");
  cJSON_Delete(root);
}

/***************************************************************
* 函数名称: wait_message
* 说    明: 等待信息
* 参    数: 无
* 返 回 值: 无
***************************************************************/
int wait_message() {
  uint8_t rec = MQTTYield(&client, 5000);
  if (rec != 0) {
    mqttConnectFlag = 0;
  }
  if (mqttConnectFlag == 0) {
    return 0;
  }
  return 1;
}

/***************************************************************
* 函数名称: mqtt_init
* 说    明: mqtt初始化
* 参    数: 无
* 返 回 值: 无
***************************************************************/
void mqtt_init() {
  int rc;

  printf("Starting MQTT...\n");

  /*网络初始化*/
  NetworkInit(&network);

begin:
  /* 连接网络*/
  printf("NetworkConnect  ...\n");
  NetworkConnect(&network, HOST_ADDR, 1883);
  printf("MQTTClientInit  ...\n");
  /*MQTT客户端初始化*/
  MQTTClientInit(&client, &network, 2000, sendBuf, sizeof(sendBuf), readBuf,
                 sizeof(readBuf));

  MQTTString clientId = MQTTString_initializer;
  clientId.cstring = mqtt_devid;

  MQTTString userName = MQTTString_initializer;
  userName.cstring = mqtt_username;

  MQTTString password = MQTTString_initializer;
  password.cstring = mqtt_pwd;

  MQTTPacket_connectData data = MQTTPacket_connectData_initializer;
  data.clientID = clientId;
  data.username = userName;
  data.password = password;
  data.willFlag = 0;
  data.MQTTVersion = 4;
  data.keepAliveInterval = 60;
  data.cleansession = 1;

  printf("MQTTConnect  ...\n");
  rc = MQTTConnect(&client, &data);
  if (rc != 0) {
    printf("MQTTConnect: %d\n", rc);
    NetworkDisconnect(&network);
    MQTTDisconnect(&client);
    osDelay(200);
    goto begin;
  }

  printf("MQTTSubscribe  ...\n");
  // sprintf(subcribe_topic,"$oc/devices/%s/sys/commands/+",mqtt_devid);
  rc = MQTTSubscribe(&client, subcribe_topic, 0, mqtt_message_arrived);
  if (rc != 0) {
    printf("MQTTSubscribe: %d\n", rc);
    osDelay(200);
    goto begin;
  }

  mqttConnectFlag = 1;
}

/***************************************************************
* 函数名称: mqtt_is_connected
* 说    明: mqtt连接状态
* 参    数: 无
* 返 回 值: unsigned int 状态
***************************************************************/
unsigned int mqtt_is_connected() { return mqttConnectFlag; }

/***************************************************************
* 函数名称: get_mqtt_test_value
* 说    明: 获取MqttTest变量的值
* 参    数: 无
* 返 回 值: MqttTest变量的值
***************************************************************/
const char* get_mqtt_test_value(void)
{
    return MqttTest;
}
