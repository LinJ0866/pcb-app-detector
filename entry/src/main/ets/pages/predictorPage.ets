import { AlbumView } from '../view/AlbumView'
import { detectRecordStruct } from '../viewmodel/resultModel'
import ResultsTable from '../common/database/tables/resultTable'
import dayjs from "@hview/dayjs"
import { photoPickerGetUri } from '../common/utils/PictureSaving';
import { detect, detectUrl, cacheDir } from '../common/utils/detect'
import { SelectDialog } from '@kit.ArkUI'
import { showToast } from '../common/utils/ToastUtils'
import { taskpool, uri } from '@kit.ArkTS';

@Component
export struct predictorPage {
  @State defectCount: number = 0
  @State allCount: number = 0
  @State isStart: boolean = false

  @State detectUrl:string = detectUrl
  @State cacheDir:string = cacheDir

  @State dateList: string[] = []
  @State photoArr:Map<string, detectRecordStruct[]> = new Map<string, detectRecordStruct[]>()
  @Consume('pageInfos') pageInfos: NavPathStack;
  private resultsTable = new ResultsTable();

  radioIndex = 0;
  dialogControllerList: CustomDialogController = new CustomDialogController({
    builder: SelectDialog({
      title: '检测到缺陷后应对策略',
      selectedIndex: this.radioIndex,
      confirm: {
        value: '取消',
        action: () => {},
      },
      radioContent: [
        {
          title: '停止检测并报警',
          action: () => {
            this.radioIndex = 0
          }
        },
        {
          title: '继续检测(多线程并行)',
          action: () => {
            this.radioIndex = 1
          }
        },
        {
          title: '继续检测(单线程串行)',
          action: () => {
            this.radioIndex = 2
          }
        },
      ]
    }),
  })

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Text('今日')
            .width('90%')
            .textAlign(TextAlign.Center)
            .font({
              size: 20,
              weight: 700,
              family: 'sans-serif'
            })
          Text(`${this.defectCount} / ${this.allCount}`)
            .margin({ 'top': 15, 'bottom': 15 })
            .width('90%')
            .textAlign(TextAlign.Center)
            .font({
              size: 40,
              weight: 700,
              family: 'sans-serif'
            })

          Button(this.isStart ? '检测中': '开始', { type: ButtonType.Circle, stateEffect: true })
            .width(150)
            .fontSize(30)
            .enabled(!this.isStart)
            .onClick(async() => {
              let uris = await photoPickerGetUri(10)
              let count = 0
              let successDetect = 0
              this.isStart = true

              if (this.radioIndex == 1) {
                // 多线程
                let number: number = Math.floor(uris.length / 2);

                for (let i = 0; i < number; i++) {
                  let group: taskpool.TaskGroup = new taskpool.TaskGroup();
                  group.addTask(await detect, uris[i], this.detectUrl, this.cacheDir);
                  group.addTask(await detect, uris[number+i], this.detectUrl, this.cacheDir);

                  let ret = await taskpool.execute(group, taskpool.Priority.HIGH)
                  let results = ret as [number, detectRecordStruct][]
                  for (let i = 0; i<2; i++) {
                    if (results[i][0] == 0) {
                      successDetect += 1
                      this.addResult(results[i][1])
                      if (results[i][1].detect_count > 0) {
                        count += 1
                      }
                    } else {
                      showToast("检测失败")
                    }
                  }
                }
                // 奇数
                if (uris.length % 2) {
                  let result = await detect(uris[-1], this.detectUrl, this.cacheDir)
                  if (result[0] == 0) {
                    successDetect += 1
                    this.addResult(result[1])
                    if (result[1].detect_count > 0) {
                      count += 1
                    }
                  } else {
                    showToast("检测失败")
                  }
                }
              } else if (this.radioIndex == 2) {
                // 单线程串行预测
                for (let i = 0; i < uris.length; i++) {
                  let result = await detect(uris[i], this.detectUrl, this.cacheDir)
                  if (result[0] == 0) {
                    successDetect += 1
                    this.addResult(result[1])
                    if (result[1].detect_count > 0) {
                      count += 1
                    }
                  } else {
                    showToast("检测失败")
                  }
                }
              } else {
                // 遇到报错停止
                for (let i = 0; i < uris.length; i++) {
                  let result = await detect(uris[i], this.detectUrl, this.cacheDir)
                  if (result[0] == 0) {
                    successDetect += 1
                    this.addResult(result[1])
                    if (result[1].detect_count > 0) {
                      AlertDialog.show(
                        {
                          title: '检测已中止',
                          message: `检测到${result[1].detect_count}处缺陷，请注意查看`,
                          autoCancel: true,
                          alignment: DialogAlignment.Bottom,
                          offset: { dx: 0, dy: -20 },
                          gridCount: 3,
                          confirm: {
                            value: '我知道了',
                            action: () => {
                              console.info('Button-clicking callback')
                            }
                          }
                        }
                      )
                      this.isStart = false
                      break
                    }
                  } else {
                    showToast("检测失败")
                  }
                }
              }

              // 结束
              if (successDetect > 0 && this.isStart) {
                AlertDialog.show(
                  {
                    title: '检测完成',
                    message: `共检测${uris.length}块电路板，其中${count}张存在缺陷，请注意查看`,
                    autoCancel: true,
                    alignment: DialogAlignment.Bottom,
                    offset: { dx: 0, dy: -20 },
                    gridCount: 3,
                    confirm: {
                      value: '我知道了',
                      action: () => {
                        console.info('Button-clicking callback')
                      }
                    }
                  })
              }
              this.isStart = false
            })
          if (!this.isStart) {
            Button('设置', { buttonStyle: ButtonStyleMode.NORMAL })
              .margin({ 'top': 15 })
              .enabled(!this.isStart)
              .onClick(() => {
                this.dialogControllerList.open()
              })
          }

          ForEach(this.dateList, (item:string, index) => {
            AlbumView({
              dateTime: item,
              records: this.photoArr[item]
            })
          })

        }.width('100%')
      }

    }.title("缺陷检测")
      .onBackPressed(() => {
        const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
        console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
        return true
      })
    .backgroundColor($r('app.color.start_window_background'))

  }

  async aboutToAppear() {
    await this.resultsTable.getRdbStore()
    let res = await this.resultsTable.query()
    this.dateList = res[0]
    this.photoArr = res[1]

    this.updateCount()
  }
  updateCount() {
    let today_str =dayjs().format('YYYY年MM月DD日')
    if (this.dateList.indexOf(today_str) != -1) {
      this.allCount = this.photoArr[today_str].length
      this.defectCount = 0
      for(let i=0; i<this.allCount; i++) {
        if (this.photoArr[today_str][i].detect_count > 0) {
          this.defectCount += 1
        }
      }
    }
  }

  // async detectUris(uris: string[]): void {
  //   for (let i = 0; i < uris.length; i++) {
  //     detectAndRecord(uris[i])
  //     this.add
  //   }
  //   let number: number = uris.length / 2;
  //   let uris1: string[] = uris.slice(0, number);
  //   let uris2: string[] = uris.slice(number, -1);
  //
  //   let group: taskpool.TaskGroup = new taskpool.TaskGroup();
  //   group.addTask(imageProcessing, buffer1);
  //   group.addTask(imageProcessing, buffer2);
  //   group.addTask(imageProcessing, buffer3);
  //
  //   taskpool.execute(group, taskpool.Priority.HIGH).then((ret: Object) => {
  //     // 步骤3: 结果数组汇总处理
  //   })
  // }

  async addResult(dataSample: detectRecordStruct) {
    await this.resultsTable.getRdbStore()
    await this.resultsTable.insertData(dataSample);

    dataSample.date = dayjs(dataSample.date)
      .format('YYYY年MM月DD日 HH:mm:ss')

    let today_str =dayjs().format('YYYY年MM月DD日')
    if (this.dateList.indexOf(today_str) != -1) {
      let list_tmp:detectRecordStruct[] = Array.from(this.photoArr[today_str])
      list_tmp.push(dataSample)
      this.photoArr[today_str] = list_tmp
    } else {
      this.dateList.push(today_str)
      this.dateList.sort((a: string, b: string) => b.localeCompare(a))
      this.photoArr[today_str] = [dataSample]
    }

    this.updateCount()
  }


}