import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:sqflite/sqflite.dart';

enum DBTyble { message, chatList, talk }

class SqfliteHelper extends GetxController {
  factory SqfliteHelper() => _sqfliteHelper;
  SqfliteHelper._internal() {
    _tables = {
      DBTyble.message: _messageTable,
      DBTyble.chatList: _chatList,
      DBTyble.talk: _talk,
    };
    if (kDebugMode) print("SqfliteHelper init ......");
  }
  static final SqfliteHelper _sqfliteHelper = SqfliteHelper._internal();

  final _sqlFileName = 'linyu.db';

  final _messageTable = 'message';
  final _chatList = 'chat_list';
  final _talk = 'talk';
  late final Map<DBTyble, String> _tables;
  Database? _db;
  void open() async {
    String path = "${await getDatabasesPath()}/$_sqlFileName";
    if (kDebugMode) print("SqfliteHelper open path: $path");
    if (_db == null)
      _db = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
        await db.execute('''
            create table if not exists $_messageTable(
                id               text primary key,
                fromId           text,
                toId             text,
                type             text,
                isShowTime       bit,
                msgContent       text,
                status           text,
                source           text,
                createTime       text,
                updateTime       text,
                fromForwardMsgId text
            );
        ''');
        // await db.execute('''
        //     create table if not exists $_chatList(
        //         id              text primary key,
        //         userId          text,
        //         fromId          text,
        //         isTop           bit,
        //         unreadNum       integer,
        //         lastMsgContent  text,
        //         type            text,
        //         status          text,
        //         createTime      text,
        //         updateTime      text
        //     );
        // ''');
        // await db.execute('''
        //     create table if not exists $_talk(
        //         id            text primary key,
        //         userId        text,
        //         content       text,
        //         likeNum       integer,
        //         commentNum    integer,
        //         latestComment text,
        //         status        text,
        //         createTime    text,
        //         updateTime    text
        //     );
        // ''');
      });
    if (kDebugMode) print("SqfliteHelper open success ......");
  }

  Future<int?> insert(Map<String, dynamic> data, {DBTyble? table}) async {
    String tableStr = _tables[table ?? DBTyble.message]!;
    final result = await _db?.insert(tableStr, data,
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return result;
  }

  Future<int?> insertAll(List<dynamic> data, {DBTyble? table}) async {
    int count = 0;
    data.forEach((element) async {
      await insert(element, table: table);
      count++;
    });
    return count;
  }

  Future<int?> updateDB(Map<String, dynamic> data, {DBTyble? table}) async {
    final String tableStr = _tables[table ?? DBTyble.message]!;

    final result = await _db
        ?.update(tableStr, data, where: 'id =?', whereArgs: [data['id']]);
    return result;
  }

  Future<int?> updateOrInsert(Map<String, dynamic> data,
      {DBTyble? table}) async {
    final String tableStr = _tables[table ?? DBTyble.message]!;
    final result = await _db?.insert(tableStr, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  Future<int?> updateOrInsertAll(List<dynamic> data, {DBTyble? table}) async {
    int count = 0;
    data.forEach((element) async {
      await updateOrInsert(element, table: table);
      count++;
    });
    return count;
  }

  Future<int?> delete(String id, {DBTyble? table}) async {
    final String tableStr = _tables[table ?? DBTyble.message]!;
    final result = await _db?.delete(tableStr, where: 'id =?', whereArgs: [id]);
    return result;
  }

  Future<int?> deleteAll({DBTyble? table}) async {
    final String tableStr = _tables[table ?? DBTyble.message]!;
    final result = await _db?.delete(tableStr);
    return result;
  }

  Future<List<Map<String, dynamic>>?> query(String sql) async {
    final result = await _db?.rawQuery(sql);
    return result;
  }

  Future<List<Map<String, dynamic>>?> queryAll({DBTyble? table}) async {
    final String tableStr = _tables[table ?? DBTyble.message]!;
    final result = await _db?.query(tableStr);
    return result;
  }

  Future<List<Map<String, dynamic>>?> queryById(String id,
      {DBTyble? table}) async {
    final String tableStr = _tables[table ?? DBTyble.message]!;
    final result = await _db?.query(tableStr, where: 'id =?', whereArgs: [id]);
    return result;
  }

  Future<List<Map<String, dynamic>>?> queryByFromId(String fromId,
      {DBTyble? table}) async {
    final String tableStr = _tables[table ?? DBTyble.message]!;
    final result =
        await _db?.query(tableStr, where: 'from_id =?', whereArgs: [fromId]);
    return result;
  }

  Future<List<Map<String, dynamic>>?> queryByToId(String toId,
      {DBTyble? table}) async {
    final String tableStr = _tables[table ?? DBTyble.message]!;
    final result =
        await _db?.query(tableStr, where: 'to_id =?', whereArgs: [toId]);
    return result;
  }

  Future<List<dynamic>> queryMessageByCondition(
    String userId,
    String targetId,
    int index,
    int num,
  ) async {
    final result = await _db?.rawQuery('''
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
    await _db?.close();
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
