import { IAMTokenPreferencesDataUtil } from '../utils/IAMTokenPreferencesDataUtil';
import axios, { AxiosError, AxiosResponse } from '@ohos/axios';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { SensorInfo } from '../model/SensorInfo';

// 定义灯光控制请求参数接口
interface LightControlParams {
  onoff: string;
}

// 定义灯光控制请求接口
interface LightControlRequest {
  service_id: string;
  command_name: string;
  paras: LightControlParams;
}

// 定义震动控制请求参数接口
interface MotorControlParams {
  onoff: string;
}

// 定义震动控制请求接口
interface MotorControlRequest {
  service_id: string;
  command_name: string;
  paras: MotorControlParams;
}

// 定义寻找药箱请求参数接口
interface FindBoxParams {
  onoff: string;
}

// 定义寻找药箱请求接口
interface FindBoxRequest {
  service_id: string;
  command_name: string;
  paras: FindBoxParams;
}

// 在文件顶部添加药品接口定义
interface Medicine {
  id: number;
  name: string;
  times: string[];
  frequency: string;
  location: string;
}

interface MqttControlParams {
  value: string;
}

// 定义MQTT控制请求接口
interface MqttControlRequest {
  service_id: string;
  command_name: string;
  paras: MqttControlParams;
}

interface MissedMedicineItem {
  medicine: Medicine;
  missedTime: string;
}


// 添加蜂鸣器控制参数接口
interface BeepControlParams {
  onoff: string;
}

// 添加蜂鸣器控制请求接口
interface BeepControlRequest {
  service_id: string;
  command_name: string;
  paras: BeepControlParams;
}

interface UserInfo {
  id: number;
  name: string;
  avatar: Resource;
  signature: string;
}

@Component
export default struct HouseStateComponent {
  @State sensorInfo: SensorInfo = new SensorInfo();
  @State lightStatus: boolean = false; // 灯光开关状态
  @State vibrationStatus: boolean = false; // 震动开关状态
  @State findBoxStatus: boolean = false; // 寻找药箱状态
  @State currentUserName: string = 'Dove'; // 当前用户名
  @State userList: Array<UserInfo> = [
    {
      id: 1,
      name: 'Dove',
      avatar: $r('app.media.user_avtar'),
      signature: '管理账号'
    },
    {
      id: 2,
      name: 'Young',
      avatar: $r('app.media.young_avtar'),
      signature: '年轻用户，活力满满'
    },
    {
      id: 3,
      name: 'Elder',
      avatar: $r('app.media.old_avtar'),
      signature: '长者用户，经验丰富'
    }
  ];
  // 添加药品列表状态变量
  @State medicineList: Array<Medicine> = [];
  // 添加已检查药品记录
  private checkedMedicines: Set<string> = new Set();

  // 添加寻找药箱定时器变量
  private findBoxTimerId: number = 0; // 寻找药箱定时器ID
  // 添加第一次连接标志
  private isFirstConnection: boolean = true; // 是否第一次连接设备

  private timerId: number = 0;//计时器id，每3秒读取一次数据

  @Builder
  IconOverlay(icon: string) {
    Text(icon)
      .fontSize(24)
  }

  @Builder
  SwitchOverlay() {
    Text('○')
      .fontSize(12)
      .fontColor('#ffffff')
  }

  @Builder
  NotificationDot() {
    Circle({width: 6, height: 6})
      .fill('#ff4444')
      .position({x: 8, y: -2})
  }

  @Builder
  ActiveIndicator() {
    Rect({width: 20, height: 2})
      .fill('#0066cc')
  }

  // 控制灯光开关的方法
  controlLight = (onoff: string): void => {
    const token = IAMTokenPreferencesDataUtil.init().getPreferencesData('token');
    // 修正：使用commands路径而不是properties路径
    const url = 'https://61357a1900.st1.iotda-app.cn-north-4.myhuaweicloud.com:443/v5/iot/5390eb2140d2435c91cadccf942fb3eb/devices/685f8b5ed582f2001835e760_Smart_Medicien_Box/commands';
    
    const requestData: LightControlRequest = {
      service_id: "IntelligentCookpit",
      command_name: "light_control",
      paras: {
        onoff: onoff
      }
    };
  
    const axiosInstance = axios.create({
      headers: {
        "Content-Type": "application/json",
        "X-Auth-Token": token
      }
    });
  
    // 修正：使用POST方法而不是PUT方法
    axiosInstance.post(url, requestData).then((response: AxiosResponse) => {
      console.log('灯光控制成功:', JSON.stringify(response.data));
      hilog.info(2311, 'testTag', '灯光控制成功:', JSON.stringify(response.data));
    }).catch((error: AxiosError) => {
      console.log('灯光控制失败:', JSON.stringify(error));
      hilog.error(2311, 'testTag', '灯光控制失败:', JSON.stringify(error));
    });
  }

  // 控制震动电机的方法
  controlMotor = (onoff: string): void => {
    const token = IAMTokenPreferencesDataUtil.init().getPreferencesData('token');
    const url = 'https://61357a1900.st1.iotda-app.cn-north-4.myhuaweicloud.com:443/v5/iot/5390eb2140d2435c91cadccf942fb3eb/devices/685f8b5ed582f2001835e760_Smart_Medicien_Box/commands';
    
    const requestData: MotorControlRequest = {
      service_id: "IntelligentCookpit",
      command_name: "motor_control",
      paras: {
        onoff: onoff
      }
    };

    const axiosInstance = axios.create({
      headers: {
        "Content-Type": "application/json",
        "X-Auth-Token": token
      }
    });

    axiosInstance.post(url, requestData).then((response: AxiosResponse) => {
      console.log('震动控制成功:', JSON.stringify(response.data));
      hilog.info(2311, 'testTag', '震动控制成功:', JSON.stringify(response.data));
    }).catch((error: AxiosError) => {
      console.log('震动控制失败:', JSON.stringify(error));
      hilog.error(2311, 'testTag', '震动控制失败:', JSON.stringify(error));
    });
  }

  // 获取影子数据的方法
  getSensorAll = (): void => {
    const token = IAMTokenPreferencesDataUtil.init().getPreferencesData('token');
    // 智能药盒设备的影子数据URL
    const url = 'https://61357a1900.st1.iotda-app.cn-north-4.myhuaweicloud.com:443/v5/iot/5390eb2140d2435c91cadccf942fb3eb/devices/685f8b5ed582f2001835e760_Smart_Medicien_Box/shadow';
    const axiosInstance = axios.create({
      headers:{
        "Content-Type": "application/json",
        "X-Auth-Token": token
      }
    });

    axiosInstance.get(url).then((response: AxiosResponse) => {
      const shadow: string = JSON.stringify(response.data['shadow']);
      const shadowObject = JSON.parse(shadow)[0].reported.properties as SensorInfo;
      // 逐个属性进行赋值 - 智能药盒相关属性
      this.sensorInfo.temperature = shadowObject.temperature;
      this.sensorInfo.illumination = shadowObject.illumination;
      this.sensorInfo.humidity = shadowObject.humidity;
      this.sensorInfo.motorStatus = shadowObject.motorStatus;
      this.sensorInfo.lightStatus = shadowObject.lightStatus;
      this.sensorInfo.autoStatus = shadowObject.autoStatus;
      this.sensorInfo.gas = shadowObject.gas;
      
      // 如果是第一次连接成功，显示提示框
      if (this.isFirstConnection) {
        this.isFirstConnection = false;
        // 显示设备连接成功提示框
        AlertDialog.show({
          title: '提示',
          message: '设备连接成功!',
          autoCancel: true,
          alignment: DialogAlignment.Center,
          confirm: {
            value: '确定',
            action: () => {
              console.log('设备连接成功提示框已确认');
            }
          }
        });
      }
      
      console.log('获取的影子数据是: : ', JSON.stringify(shadow))
      hilog.info(2311, 'testTag', '获取的影子数据是: ', JSON.stringify(this.sensorInfo))
    }).catch((error: AxiosError) => {
      console.log('testTag', JSON.stringify(error));
    })
  }

  // 控制寻找药箱的方法
  findBox = (): void => {
    const token = IAMTokenPreferencesDataUtil.init().getPreferencesData('token');
    const url = 'https://61357a1900.st1.iotda-app.cn-north-4.myhuaweicloud.com:443/v5/iot/5390eb2140d2435c91cadccf942fb3eb/devices/685f8b5ed582f2001835e760_Smart_Medicien_Box/commands';
    
    if (this.findBoxStatus) {
      // 开启状态：同时发送find_box、beep_control和motor_control命令
      const findBoxRequest: FindBoxRequest = {
        service_id: "IntelligentCookpit",
        command_name: "find_box",
        paras: {
          onoff: "ON"
        }
      };

      const beepRequest: BeepControlRequest = {
        service_id: "IntelligentCookpit",
        command_name: "beep_control",
        paras: {
          onoff: "ON"
        }
      };

      const motorRequest: MotorControlRequest = {
        service_id: "IntelligentCookpit",
        command_name: "motor_control",
        paras: {
          onoff: "ON"
        }
      };

      const axiosInstance = axios.create({
        headers: {
          "Content-Type": "application/json",
          "X-Auth-Token": token
        }
      });

      // 发送find_box命令
      axiosInstance.post(url, findBoxRequest).then((response: AxiosResponse) => {
        console.log('寻找药箱开启成功:', JSON.stringify(response.data));
        hilog.info(2311, 'testTag', '寻找药箱开启成功:', JSON.stringify(response.data));
      }).catch((error: AxiosError) => {
        console.log('寻找药箱开启失败:', JSON.stringify(error));
        hilog.error(2311, 'testTag', '寻找药箱开启失败:', JSON.stringify(error));
      });

      // 发送beep_control命令
      axiosInstance.post(url, beepRequest).then((response: AxiosResponse) => {
        console.log('蜂鸣器开启成功:', JSON.stringify(response.data));
        hilog.info(2311, 'testTag', '蜂鸣器开启成功:', JSON.stringify(response.data));
      }).catch((error: AxiosError) => {
        console.log('蜂鸣器开启失败:', JSON.stringify(error));
        hilog.error(2311, 'testTag', '蜂鸣器开启失败:', JSON.stringify(error));
      });

      // 发送motor_control命令
      axiosInstance.post(url, motorRequest).then((response: AxiosResponse) => {
        console.log('震动开启成功:', JSON.stringify(response.data));
        hilog.info(2311, 'testTag', '震动开启成功:', JSON.stringify(response.data));
      }).catch((error: AxiosError) => {
        console.log('震动开启失败:', JSON.stringify(error));
        hilog.error(2311, 'testTag', '震动开启失败:', JSON.stringify(error));
      });

      // 设置20秒后自动关闭
      this.findBoxTimerId = setTimeout(() => {
        this.findBoxStatus = false;
        this.vibrationStatus = false;
        this.autoCloseFindBox();
      }, 20000);

    } else {
      // 关闭状态：清除定时器并发送关闭命令
      if (this.findBoxTimerId) {
        clearTimeout(this.findBoxTimerId);
        this.findBoxTimerId = 0;
      }
      this.autoCloseFindBox();
    }
  }

  // 自动关闭寻找药箱功能的方法
  private autoCloseFindBox = (): void => {
    const token = IAMTokenPreferencesDataUtil.init().getPreferencesData('token');
    const url = 'https://61357a1900.st1.iotda-app.cn-north-4.myhuaweicloud.com:443/v5/iot/5390eb2140d2435c91cadccf942fb3eb/devices/685f8b5ed582f2001835e760_Smart_Medicien_Box/commands';
    
    const findBoxRequest: FindBoxRequest = {
      service_id: "IntelligentCookpit",
      command_name: "find_box",
      paras: {
        onoff: "OFF"
      }
    };

    const beepRequest: BeepControlRequest = {
      service_id: "IntelligentCookpit",
      command_name: "beep_control",
      paras: {
        onoff: "OFF"
      }
    };

    const motorRequest: MotorControlRequest = {
      service_id: "IntelligentCookpit",
      command_name: "motor_control",
      paras: {
        onoff: "OFF"
      }
    };

    const axiosInstance = axios.create({
      headers: {
        "Content-Type": "application/json",
        "X-Auth-Token": token
      }
    });

    // 发送关闭命令
    axiosInstance.post(url, findBoxRequest).catch((error: AxiosError) => {
      console.log('寻找药箱关闭失败:', JSON.stringify(error));
    });

    axiosInstance.post(url, beepRequest).catch((error: AxiosError) => {
      console.log('蜂鸣器关闭失败:', JSON.stringify(error));
    });

    axiosInstance.post(url, motorRequest).catch((error: AxiosError) => {
      console.log('震动关闭失败:', JSON.stringify(error));
    });

    console.log('寻找药箱功能已自动关闭');
    hilog.info(2311, 'testTag', '寻找药箱功能已自动关闭');
  }

  // 添加用户管理方法
private getUserNameFromStorage(): string {
  // 从本地存储获取当前用户名，如果没有则返回默认值
  const token = IAMTokenPreferencesDataUtil.init().getPreferencesData('currentUser');
  return token || 'Dove';
}

private saveCurrentUser(userName: string): void {
  // 保存当前用户名到本地存储
  IAMTokenPreferencesDataUtil.init().setPreferencesData('currentUser', userName);
}

// 监听用户切换事件的方法
private checkUserChange(): void {
  const storedUser = this.getUserNameFromStorage();
  if (storedUser !== this.currentUserName) {
    this.currentUserName = storedUser;
  }
}

  build(){
    Scroll() {
      Column({space: 16}){
        // 顶部状态栏
        Row(){
          Text('智能药盒')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          
          Blank()

        }
        .width('100%')
        .padding({left: 16, right: 16, top: 16})
        
        // 主要信息卡片
      Column({space: 12}){
          
        Image($r('app.media.HAVVK'))
            .width(280)
            .height(160)
            .objectFit(ImageFit.Contain)
            .margin({top: 20, bottom: 20})

        Text(`当前用户: ${this.currentUserName}`)
          .fontSize(12)
          .fontColor('#999999')
          .margin({bottom: 20})
        }
        .width('100%')
        .backgroundColor('#ffffff')
        .borderRadius(12)
        .padding(16)
        .margin({left: 16, right: 16})
        
        // 控制按钮区域
        Row({space: 15}) {
          // 灯光开关按钮
          Column({space: 8}) {
            Button() {
              Text('💡')
                .fontSize(24)
                .fontColor('#ffffff')
            }
            .width(60)
            .height(60)
            .borderRadius(30)
            .backgroundColor(this.lightStatus ? '#0066cc' : '#ffffff')
            .border({
              width: 2,
              color: this.lightStatus ? '#0066cc' : '#cccccc'
            })
            .onClick(() => {
              this.lightStatus = !this.lightStatus;
              // 发送灯光控制指令
              const onoffValue = this.lightStatus ? 'ON' : 'OFF';
              this.controlLight(onoffValue);
              console.log('灯光开关状态:', this.lightStatus);
            })
            
            Text('灯光开关')
              .fontSize(14)
              .fontColor('#666666')
          }
          
          // 震动开关按钮
          Column({space: 8}) {
            Button() {
              Text('📳')
                .fontSize(24)
                .fontColor('#ffffff')
            }
            .width(60)
            .height(60)
            .borderRadius(30)
            .backgroundColor(this.vibrationStatus ? '#0066cc' : '#ffffff')
            .border({
              width: 2,
              color: this.vibrationStatus ? '#0066cc' : '#cccccc'
            })
            .onClick(() => {
              this.vibrationStatus = !this.vibrationStatus;
              // 发送震动控制指令
              const onoffValue = this.vibrationStatus ? 'ON' : 'OFF';
              this.controlMotor(onoffValue);
              console.log('震动开关状态:', this.vibrationStatus);
            })
            
            Text('震动开关')
              .fontSize(14)
              .fontColor('#666666')
          }
          
          // 寻找药箱按钮
          Column({space: 8}) {
            Button() {
              Text('🔍')
                .fontSize(24)
                .fontColor(this.findBoxStatus ? '#ffffff' : '#666666')
            }
            .width(60)
            .height(60)
            .borderRadius(30)
            .backgroundColor(this.findBoxStatus ? '#0066cc' : '#ffffff')
            .border({
              width: 2,
              color: this.findBoxStatus ? '#0066cc' : '#cccccc'
            })
            .onClick(() => {
              this.findBoxStatus = !this.findBoxStatus;
              // 同步更新震动状态
              this.vibrationStatus = this.findBoxStatus;
              // 发送寻找药箱指令
              this.findBox();
              console.log('寻找药箱指令已发送, 状态:', this.findBoxStatus);
            })
            
            Text('寻找药箱')
              .fontSize(14)
              .fontColor('#666666')
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
        .padding({left: 16, right: 16, top: 16, bottom: 16})
        
        // 底部信息卡片
        Column({space: 16}){
          // 第一行：湿度和温度
          Row({space: 16}){
            // 湿度卡片
            Column({space: 8}){
              Row({space: 8}){
                Text('💧️')
                  .fontSize(20)
                Text('当前湿度')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                
                Blank()
              }
              .width('100%')
              
              Row(){
                Text(`${this.sensorInfo.humidity}%`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                Blank()
              }
              .width('100%')
            }
            .width(170)
            .height(120)
            .backgroundColor('#ffffff')
            .borderRadius(12)
            .padding(12)

            // 温度卡片
            Column({space: 8}){
              Row({space: 8}){
                Text('🌡️️')
                  .fontSize(20)
                Text('当前温度')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)

                Blank()
              }
              .width('100%')

              Row(){
                Text(`${this.sensorInfo.temperature}°C`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                Blank()
              }
              .width('100%')
            }
            .width(170)
            .height(120)
            .backgroundColor('#ffffff')
            .borderRadius(12)
            .padding(12)
          }
          .width('100%')
          
          // 第二行：光照强度和可燃气体值
          Row({space: 16}){
            // 光照强度卡片
            Column({space: 8}){
              Row({space: 8}){
                Text('☀️')
                  .fontSize(20)
                Text('光照强度')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                
                Blank()
              }
              .width('100%')
              
              Row(){
                Text(`${this.sensorInfo.illumination}lux`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                Blank()
              }
              .width('100%')
            }
            .width(170)
            .height(120)
            .backgroundColor('#ffffff')
            .borderRadius(12)
            .padding(12)

            // 可燃气体卡片
            Column({space: 8}){
              Row({space: 8}){
                Text('💨')
                  .fontSize(20)
                Text('可燃气体值')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)

                Blank()
              }
              .width('100%')

              Row(){
                Text(`${this.sensorInfo.gas}ppm`)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.sensorInfo.gas > 1000 ? '#ff0000' : '#333333')
                Blank()
              }
              .width('100%')
            }
            .width(170)
            .height(120)
            .backgroundColor('#ffffff')
            .borderRadius(12)
            .padding(12)
          }
          .width('100%')
          
          // 第三行：可能漏服的药品卡片
          Column({space: 12}) {
            Row({space: 8}) {
              Text('💊')
                .fontSize(20)
              Text('可能漏服的药品')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              
              Blank()
            }
            .width('100%')
            
            // 漏服药品列表
            Column({space: 8}) {
              ForEach(this.getMissedMedicines(), (item: MissedMedicineItem, index: number) => {
                Row({space: 12}) {
                  Column({space: 4}) {
                    Text(item.medicine.name)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333333')
                    Text(`应服时间: ${item.missedTime}`)
                      .fontSize(12)
                      .fontColor('#666666')
                    Text(`位置: ${item.medicine.location}`)
                      .fontSize(12)
                      .fontColor('#999999')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  
                  Button('已服药')
                    .fontSize(12)
                    .fontColor('#ffffff')
                    .backgroundColor('#28a745')
                    .borderRadius(6)
                    .padding({left: 12, right: 12, top: 6, bottom: 6})
                    .onClick(() => {
                      this.markMedicineAsTaken(item.medicine.id, item.missedTime);
                    })
                }
                .width('100%')
                .padding({left: 12, right: 12, top: 8, bottom: 8})
                .backgroundColor('#f8f9fa')
                .borderRadius(8)
}, (item: MissedMedicineItem, index: number) => `${item.medicine.id}-${item.missedTime}-${index}`)              
              // 如果没有漏服药品，显示提示信息
              if (this.getMissedMedicines().length === 0) {
                Row() {
                  Text('暂无漏服药品')
                    .fontSize(14)
                    .fontColor('#999999')
                    .textAlign(TextAlign.Center)
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .padding({top: 20, bottom: 20})
              }
            }
            .width('100%')
          }
          .width('100%')
          .backgroundColor('#ffffff')
          .borderRadius(12)
          .padding(16)
        }
        .width('100%')
        .padding({left: 16, right: 16, bottom: 20})

      }
      .width('100%')
      .backgroundColor('#f5f5f5')


      
    }
    .width('100%')
    .height('100%')
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Auto)
  }

  private getMissedMedicines(): Array<MissedMedicineItem> {
    const now = new Date();
    const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
    const currentDate = now.toDateString();
    const missedMedicines: Array<MissedMedicineItem> = [];
    
    this.medicineList.forEach((medicine: Medicine) => {
      medicine.times.forEach((time: string) => {
        const checkKey = `${medicine.id}-${time}-${currentDate}`;
        
        // 检查当前时间是否已经超过服药时间，且今天还未服药
        if (currentTime > time && !this.checkedMedicines.has(checkKey)) {
          missedMedicines.push({
            medicine: medicine,
            missedTime: time
          });
        }
      });
    });
    
    return missedMedicines;
  }



  // 标记药品已服用的方法
  private markMedicineAsTaken(medicineId: number, time: string): void {
    const now = new Date();
    const currentDate = now.toDateString();
    const checkKey = `${medicineId}-${time}-${currentDate}`;
    
    // 添加到已检查记录中
    this.checkedMedicines.add(checkKey);
    
    // 触发UI更新 - 通过更新一个状态变量来强制刷新
    this.medicineList = [...this.medicineList];
    
    console.log(`药品已标记为已服用: ID=${medicineId}, 时间=${time}`);
    hilog.info(2311, 'testTag', `药品已标记为已服用: ID=${medicineId}, 时间=${time}`);
  }

  // 发送MQTT控制命令的方法
  sendMqttControl = (location: string): void => {
    const token = IAMTokenPreferencesDataUtil.init().getPreferencesData('token');
    const url = 'https://61357a1900.st1.iotda-app.cn-north-4.myhuaweicloud.com:443/v5/iot/5390eb2140d2435c91cadccf942fb3eb/devices/685f8b5ed582f2001835e760_Smart_Medicien_Box/commands';
    
    const requestData: MqttControlRequest = {
      service_id: "IntelligentCookpit",
      command_name: "mqtt_control",
      paras: {
        value: location
      }
    };

    const axiosInstance = axios.create({
      headers: {
        "Content-Type": "application/json",
        "X-Auth-Token": token
      }
    });

    axiosInstance.post(url, requestData).then((response: AxiosResponse) => {
      console.log(`MQTT控制成功，位置${location}:`, JSON.stringify(response.data));
      hilog.info(2311, 'testTag', `MQTT控制成功，位置${location}:`, JSON.stringify(response.data));
      
      // 发送成功后开启beep_control
      this.sendBeepControl('ON');
    }).catch((error: AxiosError) => {
      console.log(`MQTT控制失败，位置${location}:`, JSON.stringify(error));
      hilog.error(2311, 'testTag', `MQTT控制失败，位置${location}:`, JSON.stringify(error));
    });
  }

  // 发送蜂鸣器控制命令的方法
  sendBeepControl = (onoff: string): void => {
    const token = IAMTokenPreferencesDataUtil.init().getPreferencesData('token');
    const url = 'https://61357a1900.st1.iotda-app.cn-north-4.myhuaweicloud.com:443/v5/iot/5390eb2140d2435c91cadccf942fb3eb/devices/685f8b5ed582f2001835e760_Smart_Medicien_Box/commands';
    
    const requestData: BeepControlRequest = {
      service_id: "IntelligentCookpit",
      command_name: "beep_control",
      paras: {
        onoff: onoff
      }
    };
    
    const axiosInstance = axios.create({
      headers: {
        "Content-Type": "application/json",
        "X-Auth-Token": token
      }
    });

    axiosInstance.post(url, requestData).then((response: AxiosResponse) => {
      console.log(`蜂鸣器控制成功，状态${onoff}:`, JSON.stringify(response.data));
      hilog.info(2311, 'testTag', `蜂鸣器控制成功，状态${onoff}:`, JSON.stringify(response.data));
    }).catch((error: AxiosError) => {
      console.log(`蜂鸣器控制失败，状态${onoff}:`, JSON.stringify(error));
      hilog.error(2311, 'testTag', `蜂鸣器控制失败，状态${onoff}:`, JSON.stringify(error));
    });
  }

  // 获取药品数据的方法
  private getMedicineData(): void {
    // 从本地存储获取药品数据，这里模拟数据，实际应该从DeviceSearchComponent获取
    const medicineData = IAMTokenPreferencesDataUtil.init().getPreferencesData('medicineList');
    if (medicineData) {
      try {
        this.medicineList = JSON.parse(medicineData);
      } catch (error) {
        console.log('解析药品数据失败:', error);
        // 如果解析失败，使用默认数据
        this.medicineList = [
          {
            id: 1,
            name: '阿司匹林',
            times: ['08:00'],
            frequency: '每日一次',
            location: 'A1'
          },
          {
            id: 2,
            name: '维生素C',
            times: ['08:00', '20:00'],
            frequency: '每日两次',
            location: 'B1'
          }
        ];
      }
    } else {
      // 如果没有数据，使用默认数据
      this.medicineList = [
        {
          id: 1,
          name: '阿司匹林',
          times: ['08:00'],
          frequency: '每日一次',
          location: 'A1'
        },
        {
          id: 2,
          name: '维生素C',
          times: ['08:00', '20:00'],
          frequency: '每日两次',
          location: 'B1'
        }
      ];
    }
  }

  // 检查服药时间的方法
  private checkMedicineTime(): void {
    const now = new Date();
    const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
    const currentDate = now.toDateString(); // 获取当前日期，用于避免同一天重复提醒

    // 收集当前时间需要服药的药品位置
    const medicineLocations: string[] = [];
    
    this.medicineList.forEach((medicine: Medicine) => {
      medicine.times.forEach((time: string) => {
        const checkKey = `${medicine.id}-${time}-${currentDate}`; // 创建唯一标识
        
        // 检查当前时间是否匹配服药时间，且今天还未提醒过
        if (currentTime === time && !this.checkedMedicines.has(checkKey)) {
          console.log(`服药时间到了！药品：${medicine.name}，时间：${time}，位置：${medicine.location}`);
          hilog.info(2311, 'testTag', `服药时间到了！药品：${medicine.name}，时间：${time}，位置：${medicine.location}`);
          
          // 收集需要发送的位置信息
          medicineLocations.push(medicine.location);
          
          // 标记为已检查，避免重复提醒
          this.checkedMedicines.add(checkKey);
        }
      });
    });

    // 如果有需要服药的药品，按顺序发送位置信息
    if (medicineLocations.length > 0) {
      this.sendMedicineLocationsSequentially(medicineLocations);
    }

    // 清理过期的检查记录（保留最近3天的记录）
    const threeDaysAgo = new Date(now.getTime() - 3 * 24 * 60 * 60 * 1000).toDateString();
    const keysToDelete: string[] = [];
    this.checkedMedicines.forEach((key: string) => {
      const keyDate = key.split('-')[2];
      if (keyDate < threeDaysAgo) {
        keysToDelete.push(key);
      }
    });
    keysToDelete.forEach(key => this.checkedMedicines.delete(key));
  }

  // 按顺序发送药品位置信息的方法
  private sendMedicineLocationsSequentially(locations: string[]): void {
    locations.forEach((location: string, index: number) => {
      setTimeout(() => {
        this.sendMqttControl(location);
        console.log(`发送第${index + 1}个位置信息：${location}`);
        hilog.info(2311, 'testTag', `发送第${index + 1}个位置信息：${location}`);
      }, index * 60000); // 每个位置间隔60000毫秒
    });
  }

  aboutToAppear(){
    // 初始化当前用户名
    this.currentUserName = this.getUserNameFromStorage();
    
    // 获取药品数据
    this.getMedicineData();
    
    // 当页面出现时获取设备数据
    this.getSensorAll();

    // 每隔3秒加载一次数据，同时检查用户切换和服药时间
    this.timerId = setInterval(()=>{
      this.getSensorAll();
      this.checkUserChange(); // 添加用户切换检查
      this.checkMedicineTime(); // 添加服药时间检查
    }, 3000)
  }

  aboutToDisappear() {
    // 页面销毁时清除定时器
    if (this.timerId) {
      clearInterval(this.timerId);
    }
    // 清除寻找药箱定时器
    if (this.findBoxTimerId) {
      clearTimeout(this.findBoxTimerId);
    }
  }
}
