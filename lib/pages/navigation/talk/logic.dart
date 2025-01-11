import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/utils/api/talk_api.dart';
import 'package:linyu_mobile/utils/api/user_api.dart';
import 'package:linyu_mobile/components/CustomDialog/index.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';

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

  Future<void> init() async {
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    currentUserInfo['name'] = sharedPreferences.getString('username');
    currentUserInfo['portrait'] = sharedPreferences.getString('portrait');
    currentUserInfo['account'] = sharedPreferences.getString('account');
    currentUserInfo['sex'] = sharedPreferences.getString('sex');
    if (Get.arguments != null) {
      targetUserId = Get.arguments['userId'] ?? '';
      title = Get.arguments['title'] ?? '说说';
      isNotShowLeading = Get.arguments['isNotShowLeading'] ?? false;
    }
    await refreshData();
    scrollController.addListener(scrollListener);
    currentUserId = sharedPreferences.getString('userId') ?? '';
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      onTalkList();
    }
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
    final result = await Get.toNamed('/edit_mine');
    if (result != null)
      init().then((_) => theme.changeThemeMode(
          sharedPreferences.getString('sex') == "女" ? "pink" : "blue"));
  }

  @override
  void onInit() {
    init();
    super.onInit();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
