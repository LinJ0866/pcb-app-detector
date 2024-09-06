/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import fs from '@ohos.file.fs'
import image from '@ohos.multimedia.image';
import { picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';

// Defines a URI array, which is used to receive the URI returned by PhotoViewPicker for selecting images.
let uris: Array<string> = [];
let img: PixelMap;

/**
 * photoPickerGetUri.
 * Returns the URI of the selected file based on the select method of PhotoViewPicker.
 * @return Promise<string>.
 */
export async function photoPickerGetUri(maxNum:number = 1): Promise<Array<string>> {
  try {
    let PhotoSelectOptions = new picker.PhotoSelectOptions();
    PhotoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
    PhotoSelectOptions.maxSelectNumber = maxNum;
    let photoPicker = new picker.PhotoViewPicker();
    await photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult: picker.PhotoSelectResult) => {
      Logger.info('PhotoViewPicker.select successfully, PhotoSelectResult uri: ' + JSON.stringify(PhotoSelectResult));
      uris = PhotoSelectResult.photoUris;
    }).catch((err: BusinessError) => {
      Logger.error('PhotoViewPicker.select failed with err: ' + JSON.stringify(err));
    });
  } catch (error) {
    let err = error as BusinessError;
    Logger.error('PhotoViewPicker failed with err: ' + err.message);
  }
  Logger.info('PhotoViewPicker' + uris[0]);
  // await getPixelMap(uris)

  return uris
}

// 定义获取图片pixelmap的函数
export async function getPixelMap(uri:string): Promise<PixelMap> {
  try {
    // 通过uri打开图片文件，获取文件fd
    let file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
    const imageSourceApi = image.createImageSource(file.fd);

    img = await imageSourceApi.createPixelMap()
    img = await copyPixelMap(img)
  } catch(e) {
    Logger.error('PhotoViewPicker.getPixelMap failed with err: ' + JSON.stringify(e));
  }

  return img;
}


export async function copyPixelMap(pm: PixelMap): Promise<PixelMap> {
  const imageInfo: image.ImageInfo = await pm.getImageInfo();
  const buffer: ArrayBuffer = new ArrayBuffer(pm.getPixelBytesNumber());
  // TODO 知识点：通过readPixelsToBuffer实现PixelMap的深拷贝，其中readPixelsToBuffer输出为BGRA_8888
  await pm.readPixelsToBuffer(buffer);
  // TODO 知识点：readPixelsToBuffer输出为BGRA_8888,此处createPixelMap需转为RGBA_8888
  const opts: image.InitializationOptions = {
    editable: true,
    pixelFormat: image.PixelMapFormat.RGBA_8888,
    size: { height: imageInfo.size.height, width: imageInfo.size.width }
  };
  return await image.createPixelMap(buffer, opts);
}
