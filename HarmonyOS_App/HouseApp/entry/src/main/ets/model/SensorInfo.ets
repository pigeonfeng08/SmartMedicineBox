export class SensorInfo {
  temperature: number = 0;      // 温度
  illumination: number = 0;     // 光照强度
  humidity: number = 0;         // 湿度
  motorStatus: boolean = false; // 电机状态
  lightStatus: boolean = false; // 灯光状态
  autoStatus: boolean = false;  // 自动模式状态
  gas: number = 0;              // 可燃气体值
}