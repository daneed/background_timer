#import "BackgroundTimerPlugin.h"

static FlutterMethodChannel* channel;

@implementation BackgroundTimerPlugin {
  UIBackgroundTaskIdentifier bgTask;
  dispatch_source_t timer;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  channel = [FlutterMethodChannel methodChannelWithName: @"background_timer"
                                        binaryMessenger: [registrar messenger]];
  BackgroundTimerPlugin* instance = [[BackgroundTimerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel: channel];
}

-(id)init {
  bgTask = UIBackgroundTaskInvalid;
  timer = nil;
  return self;
  
}

- (void) handleMethodCall:(FlutterMethodCall*) call result: (FlutterResult) result {
  if ([@"lowLevelHandlingEnabled" isEqualToString: call.method]) {
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
    result([NSNumber numberWithBool:[self isBackgroundTimerRunning]]);
  } else {
     result(nil);
  }
}

- (void) runBackgroundTimer: (NSInteger) currentId
                      delay: (NSInteger) timeout
{
  NSLog ([NSString stringWithFormat:@"runBackgroundTimer called, timeout: %d", timeout]);
  if([self isBackgroundTimerRunning]) {
    [channel invokeMethod:@"BackgroundTimerAck" arguments: @{@"msg": @" run FAILED, it is already running"}];
  } else {
    [channel invokeMethod:@"BackgroundTimerAck" arguments: @{@"msg": @" run SUCCEED, starting timer"}];
    [self startTimer:currentId delay: timeout];
  }
}

- (void) stopBackgroundTimer {
  NSLog (@"stopBackgroundTimer called");
  if([self isBackgroundTimerRunning]) {
    [channel invokeMethod:@"BackgroundTimerAck" arguments: @{@"msg": @" stop OK"}];
    dispatch_cancel (timer);
    timer = nil;
    [[UIApplication sharedApplication] endBackgroundTask: bgTask];
    bgTask = UIBackgroundTaskInvalid;
  } else {
    [channel invokeMethod:@"BackgroundTimerAck" arguments: @{@"msg": @" stop FAILED, it is stopped"}];
  }
}

- (BOOL) isBackgroundTimerRunning
{
  return bgTask != UIBackgroundTaskInvalid && timer != nil;
}

- (void) startTimer : (NSInteger) currentId
           delay : (NSInteger) timeout
{
  bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"BackgroundTimer" expirationHandler: ^{
    [channel invokeMethod:@"BackgroundTimerAck" arguments: @{@"msg": @" stopped via expiratioHandler"}];
    dispatch_cancel (timer);
    timer = nil;
    [[UIApplication sharedApplication] endBackgroundTask: bgTask];
    bgTask = UIBackgroundTaskInvalid;
  }];
  if (bgTask != UIBackgroundTaskInvalid) {
    dispatch_queue_t queue = dispatch_queue_create("com.daneed.background_timer", 0);
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 1000 * NSEC_PER_MSEC), timeout * NSEC_PER_MSEC, 0.1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
      if (bgTask != UIBackgroundTaskInvalid) {
        [channel invokeMethod:@"callback" arguments: @ {@"id": [NSNumber numberWithInt : currentId]}];
      }
    });
    dispatch_resume(timer);
  }
}

@end
