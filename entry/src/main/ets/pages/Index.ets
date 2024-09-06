import { debugPage } from './debugPage'
import { predictorPage } from './predictorPage'

interface btnItemStruct {
  name: string,
  uri: string,
  picUrl: Resource
}

@Entry
@Component
struct Index {
  // 创建一个页面栈对象并传入Navigation
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()

  @State btnList: btnItemStruct[] = [
    {
      name: '缺陷检测',
      uri: 'NavPredictorPage',
      picUrl: $r('app.media.btn1')
    },
    {
      name: '调试模式',
      uri: 'NavDebugPage',
      picUrl: $r('app.media.btn2')
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
          Row()
            .backgroundImage(item.picUrl)
            .backgroundImageSize(ImageSize.Cover)
            .height(110)
            .margin({top: 20})
            .width("90%")
            .borderRadius(32)
            .onClick(() => {
              this.pageInfos.pushPath({ name: item.uri})
            })
        })

      }.title("PCB缺陷检测")
        .navDestination(this.PageMap)
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#ffffff')
  }
}

