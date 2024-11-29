import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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

  final ContactsLogic _contactsLogic = GetInstance().find<ContactsLogic>();

  List<dynamic> friendList = [];

  List<dynamic> users = [];

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

  void _getFriendList() async {
    final result = await _friendApi.list();
    if (result['code'] == 0) {
      friendList = result['data'];
      update([const Key("create_chat_group")]);
    }
  }

  void init() {
    _getFriendList();
  }

  void addUsers(dynamic user) {
    if (kDebugMode) print(user);

    if (users.include(user as Map)) return;

    users.add(user);
    userTapWidth += 40;
  }

  void subUsers(dynamic user) {
    if (kDebugMode) print(user);
    users.delete(user);
    userTapWidth -= 40;
  }

  void onSelect(dynamic user) {
    if (!users.include(user)) {
      addUsers(user);
      return;
    }
    subUsers(user);
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
      Get.back();
    } else {
      CustomFlutterToast.showErrorToast(result['msg']);
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
    _contactsLogic.init();
  }
}
