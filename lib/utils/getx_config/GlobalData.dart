import 'package:get/get.dart';
import 'package:linyu_mobile/api/user_api.dart';
import 'package:linyu_mobile/utils/app_badger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalData extends GetxController {
  final _userApi = UserApi();
  var unread = <String, int>{}.obs;
  var currentUserId = '';
  var currentUserAccount = '';
  late String? currentUserName;
  late String? currentAvatarUrl = 'http://192.168.101.4:9000/linyu/default-portrait.jpg';

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-token');
    if (token == null) return;
    currentUserId = prefs.getString('userId') ?? '';
    currentUserAccount = prefs.getString('account') ?? '';
    currentUserName = prefs.getString('username') ?? '';
    currentAvatarUrl = prefs.getString('portrait') ?? 'http://192.168.101.4:9000/linyu/default-portrait.jpg';
    await onGetUserUnreadInfo();
  }

  Future<void> onGetUserUnreadInfo() async {
    final result = await _userApi.unread();
    if (result['code'] == 0) {
      unread.assignAll(Map<String, int>.from(result['data']));
      AppBadger.setCount(getUnreadCount('chat'), getUnreadCount('notify'));
    }
  }

  int getUnreadCount(String type) {
    if (unread.value.containsKey(type)) {
      return unread.value[type]!;
    }
    return 0;
  }

  @override
  void onInit() {
    super.onInit();
    init();
  }

}
