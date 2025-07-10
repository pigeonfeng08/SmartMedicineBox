@Component
export struct WeatherDetailsCard {
  @Prop title: string = '';
  @Prop value: string = '';
  @Prop icon: Resource = $r('app.media.icon');
  @Prop errorValue: string = '';
  @Prop errorFlagIcon: Resource = $r('app.media.icon');
  @Prop flag: boolean = false;

  build() {
    Column({ space: 8 }) {
      Row({ space: 8 }) {
        Image(this.icon)
          .width(24)
          .height(24)
        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)

      Text(this.value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)

      if (this.flag && this.errorValue) {
        Row({ space: 4 }) {
          Image(this.errorFlagIcon)
            .width(16)
            .height(16)
          Text(this.errorValue)
            .fontSize(12)
            .fontColor(Color.Red)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
    }
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({
      radius: 4,
      color: '#1F000000',
      offsetX: 0,
      offsetY: 2
    })
    .width(100)
    .height(120)
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(HorizontalAlign.Center)
  }
}