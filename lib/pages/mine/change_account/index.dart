import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';

import 'logic.dart';

class ChangeAccountPage extends CustomView<ChangeAccountLogic> {
  ChangeAccountPage({super.key});

  void _deleteAccount(User user) async {
    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除账号 ${user.account} 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => controller.deleteAccount(user),
              child: const Text('删除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountItem(User user) {
    return Dismissible(
      key: Key(user.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) => _deleteAccount(user),
      confirmDismiss: (direction) async {
        if (user.isCurrent) {
          ScaffoldMessenger.of(Get.context!)
              .showSnackBar(const SnackBar(content: Text('当前使用账号不能删除')));
          return false;
        }
        return true;
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.avatarUrl),
          radius: 20,
        ),
        title: Text(user.username),
        subtitle: Text(user.account),
        trailing: user.isCurrent
            ? Icon(Icons.check_circle, color: theme.primaryColor)
            : null,
        onTap: () => controller.switchAccount(user),
        tileColor: user.isCurrent ? Colors.blue.withOpacity(0.1) : null,
      ),
    );
  }

  @override
  Widget buildView(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        Get.back(result: true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('账号切换'),
          // actions: [
          //   const Text('编辑')
          //       .textColor(Colors.black)
          //       .fontSize(14)
          //       .onTap(() {})
          //       .paddingSymmetric(horizontal: 16),
          // ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.accounts.length,
                    itemBuilder: (context, index) {
                      final account = controller.accounts[index];
                      return _buildAccountItem(account);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: OutlinedButton(
                    onPressed: controller.addAccount,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('添加或注册账号',
                        style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
            if (controller.isChangingAccount)
              const CupertinoActivityIndicator(
                radius: 16, // 半径
                animating: true, // 是否动画
              ).center(),
          ],
        ),
      ),
    );
  }
}
