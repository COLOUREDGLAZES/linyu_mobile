import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linyu_mobile/components/custom_flutter_toast/index.dart';
import 'package:linyu_mobile/utils/config/getx/global_theme_config.dart';

typedef UploadPictureCallback = Future<void> Function(File picture);

//图片剪切
void cropPicture(ImageSource? type, UploadPictureCallback uploadPicture,
    {isVariable = false}) async {
  try {
    final GlobalThemeConfig theme = GetInstance().find<GlobalThemeConfig>();
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: type ?? ImageSource.gallery);
    if (kDebugMode) print("pickedFile: ${pickedFile?.path}");
    if (pickedFile == null) return;
    File? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatioPresets: [
        isVariable
            ? CropAspectRatioPreset.original
            : CropAspectRatioPreset.square,
      ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: '剪切',
        toolbarWidgetColor: theme.primaryColor,
        dimmedLayerColor: Colors.black54,
        cropFrameColor: theme.primaryColor,
        activeControlsWidgetColor: theme.primaryColor,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: !isVariable,
      ),
      iosUiSettings: const IOSUiSettings(
        title: '剪切',
        cancelButtonTitle: '取消',
        doneButtonTitle: '完成',
      ),
    );

    if (croppedFile != null) await uploadPicture(croppedFile);
  } catch (e) {
    // 适当处理错误，例如弹出提示
    if (kDebugMode) print("图片剪切失败: ${e.toString()}");
    // 可以添加更多的错误处理逻辑
    CustomFlutterToast.showErrorToast("图片剪切失败: ${e.toString()}");
  }
}

//图片剪切
// void cropPicture(ImageSource? type, UploadPictureCallback uploadPicture,
//     {isVariable = false}) async {
//   final GlobalThemeConfig theme = GetInstance().find<GlobalThemeConfig>();
//   final ImagePicker picker = ImagePicker();
//   final XFile? pickedFile =
//       await picker.pickImage(source: type ?? ImageSource.gallery);
//   if (pickedFile == null) return;
//   File? croppedFile = await ImageCropper().cropImage(
//     sourcePath: pickedFile.path,
//     aspectRatioPresets: Platform.isAndroid
//         ? [
//             isVariable
//                 ? CropAspectRatioPreset.original
//                 : CropAspectRatioPreset.square,
//             // CropAspectRatioPreset.ratio3x2,
//             // CropAspectRatioPreset.ratio4x3,
//             // CropAspectRatioPreset.ratio16x9
//           ]
//         : [
//             isVariable
//                 ? CropAspectRatioPreset.original
//                 : CropAspectRatioPreset.square,
//             // CropAspectRatioPreset.ratio3x2,
//             // CropAspectRatioPreset.ratio4x3,
//             // CropAspectRatioPreset.ratio5x3,
//             // CropAspectRatioPreset.ratio5x4,
//             // CropAspectRatioPreset.ratio7x5,
//             // CropAspectRatioPreset.ratio16x9
//           ],
//     androidUiSettings: AndroidUiSettings(
//       toolbarTitle: '剪切',
//       // toolbarColor: Colors.deepOrange,
//       toolbarWidgetColor: theme.primaryColor,
//       dimmedLayerColor: Colors.black54,
//       cropFrameColor: theme.primaryColor,
//       activeControlsWidgetColor: theme.primaryColor,
//       initAspectRatio: CropAspectRatioPreset.original,
//       lockAspectRatio: !isVariable,
//     ),
//     iosUiSettings: const IOSUiSettings(
//       title: '剪切',
//     ),
//   );
//   if (croppedFile != null) {
//     pickedFile.path.split("/");
//     uploadPicture(croppedFile);
//   }
// }
