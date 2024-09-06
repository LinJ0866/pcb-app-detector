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
import CommonConstants from './Common';
import Logger from '../utils/Logger';



export default class Rdb {
  private rdbStore: relationalStore.RdbStore | null = null;
  private tableName: string;
  private sqlCreateTable: string;
  private columns: Array<string>;

  constructor(tableName: string, sqlCreateTable: string, columns: Array<string>) {
    this.tableName = tableName;
    this.sqlCreateTable = sqlCreateTable;
    this.columns = columns;
  }

  async getRdbStore(): Promise<number> {
    if (this.rdbStore !== null) {
      Logger.info(CommonConstants.RDB_TAG, 'The rdbStore exists.');
      return -1;
    }
    let context: Context = getContext(this) as Context;
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, CommonConstants.STORE_CONFIG)
      await this.rdbStore.executeSql(this.sqlCreateTable);
      Logger.info(CommonConstants.RDB_TAG, 'getRdbStore() finished.');
      return 0
    } catch (err) {
      Logger.error(CommonConstants.RDB_TAG, `gerRdbStore() failed, err: ${err}`);
      return -1;
    }
  }

  async insertData(data: relationalStore.ValuesBucket): Promise<number> {
    const valueBucket: relationalStore.ValuesBucket = data;
    try {
      if (this.rdbStore) {
        let ret = await this.rdbStore.insert(this.tableName, valueBucket)

        Logger.info(CommonConstants.RDB_TAG, `insertData() finished: ${ret}`);
        return ret
      };
      Logger.error(CommonConstants.RDB_TAG, 'rdbStore init error.');
      return 0
    } catch (err) {
      Logger.error(CommonConstants.RDB_TAG, `insertData() failed, err: ${err}`);
      return 0;
    }
  }

  // deleteData(predicates: relationalStore.RdbPredicates, callback: Function = () => {
  // }) {
  //   if (!callback || typeof callback === 'undefined' || callback === undefined) {
  //     Logger.info(CommonConstants.RDB_TAG, 'deleteData() has no callback!');
  //     return;
  //   }
  //   let resFlag: boolean = false;
  //   if (this.rdbStore) {
  //     this.rdbStore.delete(predicates, (err, ret) => {
  //       if (err) {
  //         Logger.error(CommonConstants.RDB_TAG, `deleteData() failed, err: ${err}`);
  //         callback(resFlag);
  //         return;
  //       }
  //       Logger.info(CommonConstants.RDB_TAG, `deleteData() finished: ${ret}`);
  //       callback(!resFlag);
  //     });
  //   }
  // }
  //
  // updateData(predicates: relationalStore.RdbPredicates, data: relationalStore.ValuesBucket, callback: Function = () => {
  // }) {
  //   if (!callback || typeof callback === 'undefined' || callback === undefined) {
  //     Logger.info(CommonConstants.RDB_TAG, 'updateDate() has no callback!');
  //     return;
  //   }
  //   let resFlag: boolean = false;
  //   const valueBucket: relationalStore.ValuesBucket = data;
  //   if (this.rdbStore) {
  //     this.rdbStore.update(valueBucket, predicates, (err, ret) => {
  //       if (err) {
  //         Logger.error(CommonConstants.RDB_TAG, `updateData() failed, err: ${err}`);
  //         callback(resFlag);
  //         return;
  //       }
  //       Logger.info(CommonConstants.RDB_TAG, `updateData() finished: ${ret}`);
  //       callback(!resFlag);
  //     });
  //   }
  // }

  async query(predicates: relationalStore.RdbPredicates): Promise<relationalStore.ResultSet | null> {
    try{
      if (this.rdbStore) {
        let resultSet = await this.rdbStore.query(predicates, this.columns)

        Logger.info(CommonConstants.RDB_TAG, 'query() finished.');
        return resultSet
      }
      Logger.error(CommonConstants.RDB_TAG, 'rdbStore init error.');
      return null
    } catch (err) {
        Logger.error(CommonConstants.RDB_TAG, `query() failed, err:  ${err}`);
        return null;
    }
  }
}