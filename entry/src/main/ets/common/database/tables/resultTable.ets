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

import { relationalStore } from '@kit.ArkData';
import { detectRecordStruct } from '../../../viewmodel/resultModel';
import CommonConstants from '../Common';
import Rdb from '../Rdb';
import dayjs from "@hview/dayjs"

export default class ResultsTable {
  private resultsTable = new Rdb(CommonConstants.RESULT_TABLE.tableName, CommonConstants.RESULT_TABLE.sqlCreate,
    CommonConstants.RESULT_TABLE.columns);

  // async constructor() {
  //   await this.resultsTable.getRdbStore();
  // }

  async getRdbStore() {
    await this.resultsTable.getRdbStore();
  }

  async insertData(account: detectRecordStruct): Promise<number> {
    const valueBucket: relationalStore.ValuesBucket = generateBucket(account);
    return await this.resultsTable.insertData(valueBucket);
  }

  // deleteData(account: detectRecordStruct, callback: Function) {
  //   let predicates = new relationalStore.RdbPredicates(CommonConstants.RESULT_TABLE.tableName);
  //   predicates.equalTo('id', account.id);
  //   this.resultsTable.deleteData(predicates, callback);
  // }

  // updateData(account: detectRecordStruct, callback: Function) {
  //   const valueBucket: relationalStore.ValuesBucket = generateBucket(account);
  //   let predicates = new relationalStore.RdbPredicates(CommonConstants.RESULT_TABLE.tableName);
  //   predicates.equalTo('id', account.id);
  //   this.resultsTable.updateData(predicates, valueBucket, callback);
  // }

  async query(): Promise<[string[], Map<string, detectRecordStruct[]>]> {
    let predicates = new relationalStore.RdbPredicates(CommonConstants.RESULT_TABLE.tableName);
    predicates.notEqualTo('status', -1);

    let dateList: string[]= []
    let result = new Map<string, detectRecordStruct[]>()
    let resultSet = await this.resultsTable.query(predicates)
    if (resultSet == null) {
      console.info(`${CommonConstants.TABLE_TAG}` + 'null');
      return [dateList, result]
    }
    let count: number = resultSet.rowCount;
    if (count === 0 || typeof count === 'string') {
      console.info(`${CommonConstants.TABLE_TAG}` + 'Query no results!');
      resultSet.close()
      return [dateList, result]
    }
    console.info(`${CommonConstants.TABLE_TAG}_count ${count}`);
    resultSet.goToFirstRow();

    for (let i = 0; i < count; i++) {
      let tmp: detectRecordStruct = {
        r_id: 0, date: '', status: -1, resource_uri: '', detect_count: 0, result: ''
      };
      let dateStr = dayjs(resultSet.getString(resultSet.getColumnIndex('date')))
        .format('YYYY年MM月DD日')
      let timeStr = dayjs(resultSet.getString(resultSet.getColumnIndex('date')))
        .format('HH:mm:ss')
      tmp.r_id = resultSet.getDouble(resultSet.getColumnIndex('r_id'));
      tmp.date = dateStr+' '+timeStr;
      tmp.status = resultSet.getDouble(resultSet.getColumnIndex('status'));
      tmp.resource_uri = resultSet.getString(resultSet.getColumnIndex('resource_uri'));
      tmp.detect_count = resultSet.getDouble(resultSet.getColumnIndex('detect_count'));
      tmp.result = resultSet.getString(resultSet.getColumnIndex('result'));

      if (dateList.indexOf(dateStr) == -1) {
        dateList.push(dateStr)
        result[dateStr] = []
      }
      result[dateStr].push(tmp)
      resultSet.goToNextRow();
    }
    resultSet.close()
    return [dateList.sort((a: string, b: string) => b.localeCompare(a)), result]
  }
}

function generateBucket(item: detectRecordStruct): relationalStore.ValuesBucket {
  let obj: relationalStore.ValuesBucket = {};
  obj.date = item.date;
  obj.status = item.status;
  obj.resource_uri = item.resource_uri;
  obj.detect_count = item.detect_count;
  obj.result = item.result;
  return obj;
}