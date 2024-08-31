
import fs from '@ohos.file.fs';
import axios, { AxiosResponse, FormData } from "@ohos/axios";

let url = ''
let token = ''

export interface detectRes{
  detection_classes: Array<string>
  detection_boxes: Array<Array<number>>,
  detection_scores: Array<number>
}

let cacheDir = getContext(this).cacheDir
let resData:detectRes

export async function detect(img:string): Promise<[number, detectRes]> {
  try {

    const fileName = Date.now() + '.jpg'
    let realUri = cacheDir + "/" + fileName //计划复制到的目标路径
    let file =  fs.openSync(img);
    fs.copyFileSync(file.fd, realUri)

    console.info('detect.upload: pic_url is '+ realUri)

    // // 测试数据
    // resData = JSON.parse(
    //   `{"detection_classes":["Mouse_bite","Mouse_bite","Short","Short","Mouse_bite","Open_circuit","Spurious_copper"],"detection_boxes":[[285,1508,299,1533],[319,927,338,961],[828,1339,843,1352],[766,1639,781,1660],[264,1285,279,1314],[432,2028,453,2042],[1241,1476,1251,1567]],"detection_scores":[0.8756362199783325,0.857711672782898,0.8572907447814941,0.8237062692642212,0.7366687655448914,0.6761752367019653,0.3056696057319641]}`)
    // return [0, resData]

    let formData = new FormData();
    formData.append('images', realUri);

    const res:AxiosResponse<detectRes> = await axios.post(url, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
        'X-Auth-Token': token
      },
    })
    resData = res.data
  } catch (err) {
    console.info('asdasd_err', err)
    return [-1, resData]
  }
  return [0, resData]
}




