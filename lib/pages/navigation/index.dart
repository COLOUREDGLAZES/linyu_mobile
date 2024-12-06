import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linyu_mobile/components/custom_tip/index.dart';
import 'package:linyu_mobile/pages/navigation/logic.dart';
import 'package:linyu_mobile/utils/getx_config/config.dart';


class NavigationPage extends CustomWidget<NavigationLogic> {
  NavigationPage({required super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Obx(()
      => Scaffold(
        drawer: controller.pages[3].page(),
        body: controller.pages[controller.currentIndex.value].page(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: (index) => controller.currentIndex.value = index,
          selectedItemColor: theme.primaryColor,
          showUnselectedLabels: true,
          backgroundColor: const Color(0xFFEDF2F9),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: List.generate(
              controller.unselectedIcons.length, (index) {
            return BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    controller.currentIndex.value == index
                        ? 'assets/images/${controller
                        .selectedIcons[index]}-${theme.themeMode
                        .value}.png'
                        : controller.unselectedIcons[index],
                    width: 26,
                    height: 26,
                  ),
                  if (controller.selectedIcons[index] == 'chat' &&
                      globalData.getUnreadCount('chat') > 0)
                    CustomTip(globalData.getUnreadCount('chat')),
                  if (controller.selectedIcons[index] == 'user' &&
                      globalData.getUnreadCount('friendNotify') > 0)
                    CustomTip(globalData.getUnreadCount('friendNotify')),
                ],
              ),
              label: controller.name[index],
            );
          }),
        ),
      )
  );
  }
}
