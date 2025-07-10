// 定义药品接口
interface Medicine {
  id: number;
  name: string;
  times: string[]; // 修改为数组，支持多个服用时间
  frequency: string;
  location: string; // 新增位置字段
}

// 定义存储位置接口
interface StorageLocation {
  layer: string;
  position: number;
  label: string;
  occupied: boolean;
}

@Component
export struct MedicineManagementComponent {
  editSelectedTime: string | Resource | undefined;
  @State medicineList: Medicine[] = [
    {
      id: 1,
      name: '阿司匹林',
      times: ['08:00'], // 修改为数组
      frequency: '每日一次',
      location: 'A1'
    },
    {
      id: 2,
      name: '维生素C',
      times: ['08:00', '20:00'], // 修改为数组，支持多个时间
      frequency: '每日两次',
      location: 'B1'
    }
  ]
  @State newMedicineName: string = ''
  @State selectedTimes: string[] = ['08:00'] // 修改为数组
  @State selectedFrequency: string = '每日一次'
  @State selectedLocation: string = ''
  @State showAddDialog: boolean = false
  @State frequencyOptions: string[] = ['每日一次', '每日两次', '每日三次', '按需服用']
  // 新增编辑相关状态变量
  @State showEditDialog: boolean = false
  @State editingMedicine: Medicine | null = null
  @State editMedicineName: string = ''
  @State editSelectedTimes: string[] = ['08:00'] // 修改为数组
  @State editSelectedFrequency: string = '每日一次'
  @State editSelectedLocation: string = ''
  @State originalLocation: string = '' // 保存原始位置，用于位置变更时的状态更新
  // 存储位置配置
  @State storageLocations: StorageLocation[] = [
  // A层 - 4格
    {
      layer: 'A',
      position: 1,
      label: 'A1',
      occupied: true
    },
    {
      layer: 'A',
      position: 2,
      label: 'A2',
      occupied: false
    },
    {
      layer: 'A',
      position: 3,
      label: 'A3',
      occupied: false
    },
    {
      layer: 'A',
      position: 4,
      label: 'A4',
      occupied: false
    },
    // B层 - 8格
    {
      layer: 'B',
      position: 1,
      label: 'B1',
      occupied: true
    },
    {
      layer: 'B',
      position: 2,
      label: 'B2',
      occupied: false
    },
    {
      layer: 'B',
      position: 3,
      label: 'B3',
      occupied: false
    },
    {
      layer: 'B',
      position: 4,
      label: 'B4',
      occupied: false
    },
    {
      layer: 'B',
      position: 5,
      label: 'B5',
      occupied: false
    },
    {
      layer: 'B',
      position: 6,
      label: 'B6',
      occupied: false
    },
    {
      layer: 'B',
      position: 7,
      label: 'B7',
      occupied: false
    },
    {
      layer: 'B',
      position: 8,
      label: 'B8',
      occupied: false
    }
  ]

  // 获取可用位置
  getAvailableLocations(): StorageLocation[] {
    return this.storageLocations.filter(location => !location.occupied)
  }

  // 更新位置占用状态
  updateLocationStatus(locationLabel: string, occupied: boolean) {
    const index = this.storageLocations.findIndex(loc => loc.label === locationLabel)
    if (index !== -1) {
      // 创建新的数组来触发UI更新
      const newStorageLocations = [...this.storageLocations]
      // 直接创建新对象，不使用对象扩展运算符
      newStorageLocations[index] = {
        layer: newStorageLocations[index].layer,
        position: newStorageLocations[index].position,
        label: newStorageLocations[index].label,
        occupied: occupied
      }
      this.storageLocations = newStorageLocations
    }
  }

  // 根据频率获取需要的时间数量
  getTimeCountByFrequency(frequency: string): number {
    switch (frequency) {
      case '每日一次':
        return 1;
      case '每日两次':
        return 2;
      case '每日三次':
        return 3;
      case '按需服用':
        return 1;
      default:
        return 1;
    }
  }

  // 更新服用时间数组
  updateTimesArray(times: string[], frequency: string): string[] {
    const requiredCount = this.getTimeCountByFrequency(frequency);
    const newTimes = [...times];
    
    if (newTimes.length > requiredCount) {
      // 如果时间数量超过需要的数量，截取前面的时间
      return newTimes.slice(0, requiredCount);
    } else if (newTimes.length < requiredCount) {
      // 如果时间数量不足，添加默认时间
      const defaultTimes = ['08:00', '12:00', '18:00'];
      while (newTimes.length < requiredCount) {
        const defaultTime = defaultTimes[newTimes.length] || '08:00';
        newTimes.push(defaultTime);
      }
    }
    
    return newTimes;
  }

  // 添加新药品
  addMedicine() {
    console.log('添加药品开始', {
      name: this.newMedicineName,
      location: this.selectedLocation
    })

    if (this.newMedicineName.trim() !== '' && this.selectedLocation !== '') {
      const newMedicine: Medicine = {
        id: Date.now(), // 使用时间戳作为ID，避免重复
        name: this.newMedicineName,
        times: [...this.selectedTimes], // 使用时间数组
        frequency: this.selectedFrequency,
        location: this.selectedLocation
      }

      // 创建新的药品列表数组来触发UI更新
      this.medicineList = [...this.medicineList, newMedicine]

      // 更新位置状态
      this.updateLocationStatus(this.selectedLocation, true)

      // 重置表单
      this.newMedicineName = ''
      this.selectedLocation = ''
      this.selectedTimes = ['08:00']
      this.selectedFrequency = '每日一次'
      this.showAddDialog = false

      console.log('添加药品成功', newMedicine)
    } else {
      console.log('添加药品失败：信息不完整', {
        name: this.newMedicineName,
        location: this.selectedLocation
      })
    }
  }

  // 删除药品
  deleteMedicine(id: number) {
    const medicine = this.medicineList.find(med => med.id === id)
    if (medicine) {
      this.updateLocationStatus(medicine.location, false)
    }
    // 创建新的数组来触发UI更新
    this.medicineList = this.medicineList.filter(medicine => medicine.id !== id)
  }

  // 在这里添加第二部分的编辑相关方法
  // 开始编辑药品
  startEditMedicine(medicine: Medicine) {
    this.editingMedicine = medicine
    this.editMedicineName = medicine.name
    this.editSelectedTimes = [...medicine.times] // 复制时间数组
    this.editSelectedFrequency = medicine.frequency
    this.editSelectedLocation = medicine.location
    this.originalLocation = medicine.location
    this.showAddDialog = true // 触发bindSheet显示
    this.showEditDialog = true
  }

  // 保存编辑的药品
  saveEditMedicine() {
    if (this.editingMedicine && this.editMedicineName.trim() !== '' && this.editSelectedLocation !== '') {
      // 如果位置发生变化，需要更新位置状态
      if (this.originalLocation !== this.editSelectedLocation) {
        // 释放原位置
        this.updateLocationStatus(this.originalLocation, false)
        // 占用新位置
        this.updateLocationStatus(this.editSelectedLocation, true)
      }

      // 更新药品信息
      const updatedMedicine: Medicine = {
        id: this.editingMedicine.id,
        name: this.editMedicineName,
        times: [...this.editSelectedTimes], // 使用时间数组
        frequency: this.editSelectedFrequency,
        location: this.editSelectedLocation
      }

      // 创建新的药品列表数组来触发UI更新
      const index = this.medicineList.findIndex(med => med.id === this.editingMedicine!.id)
      if (index !== -1) {
        const newMedicineList = [...this.medicineList]
        newMedicineList[index] = updatedMedicine
        this.medicineList = newMedicineList
      }

      // 重置编辑状态
      this.resetEditState()
      this.showAddDialog = false
      this.showEditDialog = false

      console.log('编辑药品成功', updatedMedicine)
    } else {
      console.log('编辑药品失败：信息不完整')
    }
  }

  // 取消编辑
  cancelEdit() {
    this.resetEditState()
    this.showAddDialog = false
    this.showEditDialog = false
  }

  // 重置编辑状态
  resetEditState() {
    this.editingMedicine = null
    this.editMedicineName = ''
    this.editSelectedTimes = ['08:00'] // 重置为默认时间数组
    this.editSelectedFrequency = '每日一次'
    this.editSelectedLocation = ''
    this.originalLocation = ''
  }

  resetForm() {
    this.newMedicineName = ''
    this.selectedTimes = ['08:00'] // 重置为默认时间数组
    this.selectedFrequency = '每日一次'
    this.selectedLocation = ''
  }

  build() {
    Column({ space: 12 }) {
      // 标题
      Text('药品管理')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Orange)
        .margin({ top: 10 })

      Divider().width('95%')

      // 搜索框
      Search({ placeholder: '搜索药品名称或位置' })
        .searchButton('搜索')
        .width('95%')
        .height(40)
        .backgroundColor('#F5F5F5')
        .placeholderColor(Color.Grey)
        .placeholderFont({ size: 14, weight: 400 })
        .textFont({ size: 14, weight: 400 })
        .margin({ top: 10, bottom: 10 })

      // 添加药品按钮
      Row() {
        Text('我的药品')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)

        Blank()

        Button('+ 添加药品')
          .fontSize(14)
          .backgroundColor(Color.Orange)
          .fontColor(Color.White)
          .borderRadius(20)
          .padding({
            left: 15,
            right: 15,
            top: 8,
            bottom: 8
          })
          .onClick(() => {
            this.showEditDialog = false // 确保不是编辑模式
            this.showAddDialog = true
          })
      }
      .width('95%')
      .margin({ bottom: 10 })
      .justifyContent(FlexAlign.SpaceBetween)

      // 药品列表
      List({ space: 8 }) {
        ForEach(this.medicineList, (medicine: Medicine) => {
          ListItem() {
            Row() {
              Column({ space: 4 }) {
                Text(medicine.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')

                Text(`服用时间: ${medicine.times.join(', ')}`) // 修改为显示所有时间
                  .fontSize(12)
                  .fontColor('#666666')

                Text(`频次: ${medicine.frequency}`)
                  .fontSize(12)
                  .fontColor('#666666')

                // 新增位置信息显示
                Row({ space: 4 }) {
                  Text('位置:')
                    .fontSize(12)
                    .fontColor('#666666')
                  Text(medicine.location)
                    .fontSize(12)
                    .fontColor('#FF6B35')
                    .fontWeight(FontWeight.Medium)
                    .backgroundColor('#FFF2E8')
                    .padding({
                      left: 6,
                      right: 6,
                      top: 2,
                      bottom: 2
                    })
                    .borderRadius(4)
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Row({ space: 10 }) {
                Button('编辑')
                  .fontSize(12)
                  .backgroundColor('#E8F4FD')
                  .fontColor('#1890FF')
                  .borderRadius(15)
                  .padding({
                    left: 12,
                    right: 12,
                    top: 6,
                    bottom: 6
                  })
                  .onClick(() => {
                    this.startEditMedicine(medicine)
                  })

                Button('删除')
                  .fontSize(12)
                  .backgroundColor('#FFF2F0')
                  .fontColor('#FF4D4F')
                  .borderRadius(15)
                  .padding({
                    left: 12,
                    right: 12,
                    top: 6,
                    bottom: 6
                  })
                  .onClick(() => {
                    this.deleteMedicine(medicine.id)
                  })
              }
            }
            .width('100%')
            .padding(15)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .shadow({
              radius: 2,
              color: '#00000010',
              offsetX: 0,
              offsetY: 1
            })
            .justifyContent(FlexAlign.SpaceBetween)
          }
        })
      }
      .width('95%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f1f2f3')
    .padding({ left: 10, right: 10 })
    .bindSheet($$this.showAddDialog, this.showEditDialog ? this.EditMedicineDialog() : this.AddMedicineDialog(), {
      height: 500,
      dragBar: true,
      backgroundColor: Color.White,
      onDisappear: () => {
        if (this.showEditDialog) {
          this.cancelEdit()
        } else {
          this.resetForm()
        }
        // 确保两个状态都被重置
        this.showAddDialog = false
        this.showEditDialog = false
      }
    })
  }

  // 添加药品对话框
  @Builder
  AddMedicineDialog() {
    Column({ space: 20 }) {
      Text('添加新药品')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      // 药品名称输入
      Column({ space: 8 }) {
        Text('药品名称')
          .fontSize(14)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)

        TextInput({ placeholder: '请输入药品名称' })
          .width('100%')
          .height(40)
          .backgroundColor('#F5F5F5')
          .onChange((value: string) => {
            this.newMedicineName = value
          })
      }
      .width('90%')

      // 服用时间选择
      Column({ space: 8 }) {
        Text('服用时间')
          .fontSize(14)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)

        // 修改为显示多个服用时间
        ForEach(this.selectedTimes, (time: string, index: number) => {
          Row() {
            Text(`第${index + 1}次: ${time}`)
              .fontSize(16)
              .layoutWeight(1)

            Button('选择时间')
              .fontSize(14)
              .backgroundColor(Color.Orange)
              .fontColor(Color.White)
              .borderRadius(20)
              .padding({
                left: 15,
                right: 15,
                top: 8,
                bottom: 8
              })
              .onClick(() => {
                // 时间选择逻辑
                const newTimes = [...this.selectedTimes]
                const timeOptions = ['06:00', '08:00', '12:00', '18:00', '20:00', '22:00']
                const currentIndex = timeOptions.indexOf(time)
                const nextIndex = (currentIndex + 1) % timeOptions.length
                newTimes[index] = timeOptions[nextIndex]
                this.selectedTimes = newTimes
              })
          }
          .width('100%')
          .height(40)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 8 })
        })
      }
      .width('90%')

      // 服用频次选择
      Column({ space: 8 }) {
        Text('服用频次')
          .fontSize(14)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)

        Row() {
          ForEach(this.frequencyOptions, (frequency: string) => {
            Button(frequency)
              .fontSize(12)
              .backgroundColor(this.selectedFrequency === frequency ? Color.Orange : '#F5F5F5')
              .fontColor(this.selectedFrequency === frequency ? Color.White : '#333333')
              .borderRadius(15)
              .padding({
                left: 12,
                right: 12,
                top: 6,
                bottom: 6
              })
              .onClick(() => {
                this.selectedFrequency = frequency
                // 根据频率更新时间数组
                this.selectedTimes = this.updateTimesArray(this.selectedTimes, frequency)
              })
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
      }
      .width('90%')

      // 新增存储位置选择
      Column({ space: 8 }) {
        Text('存储位置')
          .fontSize(14)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)

        // A层位置
        Column({ space: 8 }) {
          Text('A层 (4格)')
            .fontSize(12)
            .fontColor('#666666')
            .alignSelf(ItemAlign.Start)

          Row({ space: 8 }) {
            ForEach(this.storageLocations.filter(loc => loc.layer === 'A'), (location: StorageLocation) => {
              Button(location.label)
                .fontSize(12)
                .backgroundColor(location.occupied ? '#F5F5F5' :
                  (this.selectedLocation === location.label ? Color.Orange : '#E8F4FD'))
                .fontColor(location.occupied ? '#CCCCCC' :
                  (this.selectedLocation === location.label ? Color.White : '#1890FF'))
                .borderRadius(8)
                .padding({
                  left: 12,
                  right: 12,
                  top: 8,
                  bottom: 8
                })
                .enabled(!location.occupied)
                .onClick(() => {
                  if (!location.occupied) {
                    this.selectedLocation = location.label
                  }
                })
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)
        }

        // B层位置
        Column({ space: 8 }) {
          Text('B层 (8格)')
            .fontSize(12)
            .fontColor('#666666')
            .alignSelf(ItemAlign.Start)

          // B层第一行 (B1-B4)
          Row({ space: 8 }) {
            ForEach(this.storageLocations.filter(loc => loc.layer === 'B' && loc.position <= 4),
              (location: StorageLocation) => {
                Button(location.label)
                  .fontSize(12)
                  .backgroundColor(location.occupied ? '#F5F5F5' :
                    (this.selectedLocation === location.label ? Color.Orange : '#E8F4FD'))
                  .fontColor(location.occupied ? '#CCCCCC' :
                    (this.selectedLocation === location.label ? Color.White : '#1890FF'))
                  .borderRadius(8)
                  .padding({
                    left: 12,
                    right: 12,
                    top: 8,
                    bottom: 8
                  })
                  .enabled(!location.occupied)
                  .onClick(() => {
                    if (!location.occupied) {
                      this.selectedLocation = location.label
                    }
                  })
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)

          // B层第二行 (B5-B8)
          Row({ space: 8 }) {
            ForEach(this.storageLocations.filter(loc => loc.layer === 'B' && loc.position > 4),
              (location: StorageLocation) => {
                Button(location.label)
                  .fontSize(12)
                  .backgroundColor(location.occupied ? '#F5F5F5' :
                    (this.selectedLocation === location.label ? Color.Orange : '#E8F4FD'))
                  .fontColor(location.occupied ? '#CCCCCC' :
                    (this.selectedLocation === location.label ? Color.White : '#1890FF'))
                  .borderRadius(8)
                  .padding({
                    left: 12,
                    right: 12,
                    top: 8,
                    bottom: 8
                  })
                  .enabled(!location.occupied)
                  .onClick(() => {
                    if (!location.occupied) {
                      this.selectedLocation = location.label
                    }
                  })
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)
        }
      }
      .width('90%')

      // 操作按钮
      Row({ space: 15 }) {
        Button('取消')
          .fontSize(16)
          .backgroundColor('#F5F5F5')
          .fontColor('#333333')
          .borderRadius(25)
          .layoutWeight(1)
          .height(45)
          .onClick(() => {
            this.showAddDialog = false
            this.newMedicineName = ''
            this.selectedLocation = ''
          })

        Button('确认添加')
          .fontSize(16)
          .backgroundColor(this.selectedLocation !== '' ? Color.Orange : '#CCCCCC')
          .fontColor(Color.White)
          .borderRadius(25)
          .layoutWeight(1)
          .height(45)
          .enabled(this.selectedLocation !== '')
          .onClick(() => {
            this.addMedicine()
          })
      }
      .width('90%')
      .margin({ top: 20, bottom: 20 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 20, topRight: 20 })
  }

  // 编辑药品对话框
  @Builder
  EditMedicineDialog() {
    Column({ space: 20 }) {
      Text('编辑药品信息')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })

      // 药品名称输入
      Column({ space: 8 }) {
        Text('药品名称')
          .fontSize(14)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)

        TextInput({ placeholder: '请输入药品名称', text: this.editMedicineName })
          .width('100%')
          .height(40)
          .backgroundColor('#F5F5F5')
          .onChange((value: string) => {
            this.editMedicineName = value
          })
      }
      .width('90%')

      // 服用时间选择（编辑对话框）
      Column({ space: 8 }) {
        Text('服用时间')
          .fontSize(14)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)

        // 修改为显示多个服用时间
        ForEach(this.editSelectedTimes, (time: string, index: number) => {
          Row() {
            Text(`第${index + 1}次: ${time}`)
              .fontSize(16)
              .layoutWeight(1)

            Button('选择时间')
              .fontSize(14)
              .backgroundColor(Color.Orange)
              .fontColor(Color.White)
              .borderRadius(20)
              .padding({
                left: 15,
                right: 15,
                top: 8,
                bottom: 8
              })
              .onClick(() => {
                // 时间选择逻辑
                const newTimes = [...this.editSelectedTimes]
                const timeOptions = ['06:00', '08:00', '12:00', '18:00', '20:00', '22:00']
                const currentIndex = timeOptions.indexOf(time)
                const nextIndex = (currentIndex + 1) % timeOptions.length
                newTimes[index] = timeOptions[nextIndex]
                this.editSelectedTimes = newTimes
              })
          }
          .width('100%')
          .height(40)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 8 })
        })
      }
      .width('90%')

      // 服用频次选择（编辑对话框）
      Column({ space: 8 }) {
        Text('服用频次')
          .fontSize(14)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)

        Row() {
          ForEach(this.frequencyOptions, (frequency: string) => {
            Button(frequency)
              .fontSize(12)
              .backgroundColor(this.editSelectedFrequency === frequency ? Color.Orange : '#F5F5F5')
              .fontColor(this.editSelectedFrequency === frequency ? Color.White : '#333333')
              .borderRadius(15)
              .padding({
                left: 12,
                right: 12,
                top: 6,
                bottom: 6
              })
              .onClick(() => {
                this.editSelectedFrequency = frequency
                // 根据频率更新时间数组
                this.editSelectedTimes = this.updateTimesArray(this.editSelectedTimes, frequency)
              })
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
      }
      .width('90%')

      // 存储位置选择
      Column({ space: 8 }) {
        Text('存储位置')
          .fontSize(14)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)

        // A层位置
        Column({ space: 8 }) {
          Text('A层 (4格)')
            .fontSize(12)
            .fontColor('#666666')
            .alignSelf(ItemAlign.Start)

          Row({ space: 8 }) {
            ForEach(this.storageLocations.filter(loc => loc.layer === 'A'), (location: StorageLocation) => {
              Button(location.label)
                .fontSize(12)
                .backgroundColor((location.occupied && location.label !== this.originalLocation) ? '#F5F5F5' :
                  (this.editSelectedLocation === location.label ? Color.Orange : '#E8F4FD'))
                .fontColor((location.occupied && location.label !== this.originalLocation) ? '#CCCCCC' :
                  (this.editSelectedLocation === location.label ? Color.White : '#1890FF'))
                .borderRadius(8)
                .padding({
                  left: 12,
                  right: 12,
                  top: 8,
                  bottom: 8
                })
                .enabled(!(location.occupied && location.label !== this.originalLocation))
                .onClick(() => {
                  if (!(location.occupied && location.label !== this.originalLocation)) {
                    this.editSelectedLocation = location.label
                  }
                })
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)
        }

        // B层位置
        Column({ space: 8 }) {
          Text('B层 (8格)')
            .fontSize(12)
            .fontColor('#666666')
            .alignSelf(ItemAlign.Start)

          // B层第一行 (B1-B4)
          Row({ space: 8 }) {
            ForEach(this.storageLocations.filter(loc => loc.layer === 'B' && loc.position <= 4),
              (location: StorageLocation) => {
                Button(location.label)
                  .fontSize(12)
                  .backgroundColor((location.occupied && location.label !== this.originalLocation) ? '#F5F5F5' :
                    (this.editSelectedLocation === location.label ? Color.Orange : '#E8F4FD'))
                  .fontColor((location.occupied && location.label !== this.originalLocation) ? '#CCCCCC' :
                    (this.editSelectedLocation === location.label ? Color.White : '#1890FF'))
                  .borderRadius(8)
                  .padding({
                    left: 12,
                    right: 12,
                    top: 8,
                    bottom: 8
                  })
                  .enabled(!(location.occupied && location.label !== this.originalLocation))
                  .onClick(() => {
                    if (!(location.occupied && location.label !== this.originalLocation)) {
                      this.editSelectedLocation = location.label
                    }
                  })
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)

          // B层第二行 (B5-B8)
          Row({ space: 8 }) {
            ForEach(this.storageLocations.filter(loc => loc.layer === 'B' && loc.position > 4),
              (location: StorageLocation) => {
                Button(location.label)
                  .fontSize(12)
                  .backgroundColor((location.occupied && location.label !== this.originalLocation) ? '#F5F5F5' :
                    (this.editSelectedLocation === location.label ? Color.Orange : '#E8F4FD'))
                  .fontColor((location.occupied && location.label !== this.originalLocation) ? '#CCCCCC' :
                    (this.editSelectedLocation === location.label ? Color.White : '#1890FF'))
                  .borderRadius(8)
                  .padding({
                    left: 12,
                    right: 12,
                    top: 8,
                    bottom: 8
                  })
                  .enabled(!(location.occupied && location.label !== this.originalLocation))
                  .onClick(() => {
                    if (!(location.occupied && location.label !== this.originalLocation)) {
                      this.editSelectedLocation = location.label
                    }
                  })
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceAround)
        }
      }
      .width('90%')

      // 操作按钮
      Row({ space: 15 }) {
        Button('取消')
          .fontSize(16)
          .backgroundColor('#F5F5F5')
          .fontColor('#333333')
          .borderRadius(25)
          .layoutWeight(1)
          .height(45)
          .onClick(() => {
            this.cancelEdit()
          })

        Button('确认修改')
          .fontSize(16)
          .backgroundColor(this.editSelectedLocation !== '' ? Color.Orange : '#CCCCCC')
          .fontColor(Color.White)
          .borderRadius(25)
          .layoutWeight(1)
          .height(45)
          .enabled(this.editSelectedLocation !== '')
          .onClick(() => {
            this.saveEditMedicine()
          })
      }
      .width('90%')
      .margin({ top: 20, bottom: 20 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: 20, topRight: 20 })
  }
}
          