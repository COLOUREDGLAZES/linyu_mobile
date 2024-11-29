import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/api/chat_group_api.dart';
import 'package:linyu_mobile/api/friend_api.dart';
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/pages/contacts/logic.dart';
import 'package:linyu_mobile/utils/getx_config/config.dart';
import 'index.dart';
import 'package:linyu_mobile/utils/list_extension.dart';

class CreateChatGroupLogic extends Logic<CreateChatGroupPage> {
  final _friendApi = FriendApi();

  final _chatGroupApi = ChatGroupApi();

  final TextEditingController chatGroupController = new TextEditingController();

  final TextEditingController searchBoxController = new TextEditingController();

  final ContactsLogic _contactsLogic = GetInstance().find<ContactsLogic>();

  //所有的分组以及好友
  List<dynamic> friendList = [];

  //建群聊时邀请的用户
  List<dynamic> users = [];

  //选中的用户头像占用的宽度
  double _userTapWidth = 0;
  double get userTapWidth => _userTapWidth;
  set userTapWidth(double value) {
    _userTapWidth = value;
    update([const Key("create_chat_group")]);
  }

  int _chatGroupTextLength = 0;

  int get chatGroupTextLength => _chatGroupTextLength;

  set chatGroupTextLength(int value) {
    _chatGroupTextLength = value;
    update(['dialog']);
  }

  //是否创建群聊（返回时判断是否刷新通讯列表页面）
  bool _isCreate = false;

  //初始化方法 当退回该页面的时候 使用controller.init()进行页面刷新
  void init() {
    _getFriendList();
  }

  //获取所有分组以及好友
  void _getFriendList() async {
    final result = await _friendApi.list();
    if (result['code'] == 0) {
      friendList = result['data'];
      update([const Key("create_chat_group")]);
    }
  }

  //添加到选中的用户中
  void addUsers(dynamic user) {
    if (kDebugMode) print(user);

    if (users.include(user as Map)) return;

    users.add(user);
    userTapWidth += 40;
  }

  //删除选中的用户
  void subUsers(dynamic user) {
    if (users.isEmpty) return;
    // if (kDebugMode) print(user);
    if (user != null) {
      users.delete(user);
      userTapWidth -= 40;
      return;
    }
    users.removeAt(users.length - 1);
    userTapWidth -= 40;
  }

  //当被选中时进行的操作
  void onSelect(dynamic user) {
    if (!users.include(user)) {
      addUsers(user);
      return;
    }
    subUsers(user);
  }

  //监听键盘 backspace键 事件
  void onBackKeyPress(KeyEvent event) {
    if (event is KeyUpEvent && searchBoxController.text.isEmpty) subUsers(null);
  }

  void onChatGroupTextChanged(String value) {
    chatGroupTextLength = value.length;
    if (chatGroupTextLength >= 10) chatGroupTextLength = 10;
  }

  void onCreateChatGroup() async {
    String chatGroupName = chatGroupController.text;
    if (chatGroupController.text.isEmpty) {
      chatGroupName = users
          .map((user) => user['remark'] ?? user['name'])
          .toList()
          .toString();
    }
    List<Map<String, String>> groupMembers = [];
    for (var user in users) {
      groupMembers.add({
        'userId': user['friendId'],
        'name': user['remark'] ?? user['name'],
      });
    }
    final result =
        await _chatGroupApi.createWithPerson(chatGroupName, null, groupMembers);
    if (result['code'] == 0) {
      CustomFlutterToast.showSuccessToast('创建成功');
      _isCreate = true;
      Get.back();
    } else {
      CustomFlutterToast.showErrorToast(result['msg']);
      _isCreate = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    init();
  }

  @override
  void onClose() {
    super.onClose();
    if(_isCreate) _contactsLogic.init();
    chatGroupController.dispose();
    searchBoxController.dispose();
  }
}
