import 'package:ducafe_ui_core/ducafe_ui_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart'
    show Get, GetMaterialApp, GetNavigation, Inst, SmartManagement, Transition;
import 'package:linyu_mobile/utils/config/getx/controller_binding.dart';
import 'package:linyu_mobile/utils/config/getx/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linyu_mobile/utils/config/network/http.dart' as http;
import 'package:linyu_mobile/utils/config/network/web_socket.dart' as websocket;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await Get.putAsync<SharedPreferences>(
      () async => await SharedPreferences.getInstance(),
      permanent: true);
  String? token = prefs.getString('x-token');
  String? sex = prefs.getString('sex');
  http.baseUrl = prefs.getString("httpUrl");
  websocket.websocketUrl = prefs.getString("websocket_ip");
  runApp(MyApp(
      key: const Key('MyApp'),
      initialRoute: token != null ? '/?sex=$sex' : '/login'));
}

class MyApp extends StatelessWidget {
  final String? initialRoute;
  final Widget? initialPage;

  const MyApp({super.key, this.initialPage, this.initialRoute});

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => GetMaterialApp(
          key: UniqueKey(),
          navigatorKey: Get.key,
          smartManagement: SmartManagement.keepFactory,
          title: '林语',
          //国际化
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'CH'),
            Locale('en', 'US'),
          ],
          locale: const Locale('zh'),
          //全局绑定Controller
          initialBinding: ControllerBinding(),
          enableLog: true,
          //路由配置
          getPages: pageRoute,
          //路由从右侧向左滑入（对GetX有效）
          defaultTransition: Transition.rightToLeft,
          //路由监听
          routingCallback: routingCallback,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4C9BFF),
              surface: const Color(0xFFFFFFFF),
              onSurface: const Color(0xFF1F1F1F),
              primary: const Color(0xFF4C9BFF),
              onPrimary: Colors.white,
            ),
            splashColor: const Color(0x80EAEAEA),
            highlightColor: const Color(0x80EAEAEA),
            useMaterial3: true,
          ),
          home: initialPage,
          initialRoute: initialRoute,
        ),
      );
}

// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart'; // 引入 url_launcher 包
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: '个人主页',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'Roboto',
//       ),
//       home: const ProfilePage(),
//     );
//   }
// }
//
// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeader(context),
//             _buildProfileInfo(context),
//             _buildSkillsSection(context),
//             _buildExperienceSection(context),
//             _buildSocialSection(context),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Header 部分
//   Widget _buildHeader(BuildContext context) {
//     return Container(
//       height: 200,
//       width: double.infinity,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.blue, Colors.lightBlueAccent],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Positioned(
//             top: 30,
//             left: 20,
//             child: IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.white),
//               onPressed: () {
//                 // 返回逻辑
//               },
//             ),
//           ),
//           const Text(
//             "我的主页",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 个人信息部分
//   Widget _buildProfileInfo(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(60),
//             child: Image.network(
//               'https://avatars.githubusercontent.com/u/66918811?v=4', // 替换成你的头像 URL
//               width: 120,
//               height: 120,
//               fit: BoxFit.cover,
//             ),
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             '你的名字', // 替换成你的名字
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             '职位 / 简介', // 替换成你的职位和简介
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey[600],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.location_on, color: Colors.grey[600]),
//               const SizedBox(width: 4),
//               const Text('你的城市, 国家'), // 替换成你的城市和国家
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 技能部分
//   Widget _buildSkillsSection(BuildContext context) {
//     final skills = [
//       'Flutter',
//       'Dart',
//       'Firebase',
//       'REST API',
//       'Git',
//       'HTML',
//       'CSS',
//       'JavaScript'
//     ]; // 你的技能列表
//
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             '技能',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Wrap(
//             spacing: 8.0,
//             runSpacing: 4.0,
//             children: skills.map((skill) => Chip(label: Text(skill))).toList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 经历部分
//   Widget _buildExperienceSection(BuildContext context) {
//     final experiences = [
//       {
//         'title': '公司名称',
//         'subtitle': '职位',
//         'date': '2022 - Present',
//         'description': '工作描述...'
//       },
//       {
//         'title': '另一家公司',
//         'subtitle': '另一个职位',
//         'date': '2020 - 2022',
//         'description': '另一份工作的描述...'
//       },
//     ];
//
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             '经历',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 10),
//           ...experiences.map((exp) => Card(
//                 elevation: 2,
//                 child: ListTile(
//                   title: Text(exp['title']!),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(exp['subtitle']!),
//                       Text(
//                         exp['date']!,
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(exp['description']!),
//                     ],
//                   ),
//                   isThreeLine: true,
//                 ),
//               )),
//         ],
//       ),
//     );
//   }
//
//   // 社交媒体部分
//   Widget _buildSocialSection(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             '社交媒体',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.link),
//                 onPressed: () {
//                   _launchURL(
//                       'https://www.github.com/你的GitHub'); // 替换成你的 GitHub 链接
//                 },
//               ),
//               IconButton(
//                 icon: const Icon(Icons.email),
//                 onPressed: () {
//                   _launchURL('mailto:你的邮箱地址'); // 替换成你的邮箱地址
//                 },
//               ),
//               IconButton(
//                 icon: const Icon(Icons.web),
//                 onPressed: () {
//                   _launchURL('https://你的个人网站'); // 替换成你的个人网站链接
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 打开链接
//   _launchURL(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: '个人主页',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'Roboto',
//       ),
//       home: ProfilePage(),
//     );
//   }
// }
//
// class ProfilePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         // 使用 CustomScrollView
//         slivers: [
//           _buildSliverAppBar(context), // SliverAppBar
//           SliverList(
//             // SliverList 替代 Column
//             delegate: SliverChildListDelegate(
//               [
//                 _buildProfileInfo(context),
//                 _buildSkillsSection(context),
//                 _buildExperienceSection(context),
//                 _buildSocialSection(context),
//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 使用 SliverAppBar
//   Widget _buildSliverAppBar(BuildContext context) {
//     return SliverAppBar(
//       expandedHeight: 200.0, // 展开的高度
//       floating: false, // 设置为 true，当向上滚动时，AppBar 会立即显示
//       pinned: true, // AppBar 固定在顶部
//       flexibleSpace: FlexibleSpaceBar(
//         centerTitle: true,
//         title: Text(
//           "我的主页",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16.0,
//           ),
//         ),
//         background: Image.network(
//           "https://images.unsplash.com/photo-1541701496583-0a94ca585fe8?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1974&q=80", // 替换为你的背景图片URL
//           fit: BoxFit.cover, // 图片填充方式
//         ),
//       ),
//     );
//   }
//
//   // 个人信息部分
//   Widget _buildProfileInfo(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(60),
//             child: Image.network(
//               'https://avatars.githubusercontent.com/u/66918811?v=4', // 替换成你的头像 URL
//               width: 120,
//               height: 120,
//               fit: BoxFit.cover,
//             ),
//           ),
//           SizedBox(height: 16),
//           Text(
//             '你的名字', // 替换成你的名字
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             '职位 / 简介', // 替换成你的职位和简介
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey[600],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.location_on, color: Colors.grey[600]),
//               SizedBox(width: 4),
//               Text('你的城市, 国家'), // 替换成你的城市和国家
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 技能部分
//   Widget _buildSkillsSection(BuildContext context) {
//     final skills = [
//       'Flutter',
//       'Dart',
//       'Firebase',
//       'REST API',
//       'Git',
//       'HTML',
//       'CSS',
//       'JavaScript'
//     ]; // 你的技能列表
//
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '技能',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 10),
//           Wrap(
//             spacing: 8.0,
//             runSpacing: 4.0,
//             children: skills.map((skill) => Chip(label: Text(skill))).toList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 经历部分
//   Widget _buildExperienceSection(BuildContext context) {
//     final experiences = [
//       {
//         'title': '公司名称',
//         'subtitle': '职位',
//         'date': '2022 - Present',
//         'description': '工作描述...'
//       },
//       {
//         'title': '另一家公司',
//         'subtitle': '另一个职位',
//         'date': '2020 - 2022',
//         'description': '另一份工作的描述...'
//       },
//     ];
//
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '经历',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 10),
//           ...experiences.map((exp) => Card(
//                 elevation: 2,
//                 child: ListTile(
//                   title: Text(exp['title']!),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(exp['subtitle']!),
//                       Text(
//                         exp['date']!,
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                       SizedBox(height: 4),
//                       Text(exp['description']!),
//                     ],
//                   ),
//                   isThreeLine: true,
//                 ),
//               )),
//         ],
//       ),
//     );
//   }
//
//   // 社交媒体部分
//   Widget _buildSocialSection(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '社交媒体',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               IconButton(
//                 icon: Icon(Icons.link),
//                 onPressed: () {
//                   _launchURL(
//                       'https://www.github.com/你的GitHub'); // 替换成你的 GitHub 链接
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.email),
//                 onPressed: () {
//                   _launchURL('mailto:你的邮箱地址'); // 替换成你的邮箱地址
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.web),
//                 onPressed: () {
//                   _launchURL('https://你的个人网站'); // 替换成你的个人网站链接
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 打开链接
//   _launchURL(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: '个人主页',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'Roboto',
//       ),
//       home: ProfilePage(),
//     );
//   }
// }
//
// class ProfilePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           _buildSliverAppBar(context),
//           SliverList(
//             delegate: SliverChildListDelegate(
//               [
//                 _buildProfileInfo(context),
//                 _buildSkillsSection(context),
//                 _buildExperienceSection(context),
//                 _buildSocialSection(context),
//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   //  SliverAppBar with Animated Avatar
//   Widget _buildSliverAppBar(BuildContext context) {
//     // 获取Leading区域的宽度
//     final double leadingWidth = kToolbarHeight; // 假设Leading区域宽度等于toolbar高度
//
//     return SliverAppBar(
//       expandedHeight: 250.0,
//       floating: false,
//       pinned: true,
//       leading: SizedBox(), // 占位，稍后在动画中添加
//       flexibleSpace: LayoutBuilder(
//         builder: (BuildContext context, BoxConstraints constraints) {
//           double top = constraints.biggest.height;
//           double avatarSize = 120;
//           double minAvatarSize = 36; // 最小头像
//           double currentAvatarSize = avatarSize * (top / 250);
//           if (currentAvatarSize < minAvatarSize)
//             currentAvatarSize = minAvatarSize;
//
//           //  计算动画进度
//           double animationProgress = (250 - top) / (250 - kToolbarHeight);
//           if (animationProgress < 0) animationProgress = 0;
//           if (animationProgress > 1) animationProgress = 1;
//           // 计算头像位置, 当appbar完全展开时，头像在底部中央，当appbar收缩时，头像在左上角
//
//           double avatarLeft = 0;
//
//           if (animationProgress < 1) {
//             avatarLeft = (MediaQuery.of(context).size.width / 2 -
//                     currentAvatarSize / 2) *
//                 (1 - animationProgress);
//           } else {
//             avatarLeft = 10; //移动到leading区域的左上角 可以调整10 来控制边缘
//           }
//
//           double avatarBottom = 20 * (1 - animationProgress);
//
//           // 动画
//           return FlexibleSpaceBar(
//             centerTitle: true,
//             title: Opacity(
//               opacity: top <= kToolbarHeight ? 1.0 : 0.0,
//               child: Text(
//                 "我的主页",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16.0,
//                 ),
//               ),
//             ),
//             background: Stack(
//               fit: StackFit.expand,
//               children: [
//                 Image.network(
//                   "https://images.unsplash.com/photo-1541701496583-0a94ca585fe8?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1974&q=80",
//                   fit: BoxFit.cover,
//                 ),
//                 // 过渡动画
//                 Positioned(
//                   // left: avatarLeft,
//                   left: 19.8,
//                   top: avatarBottom + 88,
//                   child: TweenAnimationBuilder(
//                     tween: Tween<double>(
//                         begin: avatarSize, end: currentAvatarSize),
//                     duration: Duration(milliseconds: 200),
//                     builder:
//                         (BuildContext context, double size, Widget? child) {
//                       return Row(
//                         children: [
//                           SizedBox(
//                             width: size - 10,
//                             height: size - 10,
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(size / 2),
//                               child: Image.network(
//                                 'https://avatars.githubusercontent.com/u/66918811?v=4',
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 10),
//                           SizedBox(
//                               width: 50,
//                               child: Column(
//                                 spacing: 5,
//                                 children: [
//                                   SizedBox(height: 36),
//                                   Text('你好'),
//                                   Text('名字'),
//                                 ],
//                               )),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//                 // 返回按钮的动画
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   child: Opacity(
//                     opacity: animationProgress,
//                     child: IconButton(
//                       icon: Icon(Icons.arrow_back, color: Colors.white),
//                       onPressed: () {
//                         // 返回逻辑
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // 个人信息部分
//   Widget _buildProfileInfo(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(height: 16),
//           Text(
//             '你的名字',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             '职位 / 简介',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey[600],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.location_on, color: Colors.grey[600]),
//               SizedBox(width: 4),
//               Text('你的城市, 国家'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 技能部分
//   Widget _buildSkillsSection(BuildContext context) {
//     final skills = [
//       'Flutter',
//       'Dart',
//       'Firebase',
//       'REST API',
//       'Git',
//       'HTML',
//       'CSS',
//       'JavaScript'
//     ];
//
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '技能',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 10),
//           Wrap(
//             spacing: 8.0,
//             runSpacing: 4.0,
//             children: skills.map((skill) => Chip(label: Text(skill))).toList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 经历部分
//   Widget _buildExperienceSection(BuildContext context) {
//     final experiences = [
//       {
//         'title': '公司名称',
//         'subtitle': '职位',
//         'date': '2022 - Present',
//         'description': '工作描述...'
//       },
//       {
//         'title': '另一家公司',
//         'subtitle': '另一个职位',
//         'date': '2020 - 2022',
//         'description': '另一份工作的描述...'
//       },
//     ];
//
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '经历',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 10),
//           ...experiences.map((exp) => Card(
//                 elevation: 2,
//                 child: ListTile(
//                   title: Text(exp['title']!),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(exp['subtitle']!),
//                       Text(
//                         exp['date']!,
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                       SizedBox(height: 4),
//                       Text(exp['description']!),
//                     ],
//                   ),
//                   isThreeLine: true,
//                 ),
//               )),
//         ],
//       ),
//     );
//   }
//
//   // 社交媒体部分
//   Widget _buildSocialSection(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '社交媒体',
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               IconButton(
//                 icon: Icon(Icons.link),
//                 onPressed: () {
//                   _launchURL('https://www.github.com/你的GitHub');
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.email),
//                 onPressed: () {
//                   _launchURL('mailto:你的邮箱地址');
//                 },
//               ),
//               IconButton(
//                 icon: Icon(Icons.web),
//                 onPressed: () {
//                   _launchURL('https://你的个人网站');
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 打开链接
//   _launchURL(String url) async {
//     final Uri uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }
// }
