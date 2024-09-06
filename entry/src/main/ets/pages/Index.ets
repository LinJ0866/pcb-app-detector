import { debugPage } from './debugPage'
import { predictorPage } from './predictorPage'

interface btnItemStruct {
  name: string,
  uri: string
}

@Entry
@Component
struct Index {
  // 创建一个页面栈对象并传入Navigation
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()

  @State btnList: btnItemStruct[] = [
    {
      name: '缺陷检测',
      uri: 'NavPredictorPage'
    },
    {
      name: '调试模式',
      uri: 'NavDebugPage'
    },
  ]

  @Builder
  PageMap(name: string) {
    if (name === "NavDebugPage") {
      debugPage()
    } else if (name == "NavPredictorPage") {
      predictorPage()
    }
  }

  build() {
    Column() {
      Navigation(this.pageInfos){
        ForEach(this.btnList, (item:btnItemStruct) => {
          Button(item.name, {type: ButtonType.Normal}).onClick(() => {
            this.pageInfos.pushPath({ name: item.uri})
          }).width('90%')
            .borderRadius(16)
            .height(60)
            .fontColor('#000000')
            .backgroundColor('#ffffff')
            .margin({top: 20})
        })

      }.title("PCB缺陷检测")
        .navDestination(this.PageMap)
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F1F3F5')
  }
}

