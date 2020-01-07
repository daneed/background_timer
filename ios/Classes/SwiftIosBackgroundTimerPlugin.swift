import Flutter
import UIKit

public class SwiftIosBackgroundTimerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var _eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ios_background_timer", binaryMessenger: registrar.messenger())
    let instance = SwiftIosBackgroundTimerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }

  public func onListen (withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink ) -> FlutterError? {
    _eventSink = events
    return nil
  }

  public func onCancel (withArguments arguments: Any?) -> FlutterError? {
    _eventSink = nil
    return nil
  }
}
