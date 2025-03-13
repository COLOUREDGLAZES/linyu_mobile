import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

    // 创建 MethodChannel
    let channel = FlutterMethodChannel(
      name: "com.example.app/ios_channel",
      binaryMessenger: controller.binaryMessenger
    )

    // 设置方法调用处理器
    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      self.handleMethodCall(call, result: result)
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 处理方法调用
  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getDeviceInfo":
      let deviceName = UIDevice.current.name
      result(deviceName)
    case "receiveData":
      if let args = call.arguments as? [String: Any] {
        print("Received data from Flutter: \(args)")
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Data format error", details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
