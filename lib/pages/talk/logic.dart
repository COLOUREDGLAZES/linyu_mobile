import 'dart:io';

import 'package:dio/dio.dart' show FormData, MultipartFile;
import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    show Colors, Icons, ListTile, TextButton, showModalBottomSheet;
import 'package:get/get.dart' as GetX;
import 'package:image_picker/image_picker.dart';
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/utils/api/talk_api.dart';
import 'package:linyu_mobile/utils/api/user_api.dart';
import 'package:linyu_mobile/components/CustomDialog/index.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';
import 'package:linyu_mobile/utils/crop_picture.dart';
import 'package:palette_generator/palette_generator.dart';

// class TalkLogic extends GetxController {
class TalkLogic extends Logic {
  final _talkApi = TalkApi();
  final _userApi = UserApi();
  String currentUserId = '';
  String targetUserId = '';
  String title = '说说';
  bool isNotShowLeading = false;
  late dynamic currentUserInfo = {};
  List<dynamic> talkList = [];
  // final _wsManager = new WebSocketUtil();
  // final wsManager = Get.find<WebSocketUtil>();
  int index = 0;
  bool hasMore = true;
  bool isLoading = false;
  final ScrollController scrollController = ScrollController();

  bool _isExpanded = true;
  bool get isExpanded => _isExpanded;
  set isExpanded(bool value) {
    _isExpanded = value;
    update([const Key("talk")]);
  }

  Color _textColor = Colors.black;
  Color get textColor => _textColor;
  set textColor(Color value) {
    _textColor = value;
    update([const Key("talk")]);
  }

  GetX.RxDouble opacity = 0.0.obs;

  Future<void> init() async {
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    currentUserInfo['name'] = sharedPreferences.getString('username');
    currentUserInfo['portrait'] = sharedPreferences.getString('portrait');
    currentUserInfo['account'] = sharedPreferences.getString('account');
    currentUserInfo['sex'] = sharedPreferences.getString('sex');
    if (GetX.Get.arguments != null) {
      targetUserId = GetX.Get.arguments['userId'] ?? '';
      title = GetX.Get.arguments['title'] ?? '说说';
      isNotShowLeading = GetX.Get.arguments['isNotShowLeading'] ?? false;
    }
    await refreshData();
    scrollController.addListener(scrollListener);
    currentUserId = sharedPreferences.getString('userId') ?? '';
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500), // 动画持续时间
      curve: Curves.easeInOut, // 动画曲线
    );
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      onTalkList();
    }
    if (scrollController.offset > 140.w &&
        !scrollController.position.outOfRange &&
        opacity.value != 1) {
      opacity.value = 1;
    }
    if (scrollController.offset < 140.w &&
        !scrollController.position.outOfRange &&
        opacity.value != 0) {
      opacity.value = 0;
    }
    final double offset = scrollController.offset;
    // 检查滚动视图是否在顶部，并且偏移量在可展开高度范围内
    // 这里需要考虑AppBar完全展开的临界值。
    bool isExpanded = offset <= 0; // 或者可以加一个容错范围，例如 offset <= 5
    if (isExpanded != this.isExpanded) this.isExpanded = isExpanded;
  }

  void onTalkList() {
    if (!hasMore || isLoading) return;
    isLoading = true;
    update([const Key("talk")]);
    _talkApi
        .list(index, 10, targetUserId)
        .then((res) {
          if (res['code'] == 0) {
            final List<dynamic> newTalks = res['data'];
            if (newTalks.isEmpty)
              hasMore = false;
            else {
              talkList.addAll(newTalks);
              index += newTalks.length;
            }
            isLoading = false;
          } else
            isLoading = false;
        })
        .catchError(() => isLoading = false)
        .whenComplete(() => update([const Key("talk")]));
  }

  Future<void> refreshData() async {
    try {
      talkList.clear();
      index = 0;
      hasMore = true;
      update([const Key("talk")]);
      onTalkList();
    } catch (e) {
      if (kDebugMode) print('刷新数据时出错: $e');
    } finally {
      //判断websocket是否连接
      if (!wsManager.isConnected) wsManager.connect();
    }
  }

  // Future<void> refreshData() async {
  //   talkList.clear();
  //   index = 0;
  //   hasMore = true;
  //   update([const Key("talk")]);
  //   onTalkList();
  // }

  void updateTalkLikeOrCommentCount(String key, int num, String talkId) =>
      talkList.forEach((talk) {
        if (talk['talkId'] == talkId) {
          update([const Key("talk")]);
          return;
        }
      });
  // for (var talk in talkList)
  //   if (talk['talkId'] == talkId) {
  //     talk[key] = num;
  //     update([const Key("talk")]);
  //     return;
  //   }

  void onDeleteTalk(talkId) => _talkApi.delete(talkId).then((res) {
        if (res['code'] == 0) {
          for (var talk in talkList) {
            if (talk['talkId'] == talkId) {
              talkList.remove(talk);
              update([const Key("talk")]);
              return;
            }
          }
        }
      });

  void handlerDeleteTalkTip(BuildContext context, String talkId) =>
      CustomDialog.showTipDialog(
        context,
        text: '确认删除该条说说?',
        onOk: () => onDeleteTalk(talkId),
        onCancel: () {},
      );

  Future<String> onGetImg(String fileName, String userId) async {
    dynamic res = await _userApi.getImg(fileName, userId);
    if (res['code'] == 0) {
      return res['data'];
    }
    return '';
  }

  void onLongPressPortrait() async {
    final result = await GetX.Get.toNamed('/edit_mine');
    if (result != null)
      init().then((_) => theme.changeThemeMode(
          sharedPreferences.getString('sex') == "女" ? "pink" : "blue"));
  }

  Future<Color> updateTextColor(String imageUrl) async {
    // accept imageUrl parameter
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
            NetworkImage(imageUrl)); // Use imageUrl here
    Color? dominantColor = paletteGenerator.dominantColor?.color;

    if (dominantColor != null) {
      // Calculate brightness
      double brightness = (0.299 * dominantColor.red +
              0.587 * dominantColor.green +
              0.114 * dominantColor.blue) /
          255;
      // Choose text color based on brightness
      // textColor = brightness > 0.5 ? Colors.white : Colors.black;
      textColor = brightness > 0.5 ? Colors.black : Colors.white;
    } else
      textColor = Colors.black;

    return textColor;
  }

  //上传背景图片
  Future<void> _uploadPicture(File picture) async {
    try {
      final fileName = picture.path.split('/').last;
      final file =
          await MultipartFile.fromFile(picture.path, filename: fileName);
      final formData = FormData.fromMap({
        'type': 'image/jpeg',
        'name': fileName,
        'size': picture.lengthSync(),
        'file': file,
      });
      final result = await _userApi.uploadTalkBackground(formData);
      if (result['code'] == 0) {
        GetX.Get.back();
        final data = result['data'];
        await sharedPreferences.setString(
            'talkBackground', data['talkBackground']);
        globalData.currentBackGroundUrl = data['talkBackground'];
        await updateTextColor(data['talkBackground']);
        CustomFlutterToast.showSuccessToast('说说背景上传成功');
      } else
        CustomFlutterToast.showErrorToast(result['msg']);
    } catch (e) {
      if (kDebugMode) print('头像上传失败: $e');
    }
  }

  // 选择图片
  Future _cropChatPicture(ImageSource? type) async =>
      cropPicture(type, _uploadPicture, isVariable: true);

  //更换说说背景
  void changeTalkBackground(BuildContext context) => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
        ),
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('图库'),
                onTap: () => _cropChatPicture(null),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () => _cropChatPicture(ImageSource.camera),
              ),
            ],
          );
        },
      );

  @override
  void onInit() {
    init();
    super.onInit();
  }

  @override
  void onReady() {
    updateTextColor(globalData.currentBackGroundUrl ??
        // globalData.currentAvatarUrl ??
        'http://114.96.70.115:19000/linyu/default-portrait.jpg');
    super.onReady();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
