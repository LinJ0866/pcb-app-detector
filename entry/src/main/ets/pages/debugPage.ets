import { LengthMetricsUnit } from '@kit.ArkUI'
import image from '@ohos.multimedia.image';
import { photoPickerGetUri, getPixelMap, copyPixelMap } from '../common/utils/PictureSaving';
import { detect, detectRes, parseResult, detectUrl, cacheDir } from '../common/utils/detect'
import Logger from '../common/utils/Logger';
import { showToast } from '../common/utils/ToastUtils'

@Component
export struct debugPage {
  @State isSubmit: boolean = false
  @State isDetect: boolean = false
  @State detectResult: string = ``
  @State preImage: PixelMap = new Object() as PixelMap
  @State showImage: PixelMap = new Object() as PixelMap
  // @State detectedImage: PixelMap = new Object() as PixelMap
  @State image_w: number = 0
  @State image_h: number = 0
  @State image_x: number = 0
  @State image_y: number = 0
  @State imageScale: number = 0

  @State detectUrl:string = detectUrl
  @State cacheDir:string = cacheDir

  @Consume('pageInfos') pageInfos: NavPathStack;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  // private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  // private contextPX: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings, LengthMetricsUnit.PX);
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.All })

  build() {
    NavDestination() {
      Column() {
        Image(this.showImage)
          .alt($r('app.media.pre_image'))
          .width('90%')
          .height(300)
          .autoResize(true)
          .gesture(
            PanGesture(this.panOption)
              .onActionUpdate((event: GestureEvent) => {
                if (event) {
                  this.image_x = this.image_x - Math.round(event.offsetX / 6)
                  this.image_y = this.image_y - Math.round(event.offsetY / 6)

                  let h = this.image_h-Math.round(this.image_h*this.imageScale/100)
                  let w = this.image_w-Math.round(this.image_w*this.imageScale/100)

                  if (this.image_x + w / 2 > this.image_w) {
                    this.image_x = this.image_w - Math.round(w/2)
                  } else if (this.image_x - w / 2 < 0 ) {
                    this.image_x = Math.round(w/2)
                  }
                  if (this.image_y + h / 2 > this.image_h) {
                    this.image_y = this.image_h - Math.round(h/2)
                  } else if (this.image_y - h / 2 < 0) {
                    this.image_y = Math.round(h/2)
                  }

                  this.updateShow()
                }
              })
          )

        // Canvas(this.contextPX)
        //   .backgroundImage(this.preImage, ImageRepeat.NoRepeat)
        //   .backgroundImageSize(ImageSize.Contain)
        //   .width('90%')
        //   .height(300)

        Row() {
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
                this.imageScale = 0
                this.image_w = this.preImage.getImageInfoSync().size.width
                this.image_h = this.preImage.getImageInfoSync().size.height
                this.image_x = Math.round(this.image_w / 2)
                this.image_y = Math.round(this.image_h / 2)
                Logger.info(`picPicker.oriImage width and height: ${this.image_w}, ${this.image_h}`);

                this.updateShow()

                this.isSubmit = true;
                let result = await detect(uris[0], this.detectUrl, this.cacheDir)

                this.isSubmit = false;
                if (result[0] != 0) {
                  showToast('检测失败，请重试')
                  return
                }

                this.isDetect = true
                console.info('detectResults: ', result[1].result)
                const res: detectRes = JSON.parse(result[1].result)
                this.detectResult = parseResult(res)

                this.bboxDrawer(res)
                this.updateShow()

                showToast(`检测完成，共检测出${result[1].detect_count}个缺陷`)
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

          Slider({
            value: this.imageScale,
            step: 1,
            min: 0,
            max: 100
          })
            .trackColor(Color.White)
            .width(150)
            .margin({ 'left': 20 })
            .showSteps(true)
            .onChange((value: number, mode: SliderChangeMode) => {
              this.sliderChange(value > 100 ? 100 : value, mode);
            })
            .enabled(this.isDetect || this.isSubmit)

          Text(`${100+this.imageScale}%`)
        }

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
    .onBackPressed(() => {
      const popDestinationInfo = this.pageInfos.pop() // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })
  }
  bboxDrawer(result: detectRes) {
    console.info('detectDrawer: start.')
    let offContext: OffscreenCanvasRenderingContext2D = new OffscreenCanvasRenderingContext2D(
      this.image_w, this.image_h,
      this.settings, LengthMetricsUnit.PX
    )

    offContext.setPixelMap(this.preImage)
    offContext.font = '30px 700 sans-serif'
    offContext.lineWidth = 4
    offContext.strokeStyle = 'rgb(0, 255, 0)'
    offContext.fillStyle = '#ffffff'

    for (let i = 0; i < result.detection_classes.length; i++) {
      let bbox = result.detection_boxes[i]
      offContext.strokeRect(bbox[1], bbox[0], bbox[3]-bbox[1], bbox[2]-bbox[0])
      offContext.fillText(`${result.detection_classes[i]} (${result.detection_scores[i].toFixed(2)})`, bbox[1], bbox[2]+30)
      console.info('detectDrawer: ', result.detection_boxes[i])
    }
    this.preImage = offContext.getPixelMap(0, 0, this.image_w, this.image_h)
  }
  async sliderChange(value: number, mode: SliderChangeMode) {
    try {
      if (this.isSubmit || this.isDetect) {
        this.imageScale = Math.round(value);

        this.updateShow()
      }
    } catch (e) {
      console.info("asdasd111_e: ", e)
    }

  }
  async updateShow() {
    let h = this.image_h-Math.round(this.image_h*this.imageScale/100)
    let w = this.image_w-Math.round(this.image_w*this.imageScale/100)

    if (this.image_x + w / 2 > this.image_w) {
      this.image_x = this.image_w - Math.round(w/2)
    } else if (this.image_x - w / 2 < 0 ) {
      this.image_x = Math.round(w/2)
    }
    if (this.image_y + h / 2 > this.image_h) {
      this.image_y = this.image_h - Math.round(h/2)
    } else if (this.image_y - h / 2 < 0) {
      this.image_y = Math.round(h/2)
    }

    let region : image.Region = {
      x: this.image_x-Math.round(w/2),
      y: this.image_y-Math.round(h/2),
      size: {
        height: h,
        width: w
      }
    };
    let img_tmp = await copyPixelMap(this.preImage)
    img_tmp.cropSync(region)

    this.showImage = img_tmp
  }
}