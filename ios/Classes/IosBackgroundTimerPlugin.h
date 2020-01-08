#import <Flutter/Flutter.h>

@interface IosBackgroundTimerPlugin : NSObject<FlutterPlugin>;

- (void) runBackgroundTimer: (NSInteger) currentId
                      delay: (NSInteger) timeout;

- (void) stopBackgroundTimer;

@end
