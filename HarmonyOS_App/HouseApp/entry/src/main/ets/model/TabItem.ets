export interface TabItem {
  icon:Resource;//图标
  icon_selected: Resource;
  title: string;//标题
  id: number;
}
export enum TabID {
  HOURSE,
  SEARCH_DEVICE,
  MINE
}

export const TabItemList: TabItem[] = [
  {
    icon:$r('app.media.house0'),
    icon_selected: $r('app.media.house1'),
    title: '药盒状态',
    id:TabID.HOURSE

  },
  {
    icon:$r('app.media.search0'),
    icon_selected: $r('app.media.search1'),
    title: '药物管理',
    id:TabID.SEARCH_DEVICE

  },
  {
    icon:$r('app.media.mine0'),
    icon_selected: $r('app.media.mine1'),
    title: '我的',
    id:TabID.MINE

  }

]