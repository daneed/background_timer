#import "IosBackgroundTimerPlugin.h"

static FlutterMethodChannel* channel;

@implementation IosBackgroundTimerPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  channel = [FlutterMethodChannel methodChannelWithName: @"ios_background_timer"
                                        binaryMessenger: [registrar messenger]];
  IosBackgroundTimerPlugin* instance = [[IosBackgroundTimerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel: channel];
}

- (void) handleMethodCall:(FlutterMethodCall*) call result: (FlutterResult) result {
    if ([@"runBackgroundTimer" isEqualToString: call.method]) {
        NSNumber* delay = call.arguments[@"delay"];
        NSLog ([NSString stringWithFormat:@"runBackgroundTimer called, delay: %d", [delay integerValue]]);

        [channel invokeMethod:@"runBackgroundTimerAck"
                    arguments: nil];

    } else if ([@"stopBackgroundTimer" isEqualToString: call.method]) {
        NSLog (@"stopBackgroundTimer called");

        [channel invokeMethod:@"stopBackgroundTimerAck"
                    arguments: nil];
    } else {
        NSLog ([NSString stringWithFormat:@"%@ called", call.method]);
    }

    result ([NSString stringWithFormat:@"%@ %@", @"iOS", [[UIDevice currentDevice] systemVersion]]);
  }

@end
