import 'package:flutter/foundation.dart' show Key, kDebugMode;
import 'package:get/get.dart';
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart' show Logic;

class User {
  final String id;
  final String username;
  final String account;
  final String avatarUrl;
  bool isCurrent;

  User({
    required this.id,
    required this.username,
    required this.account,
    required this.avatarUrl,
    this.isCurrent = false,
  });
}

class ChangeAccountLogic extends Logic {
  List<User> accounts = [];

  bool _isChangingAccount = false;
  bool get isChangingAccount => _isChangingAccount;
  set isChangingAccount(bool value) {
    _isChangingAccount = value;
    super.update([const Key('change_account')]);
  }

  void init() {
    if (kDebugMode) print('init change account logic ${globalData.userIds}');
    globalData.userIds.forEach((userId) => accounts.add(User(
          id: userId,
          username: sharedPreferences.getString('username_$userId') ?? '',
          account: sharedPreferences.getString('account_$userId') ?? '',
          avatarUrl: sharedPreferences.getString('portrait_$userId') ?? '',
          isCurrent: userId == globalData.currentUserId,
        )));
  }

  void addAccount() async {
    try {
      final result =
          await Get.toNamed('/login', arguments: {'isAddAccount': true});
      if (result != null) {
        accounts.add(User(
          id: result['userId'],
          username: result['username'],
          account: result['account'],
          avatarUrl: result['portrait'] ??
              'https://p3-pc.douyinpic.com/aweme/100x100/aweme-avatar/tos-cn-i-0813_98ee65a190ea43e097c6197c34714c7f.jpeg?from=2956013662',
          isCurrent: true,
        ));
        for (var account in accounts)
          if (account.id != result['userId']) account.isCurrent = false;
        if (kDebugMode)
          print('add account currentSex is ${globalData.currentSex}');
        theme.changeThemeMode(result['sex'] == "女" ? 'pink' : 'blue');
      }
    } on Exception catch (e) {
      if (kDebugMode) print('add account error $e');
    } finally {
      super.update([const Key('change_account')]);
      wsManager.disconnect();
    }
  }

  void switchAccount(User selectedAccount) async {
    if (selectedAccount.isCurrent || isChangingAccount) return;
    try {
      isChangingAccount = true;
      globalData.currentUserId = selectedAccount.id;
      globalData.currentUserName = selectedAccount.username;
      globalData.currentAccount = selectedAccount.account;
      globalData.currentPortrait = selectedAccount.avatarUrl;
      globalData.currentToken =
          sharedPreferences.getString('x-token_${selectedAccount.id}') ?? '';
      globalData.currentSex =
          sharedPreferences.getString('sex_${selectedAccount.id}') ?? '男';
      globalData.currentTalkBackground =
          sharedPreferences.getString('talkBackground_${selectedAccount.id}') ??
              '';
      globalData.currentBirthday =
          sharedPreferences.getString('birthday_${selectedAccount.id}') ?? '';
      globalData.currentSignature =
          sharedPreferences.getString('signature_${selectedAccount.id}') ?? '';
      if (globalData.currentTalkBackground != null &&
          globalData.currentTalkBackground!.isNotEmpty)
        await globalData.updateTextColor(globalData.currentTalkBackground!);
      for (var account in accounts)
        if (account.id != selectedAccount.id) account.isCurrent = false;
      selectedAccount.isCurrent = true;
      isChangingAccount = false;
      theme.changeThemeMode(globalData.currentSex == "女" ? 'pink' : 'blue');
      CustomFlutterToast.showSuccessToast('切换用户成功~');
    } on Exception catch (e) {
      isChangingAccount = false;
      Get.snackbar('切换失败', e.toString());
      if (kDebugMode) print('切换失败 $e');
    } finally {
      wsManager.disconnect();
    }
  }

  void deleteAccount(User selectedAccount) async {
    accounts.removeWhere((a) {
      final deleteFlag = a.id == selectedAccount.id;
      globalData.userIds.removeWhere((id) => id == selectedAccount.id);
      return deleteFlag;
    });
    sharedPreferences.setStringList('userIds', globalData.userIds);
    sharedPreferences.remove('username_${selectedAccount.id}');
    sharedPreferences.remove('account_${selectedAccount.id}');
    sharedPreferences.remove('portrait_${selectedAccount.id}');
    sharedPreferences.remove('token_${selectedAccount.id}');
    sharedPreferences.remove('sex_${selectedAccount.id}');
    sharedPreferences.remove('talkBackground_${selectedAccount.id}');
    sharedPreferences.remove('birthday_${selectedAccount.id}');
    sharedPreferences.remove('signature_${selectedAccount.id}');
    Get.back();
    super.update([const Key('change_account')]);
    CustomFlutterToast.showSuccessToast('删除用户成功~');
  }

  @override
  void onInit() {
    init();
    super.onInit();
  }
}
