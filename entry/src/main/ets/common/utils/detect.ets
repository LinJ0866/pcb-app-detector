
import fs from '@ohos.file.fs';
import axios, { AxiosResponse, FormData } from "@ohos/axios";
import { detectRecordStruct } from '../../viewmodel/resultModel';

export let detectUrl = 'http://pcb-api.rubbishman.xyz/detect/infer'
export let cacheDir = getContext(this).cacheDir
// let token = 'MIIN9gYJKoZIhvcNAQcCoIIN5zCCDeMCAQExDTALBglghkgBZQMEAgEwggwIBgkqhkiG9w0BBwGgggv5BIIL9XsidG9rZW4iOnsiZXhwaXJlc19hdCI6IjIwMjQtMDktMDRUMDE6NDA6MTcuOTk4MDAwWiIsIm1ldGhvZHMiOlsicGFzc3dvcmQiXSwiY2F0YWxvZyI6W10sInJvbGVzIjpbeyJuYW1lIjoidGVfYWRtaW4iLCJpZCI6IjAifSx7Im5hbWUiOiJ0ZV9hZ2VuY3kiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9jc2JzX3JlcF9hY2NlbGVyYXRpb24iLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9lY3NfZGlza0FjYyIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX2Rzc19tb250aCIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX29ic19kZWVwX2FyY2hpdmUiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9hX2NuLXNvdXRoLTRjIiwiaWQiOiIwIn0seyJuYW1lIjoib3BfZ2F0ZWRfZGVjX21vbnRoX3VzZXIiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9jYnJfc2VsbG91dCIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX2Vjc19vbGRfcmVvdXJjZSIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX3Bhbmd1IiwiaWQiOiIwIn0seyJuYW1lIjoib3BfZ2F0ZWRfd2VsaW5rYnJpZGdlX2VuZHBvaW50X2J1eSIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX2Nicl9maWxlIiwiaWQiOiIwIn0seyJuYW1lIjoib3BfZ2F0ZWRfZG1zLXJvY2tldG1xNS1iYXNpYyIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX2Rtcy1rYWZrYTMiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9lZGdlc2VjX29idCIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX29ic19kZWNfbW9udGgiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9jc2JzX3Jlc3RvcmUiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9pZG1lX21ibV9mb3VuZGF0aW9uIiwiaWQiOiIwIn0seyJuYW1lIjoib3BfZ2F0ZWRfZWNzX2M2YSIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX211bHRpX2JpbmQiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9zbW5fY2FsbG5vdGlmeSIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX2FfYXAtc291dGhlYXN0LTNkIiwiaWQiOiIwIn0seyJuYW1lIjoib3BfZ2F0ZWRfY3Nic19wcm9ncmVzc2JhciIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX2Nlc19yZXNvdXJjZWdyb3VwX3RhZyIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX2Vjc19vZmZsaW5lX2FjNyIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX2V2c19yZXR5cGUiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9rb29tYXAiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9ldnNfZXNzZDIiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9kbXMtYW1xcC1iYXNpYyIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX2V2c19wb29sX2NhIiwiaWQiOiIwIn0seyJuYW1lIjoib3BfZ2F0ZWRfYV9jbi1zb3V0aHdlc3QtMmIiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9od2NwaCIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX2Vjc19vZmZsaW5lX2Rpc2tfNCIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX2h3ZGV2IiwiaWQiOiIwIn0seyJuYW1lIjoib3BfZ2F0ZWRfc21uX3dlbGlua3JlZCIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX2NjZV9hdXRvcGlsb3QiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9odl92ZW5kb3IiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9hX2NuLW5vcnRoLTRlIiwiaWQiOiIwIn0seyJuYW1lIjoib3BfZ2F0ZWRfYV9jbi1ub3J0aC00ZCIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX2Vjc19oZWNzX3giLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9lY3NfYWM3IiwiaWQiOiIwIn0seyJuYW1lIjoib3BfZ2F0ZWRfZXBzIiwiaWQiOiIwIn0seyJuYW1lIjoib3BfZ2F0ZWRfY3Nic19yZXN0b3JlX2FsbCIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX2FfY24tbm9ydGgtNGYiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9vY3RvcHVzIiwiaWQiOiIwIn0seyJuYW1lIjoib3BfZ2F0ZWRfb3BfZ2F0ZWRfcm91bmR0YWJsZSIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX2V2c19leHQiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9wZnNfZGVlcF9hcmNoaXZlIiwiaWQiOiIwIn0seyJuYW1lIjoib3BfZ2F0ZWRfYV9hcC1zb3V0aGVhc3QtMWUiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9hX3J1LW1vc2Nvdy0xYiIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX2FfYXAtc291dGhlYXN0LTFkIiwiaWQiOiIwIn0seyJuYW1lIjoib3BfZ2F0ZWRfYXBwc3RhZ2UiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9hX2FwLXNvdXRoZWFzdC0xZiIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX3Ntbl9hcHBsaWNhdGlvbiIsImlkIjoiMCJ9LHsibmFtZSI6Im9wX2dhdGVkX2V2c19jb2xkIiwiaWQiOiIwIn0seyJuYW1lIjoib3BfZ2F0ZWRfcmRzX2NhIiwiaWQiOiIwIn0seyJuYW1lIjoib3BfZ2F0ZWRfZWNzX2dwdV9nNXIiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9vcF9nYXRlZF9tZXNzYWdlb3ZlcjVnIiwiaWQiOiIwIn0seyJuYW1lIjoib3BfZ2F0ZWRfZWNzX3JpIiwiaWQiOiIwIn0seyJuYW1lIjoib3BfZ2F0ZWRfYV9ydS1ub3J0aHdlc3QtMmMiLCJpZCI6IjAifSx7Im5hbWUiOiJvcF9nYXRlZF9pZWZfcGxhdGludW0iLCJpZCI6IjAifV0sInByb2plY3QiOnsiZG9tYWluIjp7Im5hbWUiOiJsaW5fajA4NjYiLCJpZCI6IjQyZjM1NzE1MmJiZDQ0M2U4NDdkZWJhZmNmNmNhNzAzIn0sIm5hbWUiOiJjbi1zb3V0aHdlc3QtMiIsImlkIjoiMGVlM2U2NzYwNTgwZjJmNjJmMmRjMDA2ZTkwODk0OGMifSwiaXNzdWVkX2F0IjoiMjAyNC0wOS0wM1QwMTo0MDoxNy45OTgwMDBaIiwidXNlciI6eyJkb21haW4iOnsibmFtZSI6Imxpbl9qMDg2NiIsImlkIjoiNDJmMzU3MTUyYmJkNDQzZTg0N2RlYmFmY2Y2Y2E3MDMifSwibmFtZSI6ImxpbmoiLCJwYXNzd29yZF9leHBpcmVzX2F0IjoiIiwiaWQiOiI1MGU1NTk4NGQ2YzM0MjU4YjNjNTc5ODBmYTYyMzMwYSJ9fX0xggHBMIIBvQIBATCBlzCBiTELMAkGA1UEBhMCQ04xEjAQBgNVBAgMCUd1YW5nRG9uZzERMA8GA1UEBwwIU2hlblpoZW4xLjAsBgNVBAoMJUh1YXdlaSBTb2Z0d2FyZSBUZWNobm9sb2dpZXMgQ28uLCBMdGQxDjAMBgNVBAsMBUNsb3VkMRMwEQYDVQQDDApjYS5pYW0ucGtpAgkA3LMrXRBhahAwCwYJYIZIAWUDBAIBMA0GCSqGSIb3DQEBAQUABIIBAHZKAgiJQad5N--GGm1L-6nreXIZDWJIDMMApDIVj-qjJsxDHT7fBl6usvRWdngqmOKxxc1cSL5gh1FO+XYYmB1hL72VVD25Rut9gfYTrbqnSGqqag4BxKni0pD4Ww+kIQq3EHXuI-kjE25R+IV63+R3vXYLGPL0yZqoMEtUiuJHldxIL+br7tBsGnIzxVkB8LDiBvhm2CsJy7BijJvQ4BfsHXRp6dZJiv5xSajSd2O77juvxcmoNm+uOL31Hf70uUzyT1sfhZ9bote2bn-bdd7ocKFsIp3TCO6-ElR8gaqZy4lOAFIJQ3Pe2ojqJqhfk7z4GkWxu0D6KeJkajxJHXQ='

export interface detectRes{
  detection_classes: Array<string>
  detection_boxes: Array<Array<number>>,
  detection_scores: Array<number>
}

interface detectFormat{
  id: number
  class: string
  box: string,
  score: string
}




@Concurrent
export async function detect(img:string, url: string, cacheDir:string): Promise<[number, detectRecordStruct]> {
  interface detectRes{
    detection_classes: Array<string>
    detection_boxes: Array<Array<number>>,
    detection_scores: Array<number>
  }

  let resData: detectRes
  let record: detectRecordStruct = new Object() as detectRecordStruct

  try {
    const fileName = Date.now() + '.jpg'
    let realUri = cacheDir + "/" + fileName //计划复制到的目标路径
    let file =  fs.openSync(img);
    fs.copyFileSync(file.fd, realUri)

    console.info('detect.upload: pic_url is '+ realUri)

    // resData = JSON.parse(
    //   `{"detection_classes":["Mouse_bite","Mouse_bite","Short","Short","Mouse_bite","Open_circuit","Spurious_copper"],"detection_boxes":[[285,1508,299,1533],[319,927,338,961],[828,1339,843,1352],[766,1639,781,1660],[264,1285,279,1314],[432,2028,453,2042],[1241,1476,1251,1567]],"detection_scores":[0.8756362199783325,0.857711672782898,0.8572907447814941,0.8237062692642212,0.7366687655448914,0.6761752367019653,0.3056696057319641]}`)

    let formData = new FormData();
    formData.append('file', realUri);

    const res:AxiosResponse<detectRes> = await axios.post(url, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
        // 'X-Auth-Token': token
      },
    })

    resData = res.data

    record = {
      r_id: 0,
      date: new Date().toString(),
      resource_uri: realUri,
      status: 0,
      detect_count: resData.detection_classes.length,
      result: JSON.stringify(resData)
    }
    return [0, record]
  } catch (err) {
    console.info('asdasd_err', err)
    return [-1, record]
  }
}

export function parseResult(result:detectRes):string {
  let formatRes: detectFormat[] = []
  for(let i=0; i<result.detection_classes.length; i++) {
    formatRes.push({
      id: i+1,
      class: result.detection_classes[i],
      box: `[${result.detection_boxes[i].join(', ')}]`,
      score: result.detection_scores[i].toFixed(2)
    })
  }
  return JSON.stringify(formatRes, null, 2)
}
