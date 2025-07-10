import router from '@ohos.router'
@Entry
@Component
struct Index {
  @State account: string = ''//账号
  @State password: string = ''//密码

  build() {
    Flex({direction:FlexDirection.Column,alignItems:ItemAlign.Center,justifyContent:FlexAlign.SpaceAround}){
      Text('登陆智能药盒系统')
        .fontSize(24)
        .fontColor(Color.Blue)
        .fontWeight(FontWeight.Bold)
      //用户名和密码
      Column({space:8}){
        TextInput({placeholder:'用户名：'})
          .onChange((value)=>{
            this.account = value;
          })
        TextInput({placeholder:'密码：'}).type(InputType.Password)
          .onChange((value)=>{
            this.password = value;
          })
        Button('登陆')
          .width('95%')
          .margin({top:10})
          .onClick(()=>{//绑定点击事件
            router.pushUrl({
              url:'pages/LoadingPage'//新建的加载页面
            })
          })
        Button('注册')
          .width('95%')
          .backgroundColor(Color.Gray)
          .margin({top:10})
      }
      .width('90%')
    }
    .width('100%')
    .height('100%')
    // .backgroundImage($r('app.media.housebg'))//设置图片背景
    // .backgroundImageSize(ImageSize.Cover)//覆盖背景

  }
}