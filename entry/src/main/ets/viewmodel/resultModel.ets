// export interface detectRecords {
//   date: string,
//   results: detectRecordStruct[]
// }

export interface detectRecordStruct {
  r_id: number,
  date: string,
  status: number,
  resource_uri: string,
  detect_count: number,
  result: string
}