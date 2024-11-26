import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/pages/image_viewer/image_viewer_update/index.dart';
import 'package:linyu_mobile/pages/image_viewer/index.dart';
import 'package:linyu_mobile/pages/add_friend/friend_info/index.dart';
import 'package:linyu_mobile/pages/add_friend/friend_request/index.dart';
import 'package:linyu_mobile/pages/add_friend/index.dart';
import 'package:linyu_mobile/pages/chat_list/index.dart';
import 'package:linyu_mobile/pages/contacts/chat_group_information/index.dart';
import 'package:linyu_mobile/pages/contacts/friend_information/index.dart';
import 'package:linyu_mobile/pages/contacts/friend_information/set_group/index.dart';
import 'package:linyu_mobile/pages/contacts/friend_information/set_remark/index.dart';
import 'package:linyu_mobile/pages/contacts/index.dart';
import 'package:linyu_mobile/pages/login/index.dart';
import 'package:linyu_mobile/pages/mine/about/index.dart';
import 'package:linyu_mobile/pages/mine/index.dart';
import 'package:linyu_mobile/pages/mine/mine_qr_code/index.dart';
import 'package:linyu_mobile/pages/navigation/index.dart';
import 'package:linyu_mobile/pages/password/retrieve/index.dart';
import 'package:linyu_mobile/pages/password/update/index.dart';
import 'package:linyu_mobile/pages/qr_code_scan/index.dart';
import 'package:linyu_mobile/pages/qr_code_scan/qr_friend_affirm/index.dart';
import 'package:linyu_mobile/pages/qr_code_scan/qr_login_affirm/index.dart';
import 'package:linyu_mobile/pages/qr_code_scan/qr_other_result/index.dart';
import 'package:linyu_mobile/pages/register/index.dart';
import 'package:linyu_mobile/pages/talk/index.dart';

import 'package:linyu_mobile/pages/mine/edit/index.dart';
import 'package:linyu_mobile/pages/talk/talk_create/index.dart';
import 'package:linyu_mobile/pages/talk/talk_details/index.dart';
import '../../pages/contacts/user_select/index.dart';
import 'ControllerBinding.dart';

class AppRoutes {
  static List<GetPage> pageRoute = [
    GetPage(
      name: '/',
      page: () => NavigationPage(
        key: const Key('main'),
      ),
      binding: ControllerBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: '/login',
      page: () => LoginPage(
        key: const Key('login'),
      ),
      binding: ControllerBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: '/register',
      page: () => RegisterPage(
        key: const Key('register'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/retrieve_password',
      page: () => RetrievePassword(
        key: const Key('retrieve_password'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/update_password',
      page: () => UpdatePasswordPage(
        key: const Key('update_password'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/chat_list',
      page: () => ChatListPage(
        key: const Key('chat_list'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/contacts',
      page: () => ContactsPage(
        key: const Key('contacts'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/mine',
      page: () => MinePage(
        key: const Key('mine'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/talk',
      page: () => TalkPage(
        key: const Key('talk'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/qr_code_scan',
      page: () => QRCodeScanPage(
        key: const Key('qr_code_scan'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/qr_login_affirm',
      page: () => QrLoginAffirmPage(
        key: const Key('qr_login_affirm'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/edit_mine',
      page: () => EditMinePage(
        key: const Key('edit_mine'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/mine_qr_code',
      page: () => MineQRCodePage(
        key: const Key('mine_qr_code'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/qr_friend_affirm',
      page: () => QRFriendAffirmPage(
        key: const Key('qr_friend_affirm'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/qr_other_result',
      page: () => QrOtherResultPage(
        key: const Key('qr_other_result'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/about',
      page: () => AboutPage(
        key: const Key('about'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/friend_info',
      page: () => FriendInformationPage(
        key: const Key('friend_info'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/set_remark',
      page: () => SetRemarkPage(
        key: const Key('set_remark'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/add_friend',
      page: () => AddFriendPage(
        key: const Key('add_friend'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/search_info',
      page: () => SearchInfoPage(
        key: const Key('search_info'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/friend_request',
      page: () => FriendRequestPage(
        key: const Key('friend_request'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/set_group',
      page: () => SetGroupPage(
        key: const Key('set_group'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/talk_details',
      page: () => TalkDetailsPage(
        key: const Key('talk_details'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/talk_create',
      page: () => TalkCreatePage(
        key: const Key('talk_create'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/user_select',
      page: () => UserSelectPage(
        key: const Key('user_select'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/chat_group_info',
      page: () => ChatGroupInformationPage(
        key: const Key('chat_group_info'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/image_viewer',
      page: () => ImageViewerPage(
        key: const Key('image_viewer'),
      ),
      binding: ControllerBinding(),
    ),
    GetPage(
      name: '/image_viewer_update',
      page: () => ImageViewerUpdatePage(
        key: const Key('image_viewer_update'),
      ),
      binding: ControllerBinding(),
    ),
  ];
}
