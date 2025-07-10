export default class DeviceBean{
  deviceId: number;//设备id
  name: string; //设备名
  temperator: number;// 室内温度
  humidity: number;//室内湿度
  lumination: number;//光照
  isRain: number;//下雨预警 0：正常 1：触发警报
  isSmoke:number;//烟雾报警 0：正常 1：触发警报
  isFire: number;// 火灾报警 0：正常 1：触发警报
  doorStatus: number;// 门开关状态 0：正常 1：开启
  garageStatus: number;//车库门开关  0：正常 1：开启
  curtainStatus: number;//窗联开关  0：正常 1：开启
  lightStatus: number; //灯开关  0：正常 1：开启



  constructor(deviceId: number, name: string, temperator: number,
              humidity: number, lumination: number,isRain: number,
              isSmoke:number,isFire: number,doorStatus: number,
              garageStatus: number,curtainStatus: number,lightStatus: number) {
    this.deviceId = deviceId;
    this.name = name;
    this.temperator = temperator;
    this.humidity = humidity;
    this.lumination = lumination;
    this.isRain = isRain;
    this.isSmoke = isSmoke;
    this.isFire = isFire;
    this.doorStatus = doorStatus;
    this.garageStatus = garageStatus;
    this.curtainStatus = curtainStatus;
    this.lightStatus = lightStatus;

  }
}