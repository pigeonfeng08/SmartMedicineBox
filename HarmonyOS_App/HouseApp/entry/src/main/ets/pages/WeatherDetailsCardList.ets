import { WeatherDetailsCard } from '../view/WeatherDetailsCard'
import { IAMTokenPreferencesDataUtil } from '../utils/IAMTokenPreferencesDataUtil';
import axios, { AxiosError, AxiosResponse } from '@ohos/axios';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { SensorInfo } from '../model/SensorInfo';
@Entry
@Component
export struct WeatherDetailsCardList {
  @State sensorInfo: SensorInfo = new SensorInfo();

  aboutToAppear(): void {
    this.getSensorAll();
    setInterval(this.getSensorAll.bind(this), 3000);
  }
  
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
      this.sensorInfo.gas = shadowObject.gas;  // 添加可燃气体值的赋值
      console.log('获取的影子数据是: : ', JSON.stringify(shadow))
      hilog.info(2311, 'testTag', '获取的影子数据是: ', JSON.stringify(this.sensorInfo))
    }).catch((error: AxiosError) => {
      console.log('testTag', JSON.stringify(error));
    })
  }
  
  build() {
    Row({space: 20}) {
      WeatherDetailsCard({
        title: '温度',
        value: this.sensorInfo.temperature + '°C',
        icon: $r('app.media.house1'),
        errorValue: '',
        errorFlagIcon: $r('app.media.house1'),
        flag: false
      })
      WeatherDetailsCard({
        title: '湿度',
        value: this.sensorInfo.humidity + '%',
        icon: $r('app.media.house1'),
        errorValue: '5%',
        errorFlagIcon: $r('app.media.house1'),
        flag: true
      })
      WeatherDetailsCard({
        title: '光照',
        value: this.sensorInfo.illumination + 'lux',
        icon: $r('app.media.house1'),
        errorValue: '',
        errorFlagIcon: $r('app.media.house1'),
        flag: false
      })
      WeatherDetailsCard({
        title: '可燃气体',
        value: this.sensorInfo.gas + 'ppm',
        icon: $r('app.media.house1'),
        errorValue: '',
        errorFlagIcon: $r('app.media.house1'),
        flag: false
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .padding(16)
  }
}