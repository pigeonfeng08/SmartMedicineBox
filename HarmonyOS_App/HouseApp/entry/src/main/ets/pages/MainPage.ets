import { TabID, TabItemList } from '../model/TabItem';
import { MedicineManagementComponent } from '../view/DeviceSearchComponent';
import HouseStateComponent from '../view/HouseStateComponent';
import { MineComponent } from '../view/MineComponent';
@Entry
@Component
struct MainPage {
  @State pageIndex: number = 0;//页面索引
  private tabController: TabsController = new TabsController();//tab切换控制器

  build() {

    Tabs({barPosition:BarPosition.End}){

      TabContent(){
        //Text('小屋状态')
        HouseStateComponent()//调用小屋状态组件
      }
      //.tabBar('小屋状态')
      .tabBar(this.MyTabBuilder(TabID.HOURSE))//调用自定义的TabBar

      TabContent(){
        //Text('药品管理')
        MedicineManagementComponent()//调用药品管理组件
      }
      //.tabBar('搜索设备')
      .tabBar(this.MyTabBuilder(TabID.SEARCH_DEVICE))//调用自定义的TabBar

      TabContent(){
        //Text('我的')
        MineComponent()//个人主页
      }
      //.tabBar('我的')
      .tabBar(this.MyTabBuilder(TabID.MINE))//调用自定义的TabBar

    }
    .barWidth('100%')
    .barMode(BarMode.Fixed)
    .width('100%')
    .height('100%')
    .onChange((index)=>{//绑定onChange函数切换页签
      this.pageIndex = index;
    })

  }

  @Builder MyTabBuilder(idx: number){
    Column(){
      Image(idx === this.pageIndex ? TabItemList[idx].icon_selected : TabItemList[idx].icon)
        .width(32)
        .height(32)
      Text(TabItemList[idx].title)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.pageIndex === idx ? '#006eee':'#888')
    }
  }


}

