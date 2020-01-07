#import "IosBackgroundTimerPlugin.h"
#if __has_include(<ios_background_timer/ios_background_timer-Swift.h>)
#import <ios_background_timer/ios_background_timer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ios_background_timer-Swift.h"
#endif

@implementation IosBackgroundTimerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftIosBackgroundTimerPlugin registerWithRegistrar:registrar];
}
@end
