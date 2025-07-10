import { InfoItem, MineItemList } from '../model/MineItemList';
import { IAMTokenPreferencesDataUtil } from '../utils/IAMTokenPreferencesDataUtil';

// 定义用户接口
interface User {
  id: number;
  name: string;
  avatar: Resource;
  signature: string;
}

@Component
export struct MineComponent {
  @State nickname: string = 'Dove'; // 昵称
  @State signature: string = '管理账号';//签名
  @State houseCount: string = '1个家庭'; // 家庭数量
  @State deviceCount: string = '6个智能设备'; // 设备数量
  @State currentUserAvatar: Resource = $r('app.media.user_avtar'); // 当前用户头像
  @State showUserSwitchDialog: boolean = false; // 控制用户切换对话框显示
  
  // 用户列表
  @State userList: User[] = [
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
  
  // 切换用户方法
  switchUser(user: User) {
    this.nickname = user.name;
    this.signature = user.signature;
    this.currentUserAvatar = user.avatar;
    this.showUserSwitchDialog = false;
    
    // 保存当前用户到本地存储，供其他组件使用
    const tokenUtil: IAMTokenPreferencesDataUtil = IAMTokenPreferencesDataUtil.init();
    tokenUtil.setPreferencesData('currentUser', user.name);
  }

  build(){
    Column(){
      // 顶部用户信息区域 - 添加点击事件
      Row(){
        Column({ space: 8 }){
          Row({ space: 8 }){
            Image($r('app.media.icon')) // Dove图标
              .width(24)
              .height(24)
            Text(this.nickname)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            Image($r('app.media.right'))
              .width(16)
              .height(16)
          }
          .alignItems(VerticalAlign.Center)
          
          Text(this.signature)
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 4 })
          
          Row({ space: 16 }){
            Text(this.houseCount)
              .fontSize(14)
              .fontColor('#666666')
            Text(this.deviceCount)
              .fontSize(14)
              .fontColor('#666666')
          }
          .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        // 右侧头像 - 使用当前用户头像
        Image(this.currentUserAvatar)
          .width(60)
          .height(60)
          .borderRadius(30)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 20 })
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.showUserSwitchDialog = true; // 点击弹出用户切换对话框
      })
      
      // Dove的家 卡片
      Row(){
        Column({ space: 4 }){
          Row({ space: 8 }){
            Image($r('app.media.icon')) // Dove图标
              .width(20)
              .height(20)
            Text('Dove的家')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
          }
          .alignItems(VerticalAlign.Center)
          
          Text('3个成员')
            .fontSize(12)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        
        Row({ space: 8 }){
          Image($r('app.media.user_avtar'))
            .width(32)
            .height(32)
            .borderRadius(16)
          Image($r('app.media.young_avtar'))
            .width(32)
            .height(32)
            .borderRadius(16)
          Image($r('app.media.old_avtar'))
            .width(32)
            .height(32)
            .borderRadius(16)
        }
      }
      .width('90%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 12, left: 20, right: 20 })
      .shadow({
        radius: 8,
        color: '#00000010',
        offsetX: 0,
        offsetY: 2
      })

      
      // 功能列表
      Column(){
        List({ space: 0 }){
          ForEach(MineItemList,(item:InfoItem)=>{
            ListItem(){
              Row(){
                Row({ space: 12 }){
                  Image(item.icon)
                    .width(24)
                    .height(24)
                  Text(item.title)
                    .fontSize(16)
                    .fontColor('#333333')
                }
                .alignItems(VerticalAlign.Center)
                
                Row({ space: 8 }){
                  if(item.title === '家庭网络') {
                    Text('良好')
                      .fontSize(14)
                      .fontColor('#999999')
                  }
                  Image($r('app.media.right'))
                    .width(16)
                    .height(16)
                }
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .height(56)
              .padding({ left: 20, right: 20 })
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Center)
            }
            .backgroundColor(Color.White)
            .border({
              width: { bottom: 0.5 },
              color: '#F0F0F0'
            })
          },(item: InfoItem)=>JSON.stringify(item))
        }
        .backgroundColor(Color.White)
        .borderRadius(12)
        .margin({ top: 20 })
      }
      .width('90%')
      .margin({ left: 20, right: 20 })
      
      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    // 绑定用户切换对话框 - 增加高度和底部边距
    .bindSheet($$this.showUserSwitchDialog, this.UserSwitchDialog(), {
      height: 400, // 从300增加到400
      dragBar: true,
      backgroundColor: Color.White
    })
  }
  
  // 用户切换对话框 - 增加底部边距
  @Builder
  UserSwitchDialog() {
    Column({ space: 20 }) {
      Text('选择用户')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })
      
      // 用户列表
      Column({ space: 16 }) {
        ForEach(this.userList, (user: User) => {
          Row({ space: 12 }) {
            Image(user.avatar)
              .width(50)
              .height(50)
              .borderRadius(25)
            
            Column({ space: 4 }) {
              Text(user.name)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              Text(user.signature)
                .fontSize(12)
                .fontColor('#999999')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            
            if (user.name === this.nickname) {
              Text('当前')
                .fontSize(12)
                .fontColor('#FF6B35')
                .backgroundColor('#FFF2E8')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(12)
            }
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
          .backgroundColor(user.name === this.nickname ? '#FFF8F0' : Color.White)
          .borderRadius(8)
          .onClick(() => {
            this.switchUser(user);
          })
        }, (user: User) => user.id.toString())
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
      
      // 增加底部空白区域，确保内容不被遮挡
      Blank()
        .height(40)
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: 20 }) // 增加底部内边距
  }
}