// import image from '@ohos.multimedia.image';
// import { copyPixelMap } from '../common/utils/PictureSaving';
//
// @Component
// export struct imageViewer {
//   public showImage: PixelMap = new Object() as PixelMap
//
//   @State image_w: number = 0
//   @State image_h: number = 0
//   @State image_x: number = 0
//   @State image_y: number = 0
//   @State imageScale: number = 0
//   private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.All })
//
//   build() {
//     Image(this.showImage)
//       .alt($r('app.media.pre_image'))
//       .autoResize(true)
//       .gesture(
//         PanGesture(this.panOption)
//           .onActionUpdate((event: GestureEvent) => {
//             if (event) {
//               this.image_x = this.image_x - Math.round(event.offsetX / 6)
//               this.image_y = this.image_y - Math.round(event.offsetY / 6)
//
//               let h = this.image_h-Math.round(this.image_h*this.imageScale/100)
//               let w = this.image_w-Math.round(this.image_w*this.imageScale/100)
//
//               if (this.image_x + w / 2 > this.image_w) {
//                 this.image_x = this.image_w - Math.round(w/2)
//               } else if (this.image_x - w / 2 < 0 ) {
//                 this.image_x = Math.round(w/2)
//               }
//               if (this.image_y + h / 2 > this.image_h) {
//                 this.image_y = this.image_h - Math.round(h/2)
//               } else if (this.image_y - h / 2 < 0) {
//                 this.image_y = Math.round(h/2)
//               }
//
//               this.updateShow()
//             }
//           })
//       )
//   }
//
//   async updateShow() {
//     let h = this.image_h-Math.round(this.image_h*this.imageScale/100)
//     let w = this.image_w-Math.round(this.image_w*this.imageScale/100)
//
//     if (this.image_x + w / 2 > this.image_w) {
//       this.image_x = this.image_w - Math.round(w/2)
//     } else if (this.image_x - w / 2 < 0 ) {
//       this.image_x = Math.round(w/2)
//     }
//     if (this.image_y + h / 2 > this.image_h) {
//       this.image_y = this.image_h - Math.round(h/2)
//     } else if (this.image_y - h / 2 < 0) {
//       this.image_y = Math.round(h/2)
//     }
//
//     let region : image.Region = {
//       x: this.image_x-Math.round(w/2),
//       y: this.image_y-Math.round(h/2),
//       size: {
//         height: h,
//         width: w
//       }
//     };
//     let img_tmp = await copyPixelMap(this.preImage)
//     img_tmp.cropSync(region)
//
//     this.showImage = img_tmp
//   }
//
// }