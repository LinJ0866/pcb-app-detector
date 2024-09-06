import { fileUri } from '@kit.CoreFileKit';
import { LengthMetricsUnit } from '@kit.ArkUI'
import image from '@ohos.multimedia.image';
import { getPixelMap, copyPixelMap } from '../common/utils/PictureSaving';
import { detectRes, parseResult } from '../common/utils/detect'
import { detectRecordStruct } from '../viewmodel/resultModel'

@Component
export struct AlbumView {
  public dateTime:string = ''
  @Prop records: detectRecordStruct[]

  @State isShow: Array<boolean> = new Array<boolean>(this.records.length).fill(false);
  @State detectResult: string = ``
  @State preImage: PixelMap = new Object() as PixelMap
  @State showImage: PixelMap = new Object() as PixelMap
  // @State detectedImage: PixelMap = new Object() as PixelMap
  @State image_w: number = 0
  @State image_h: number = 0
  @State image_x: number = 0
  @State image_y: number = 0
  @State imageScale: number = 0

  @Consume('pageInfos') pageInfos: NavPathStack;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.All })
  @Builder myBuilder() {
    Column(){
      Image(this.showImage)
        .alt($r('app.media.loading'))
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

      Row() {
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

        Text(`${100+this.imageScale}%`)
      }

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
    .padding( {'bottom': 30 })
  }

  // build
  build() {
    Column() {
      Text(this.dateTime)
        .width('90%')
        .textAlign(TextAlign.Start)
        .margin({ top: 15 })
      Grid() {
        ForEach(this.records, (item: detectRecordStruct, idx) => {
          GridItem() {
            Badge({
              count: item.detect_count,
              style: {},
              position: BadgePosition.RightTop,
            }) {
              Image(fileUri.getUriFromPath(item.resource_uri))
                .alt($r('app.media.loading'))
                .height('100%')
                .width('100%')
                .objectFit(ImageFit.Cover)
                .onClick(async() => {
                  console.info('asdasd', JSON.stringify(item))
                  this.preImage = await getPixelMap(fileUri.getUriFromPath(item.resource_uri));
                  this.imageScale = 0
                  this.image_w = this.preImage.getImageInfoSync().size.width
                  this.image_h = this.preImage.getImageInfoSync().size.height
                  this.image_x = Math.round(this.image_w / 2)
                  this.image_y = Math.round(this.image_h / 2)

                  if (item.status === 0) {
                    const res: detectRes = JSON.parse(item.result)
                    this.detectResult =parseResult(res)
                    this.bboxDrawer(res)
                  } else {
                    this.detectResult = '无缺陷'
                    this.updateShow()
                  }

                  this.isShow[idx] = true;
                })
                .bindSheet(this.isShow[idx], this.myBuilder(),{
                  detents:[SheetSize.FIT_CONTENT, SheetSize.LARGE],
                  backgroundColor:Color.Gray,
                  blurStyle:BlurStyle.Thick,
                  showClose:true,
                  onDisappear: () => {
                    this.isShow[idx] = false;
                  },
                  title:{title:"检测详情", subtitle:item.date},
                })
            }
            .margin({ right: 8 })
          }
          .padding( { top: 6 } )
          .width('100%')
          .aspectRatio(1)
        })
      }
      .scrollBar(BarState.Off)
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .rowsGap(2)
      .columnsGap(2)
      .layoutWeight(0)
    }
    .width('100%')
  }

  // Todo: 总有一天会把底下的组件封装的
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
    this.updateShow()
  }
  async sliderChange(value: number, mode: SliderChangeMode) {
    try {
      this.imageScale = Math.round(value);
      this.updateShow()
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