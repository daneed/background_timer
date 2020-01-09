#import "IosBackgroundTimerPlugin.h"

static FlutterMethodChannel* channel;

@implementation IosBackgroundTimerPlugin {
  UIBackgroundTaskIdentifier bgTask;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  channel = [FlutterMethodChannel methodChannelWithName: @"ios_background_timer"
                                        binaryMessenger: [registrar messenger]];
  IosBackgroundTimerPlugin* instance = [[IosBackgroundTimerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel: channel];
}

-(id)init {
  bgTask = UIBackgroundTaskInvalid;
  return self;
}

- (void) handleMethodCall:(FlutterMethodCall*) call result: (FlutterResult) result {
  if (@"lowLevelHandlingEnabled" isEqualToString: call.method]) {
      result([NSNumber numberWithBool:true]);
  } else if ([@"runBackgroundTimer" isEqualToString: call.method]) {
    NSNumber* currentId = call.arguments[@"id"];
    NSNumber* delay = call.arguments[@"delay"];
    [self runBackgroundTimer : [currentId integerValue] delay: [delay integerValue]];
     result(nil);
  } else if ([@"stopBackgroundTimer" isEqualToString: call.method]) {
    [self stopBackgroundTimer];
     result(nil);
  } else if ([@"isBackgroundTimerRunning" isEqualToString: call.method]) {
    result([NSNumber numberWithBool:(bgTask != UIBackgroundTaskInvalid)]);
  } else {
     result(nil);
  }
}

- (void) runBackgroundTimer: (NSInteger) currentId
                      delay: (NSInteger) timeout
{
  NSLog ([NSString stringWithFormat:@"runBackgroundTimer called, timeout: %d", timeout]);
  if(bgTask != UIBackgroundTaskInvalid) {
    [channel invokeMethod:@"IosBackgroundTimerAck" arguments: @{@"msg": @" run FAILED, it is already running"}];
  } else {
    [channel invokeMethod:@"IosBackgroundTimerAck" arguments: @{@"msg": @" run SUCCEED, starting timer"}];
    [self timeout:currentId delay: timeout];
  }
}

- (void) stopBackgroundTimer {
  NSLog (@"stopBackgroundTimer called");
  if(bgTask != UIBackgroundTaskInvalid) {
    [channel invokeMethod:@"IosBackgroundTimerAck" arguments: @{@"msg": @" stop OK"}];
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
  } else {
    [channel invokeMethod:@"IosBackgroundTimerAck" arguments: @{@"msg": @" stop FAILED, it is stopped"}];
  }
}

- (void) timeout : (NSInteger) currentId
           delay : (NSInteger) timeout
{
  bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"IosBackgroundTimer" expirationHandler:^{
    [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
  }];

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeout * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
    if(bgTask != UIBackgroundTaskInvalid) {
      [channel invokeMethod:@"callback" arguments: @ {@"id": [NSNumber numberWithInt : currentId]}];
      [self timeout:currentId delay: timeout];
    }
  });
}

@end
