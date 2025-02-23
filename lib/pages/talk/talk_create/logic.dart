import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart'
    show Get, GetInstance, GetNavigation, GetxController;
import 'package:get/get_rx/get_rx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linyu_mobile/utils/api/talk_api.dart';
import 'package:dio/dio.dart' show MultipartFile, FormData;
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';

import '../logic.dart';

class TalkCreateLogic extends GetxController {
  final _talkApi = TalkApi();
  final contentController = TextEditingController();
  final selectedImages = <File>[].obs;
  late List<dynamic> selectedUsers = [];

  TalkLogic get talkLogic => GetInstance().find<TalkLogic>();

  Future<void> pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      // final List<XFile>? images = await picker.pickMultiImage();
      XFile? image = await picker.pickImage(source: ImageSource.gallery);
      // final List<XFile>? images = await picker.pickMultiImage();
      // if (images != null)
      if (image != null) {
        // 检查images是否为空
        // selectedImages
        //     .assignAll(images.map((image) => File(image.path)).toList());
        // selectedImages.forEach((file) => file.path == image.path
        //     ? selectedImages.remove(file)
        //     : selectedImages.add(File(image.path)));
        // bool isExists = false;
        // for (var file in selectedImages)
        //   if (file.path == image.path) {
        //     isExists = true;
        //     break;
        //   }
        // if (!isExists)
        selectedImages.add(File(image.path));
      }
    } catch (e) {
      if (kDebugMode) print('选择图片时发生错误：${e.toString()}');
    }
  }

  // Future<void> pickImages() async {
  //   final ImagePicker picker = ImagePicker();
  //   final List<XFile> images = await picker.pickMultiImage();
  //   for (var image in images) selectedImages.add(File(image.path));
  // }

  void removeImage(int index) => selectedImages.removeAt(index);

  Future<Map<String, dynamic>> onUploadImg(String talkId, File img) async {
    try {
      // 获取文件名称
      final fileName = img.path.split('/').last;
      // 创建 MultipartFile
      final file = await MultipartFile.fromFile(img.path, filename: fileName);
      FormData formData = FormData.fromMap({
        'talkId': talkId,
        'name': fileName,
        'size': img.lengthSync(),
        'file': file,
      });
      return await _talkApi.uploadImg(formData);
    } catch (e) {
      // 错误处理
      if (kDebugMode) print('上传图片时发生错误：${e.toString()}');
      return {'code': -1, 'message': '上传失败，请稍后再试'};
    }
  }

  // Future<Map<String, dynamic>> onUploadImg(String talkId, File img) async {
  //   Map<String, dynamic> map = {};
  //   final file = await MultipartFile.fromFile(img.path,
  //       filename: img.path.split('/').last);
  //   map['talkId'] = talkId;
  //   map['name'] = img.path.split('/').last;
  //   map['size'] = img.lengthSync();
  //   map["file"] = file;
  //   FormData formData = FormData.fromMap(map);
  //   return await _talkApi.uploadImg(formData);
  // }

  void onCreateTalk() async {
    if (contentController.text.isEmpty && selectedImages.isEmpty) {
      CustomFlutterToast.showSuccessToast('内容不能为空~');
      return;
    }
    List permission = selectedUsers.map((user) => user['friendId']).toList();
    try {
      final res = await _talkApi.create(contentController.text, permission);
      if (res['code'] == 0) {
        if (selectedImages.isNotEmpty) {
          List result = await Future.wait(
            selectedImages.map((img) => onUploadImg(res['data']['id'], img)),
          );
          // 只在有有效结果时才显示成功提示
          if (result.isNotEmpty) {
            CustomFlutterToast.showSuccessToast('发表成功~');
            if (talkLogic.initialized) talkLogic.refreshData();
            Get.back(result: {
              'msg': '发表成功',
              'refresh': true,
            });
          } else
            CustomFlutterToast.showErrorToast('发表失败·请稍后再试~');
        } else {
          CustomFlutterToast.showSuccessToast('发表成功~');
          Get.back(result: {
            'msg': '发表成功，未上传图片',
            'refresh': true,
          });
          if (talkLogic.initialized) talkLogic.refreshData();
        }
      } else
        CustomFlutterToast.showErrorToast('创建失败·请稍后再试~');
    } catch (e) {
      if (kDebugMode) print('发生错误：${e.toString()}');
      // CustomFlutterToast.showErrorToast('发生错误：${e.toString()}');
    }
  }

  // void onCreateTalk() {
  //   if (contentController.text.isEmpty) {
  //     CustomFlutterToast.showSuccessToast('内容不能为空~');
  //     return;
  //   }
  //   List permission = selectedUsers.map((user) => user['friendId']).toList();
  //   _talkApi.create(contentController.text, permission).then((res) async {
  //     if (res['code'] == 0) {
  //       List result = [];
  //       for (var img in selectedImages)
  //         result.add(await onUploadImg(res['data']['id'], img));
  //       if (result.length > 0) {
  //         CustomFlutterToast.showSuccessToast('发表成功~');
  //         Get.back(result: {
  //           'msg': '发表成功',
  //           'refresh': true,
  //         });
  //         if (talkLogic.initialized) talkLogic.refreshData();
  //       } else
  //         CustomFlutterToast.showErrorToast('发表失败·请稍后再试~');
  //     }
  //   });
  // }

  Future<void> handlerToUserSelect() async {
    var result = await Get.toNamed('/user_select',
        arguments: {'selectedUsers': selectedUsers});
    if (result != null) selectedUsers = result;
    update([const Key('talk_create')]);
  }

  @override
  void onClose() {
    contentController.dispose();
    super.onClose();
  }
}
