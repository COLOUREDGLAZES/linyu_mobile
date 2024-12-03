import 'package:flutter/foundation.dart';

extension UsersListExtension<E extends Map<String, dynamic>> on List {
  bool include(Map value) {
    for (E e in this) {
      if (e['friendId'] == value['friendId']) return true;
    }
    return false;
  }

  bool delete(Map value) {
    for (E e in this) {
      if (e['friendId'] == value['friendId']) {
        return remove(e);
      }
    }
    return false;
  }

  List copyWithList({List? list}) {
    List sourceList = list ?? this; // 若 list 为空，将其设为当前对象
    if (sourceList.isEmpty) return []; // 若源列表为空，返回空列表
    List copyList = []; // 创建一个新的列表用于存放复制的元素
    try {
      for (var item in sourceList) {
        if (item is Map) {
          Map<String, dynamic> mapItem = Map.from(item);
          copyList.add(mapItem);
        } else if (item is List) {
          copyList.add(item.copyWithList());
        } else {
          copyList.add(item);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('复制列表时发生错误: $e');
      } // 错误处理，输出错误信息
    }
    return copyList; // 返回复制后的列表
  }
}
