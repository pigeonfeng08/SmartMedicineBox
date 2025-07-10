import DeviceBean from '../common/bean/DeviceBean';
export class MainViewModel {

  public getDeviceData(deviceId: number) : DeviceBean {
    //此处先模拟数据，后面从设备读取
     let deviceBean = new DeviceBean(1,'Jerry设备',22.5,5.12,700,0,0,0,0,0,0,0);
     deviceBean.temperator = deviceBean.temperator + Math.floor(Math.random()*5)//模拟数据变动

     deviceBean.lumination = deviceBean.lumination +  Math.floor(Math.random()*5)//模拟数据变动


    return deviceBean;
  }

}
export default new MainViewModel();