import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteHelper extends GetxController {
  final sqlFileName = 'linyu.db';
  final table = 'message';
  Database? db;
  void open() async {
    String path = "${await getDatabasesPath()}/$sqlFileName";
    debugPrint("SqfliteHelper open path: $path");
    if (db == null)
      db = await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async => await db.execute('''
        create table if not exists message
        (
          id           text primary key,
          fromId      text,
          toId        text,
          type         text,
          isShowTime bit,
          msgContent  text,
          status       text,
          source       text,
          createTime  text,
          updateTime  text,
          fromForwardMsgId text
          );
        '''),
      );
    debugPrint("SqfliteHelper open success ......");
  }

  Future<int?> insert(Map<String, dynamic> data) async {
    final result = await db?.insert(table, data,
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return result;
  }

  Future<int?> insertAll(List<dynamic> data) async {
    int count = 0;
    data.forEach((element) async {
      await insert(element);
      count++;
    });
    return count;
  }

  Future<int?> updateDB(Map<String, dynamic> data) async {
    final result =
        await db?.update(table, data, where: 'id =?', whereArgs: [data['id']]);
    return result;
  }

  Future<int?> updateOrInsert(Map<String, dynamic> data) async {
    final result = await db?.insert(table, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  Future<int?> updateOrInsertAll(List<dynamic> data) async {
    int count = 0;
    data.forEach((element) async {
      await updateOrInsert(element);
      count++;
    });
    return count;
  }

  Future<int?> delete(String id) async {
    final result = await db?.delete(table, where: 'id =?', whereArgs: [id]);
    return result;
  }

  Future<int?> deleteAll() async {
    final result = await db?.delete(table);
    return result;
  }

  Future<List<Map<String, dynamic>>?> query(String sql) async {
    final result = await db?.rawQuery(sql);
    return result;
  }

  Future<List<Map<String, dynamic>>?> queryAll() async {
    final result = await db?.query(table);
    return result;
  }

  Future<List<Map<String, dynamic>>?> queryById(String id) async {
    final result = await db?.query(table, where: 'id =?', whereArgs: [id]);
    return result;
  }

  Future<List<Map<String, dynamic>>?> queryByFromId(String fromId) async {
    final result =
        await db?.query(table, where: 'from_id =?', whereArgs: [fromId]);
    return result;
  }

  Future<List<Map<String, dynamic>>?> queryByToId(String toId) async {
    final result = await db?.query(table, where: 'to_id =?', whereArgs: [toId]);
    return result;
  }

  Future<List<Map<String, dynamic>>?> queryByStatus(String status) async {
    final result =
        await db?.query(table, where: 'status =?', whereArgs: [status]);
    return result;
  }

  Future<List<Map<String, dynamic>>?> queryBySource(String source) async {
    final result =
        await db?.query(table, where: 'source =?', whereArgs: [source]);
    return result;
  }

  Future<List<Map<String, dynamic>>?> queryByCreateTime(
      String createTime) async {
    final result = await db
        ?.query(table, where: 'create_time =?', whereArgs: [createTime]);
    return result;
  }

  Future<List<Map<String, dynamic>>?> queryByUpdateTime(
      String updateTime) async {
    final result = await db
        ?.query(table, where: 'update_time =?', whereArgs: [updateTime]);
    return result;
  }

  Future<List<Map<String, dynamic>>?> queryByFromForwardMsgId(
      String fromForwardMsgId) async {
    final result = await db?.query(table,
        where: 'from_forward_msgId =?', whereArgs: [fromForwardMsgId]);
    return result;
  }

  Future<List<dynamic>> queryByCondition(
    String userId,
    String targetId,
    int index,
    int num,
  ) async {
    // final result = await db?.rawQuery('''
    //     SELECT * FROM (SELECT * FROM `message` WHERE
    //     (`fromId` = ? AND `toId` = ?) OR (`fromId` = ? AND `toId` = ?)
    //     OR (`source` = 'group' AND `toId` = ?)
    //     ORDER BY `createTime` DESC LIMIT ?, ?)
    //     AS subquery ORDER BY `createTime` ASC;
    //     ''', [userId, targetId, targetId, userId, targetId, index, num]);
    final result = await db?.rawQuery('''
        select * from(
            select * from message where
              ( fromId = ? and toId = ? ) or 
              ( fromId = ? and toId = ? ) or 
              ( source = 'group' and toId = ? ) 
              order by createTime desc limit ?,? 
            ) as subquery order by createTime asc;
        ''', [userId, targetId, targetId, userId, targetId, index, num]);
    return result ?? [];
  }

  Future close() async {
    await db?.close();
  }

  @override
  void onInit() {
    open();
    super.onInit();
  }

  @override
  void onClose() {
    close();
    super.onClose();
  }
}
