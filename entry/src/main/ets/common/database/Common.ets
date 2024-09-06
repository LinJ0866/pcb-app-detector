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

export interface AccountTable {
  tableName: string;
  sqlCreate: string;
  columns: string[];
}

export default class CommonConstants {
  /**
   * Rdb database config.
   */
  static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'database.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };
  /**
   * Account table config.
   */
  static readonly RESULT_TABLE: AccountTable = {
    tableName: 'results',
    sqlCreate: 'CREATE TABLE IF NOT EXISTS results(r_id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, ' +
      'status INTEGER, resource_uri TEXT, detect_count INTEGER, result TEXT)',
    columns: ['r_id', 'date', 'status', 'resource_uri', 'detect_count', 'result']
  };

  /**
   * Log tag.
   */
  static readonly RDB_TAG = '[Debug.Rdb]';
  static readonly TABLE_TAG = '[Debug.ResultsTable]';
  static readonly INDEX_TAG = '[Debug.Index]';

}