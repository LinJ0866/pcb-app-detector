
import { photoPickerGetUri, getPixelMap } from '../common/utils/PictureSaving';
import { detect } from '../common/utils/detect'
import Logger from '../common/utils/Logger';
import { showToast } from '../common/utils/ToastUtils'

@Entry
@Component
export struct debugPage {
  @State isSubmit: boolean = false
  @State isDetect: boolean = false
  @State detectResult: string = ``
  @State preImage: PixelMap = new Object() as PixelMap


  build() {
    NavDestination() {
      Column() {
        Image(this.preImage)
          .alt($r('app.media.pre_image'))
          .width('90%')
          .height(300)
          .autoResize(true)

        Button(){
          Row() {
            if (this.isSubmit) {
              LoadingProgress().width(20).height(20).color(0xFFFFFF)
              Text('检测中').fontSize(12).fontColor(0xffffff)
            } else {
              Text('上传并检测').fontSize(12).fontColor(0xffffff)
            }
          }
        }.onClick(async () => {
          try {
            let uris = await photoPickerGetUri(1)
            if (uris.length == 1) {
              this.isDetect = false

              Logger.info('picPicker: ' + uris[0]);
              this.preImage = await getPixelMap(uris[0]);

              let result = await detect(uris[0])

              this.isSubmit = false;
              if (result[0] != 0) {
                showToast('检测失败，请重试')
                return
              }

              this.isDetect = true
              console.info('detectResults: ', JSON.stringify(result[1]))
              this.detectResult = JSON.stringify(result[1], null, 2)


              showToast(`检测完成，共检测出${result[1].detection_classes.length}个缺陷`)
            } else {
              showToast('请选择1张待检测的PCB图像')
            }
          } catch (err) {
            console.info('asdasd', err)
          }
        })
        .enabled(!this.isSubmit)
        .width(90).height(40).margin({ 'top': 20, 'bottom': 20 })
        .backgroundColor(0x317aff)


        if (this.isDetect) {
          Text('检测结果').margin({'bottom': 15})
            .width('90%')
            .textAlign(TextAlign.Start)
            .font({
              size: 15,
              weight: 700,
              family: 'sans-serif'
            })
          TextArea({text: this.detectResult})
            .height(250).width('90%')
        }

      }.width('100%').height('100%')
    }.title("调试模式")
  }
}