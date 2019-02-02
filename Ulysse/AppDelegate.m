#import "AppDelegate.h"

#import <AudioToolbox/AudioToolbox.h>
#import <GameController/GameController.h>
#include <math.h>

#import "Config.h"
#import "Ulysse.h"
#import "GamepadController.h"

#import "Ulysse-Swift.h"

static NSString *kBoatNameKey = @"BoatName";
static NSString *kMotorCoefKey = @"MotorCoef";

@implementation AppDelegate

@synthesize config = _config;
@synthesize gamepadController = _gamepadController;
@synthesize ulysse = _ulysse;

+ (NSString *)stringWithTimestamp:(NSTimeInterval)timestamp {
  return [self stringWithDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
}

+ (NSString *)stringWithDate:(NSDate *)date {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  formatter.timeZone = [NSTimeZone defaultTimeZone];
  formatter.dateFormat = @"dd/MM/yyyy, HH:mm:ss";
  return [formatter stringFromDate:date];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  _config = [Config sharedInstance];
  [_config addObserver:self forKeyPath:@"boatName" options:NSKeyValueObservingOptionNew context:nil];
  self.modules = [[Modules alloc] init];
  self.ulysse = [[Ulysse alloc] initWithConfig:_config modules:self.modules];
  [self loadPreferences];
  // Blocking iOS to go to sleep.
  UIApplication.sharedApplication.idleTimerDisabled = YES;
  [self.ulysse open];
  self.gamepadController = [[GamepadController alloc] init];
  self.gamepadController.ulysse = self.ulysse;
  self.gamepadController.config = self.config;
  return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
  return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (Config *)config {
  return _config;
}

- (void)setMotorCoef:(float)motorCoef {
  [NSUserDefaults.standardUserDefaults setFloat:motorCoef forKey:kMotorCoefKey];
  [NSUserDefaults.standardUserDefaults synchronize];
  [_ulysse setMotorCoef:motorCoef];
}

- (float)motorCoef {
  return _ulysse.motorCoef;
}

- (void)addAlert:(Alert)alert {
  _alert |= alert;
}

- (void)removeAlert:(Alert)alert {
  alert &= ~alert;
}

#pragma mark - Private

- (void)loadPreferences {
  NSUserDefaults *standardUserDefaults = NSUserDefaults.standardUserDefaults;
  NSString *boatName = [standardUserDefaults objectForKey:kBoatNameKey];
  if (boatName) {
    _config.boatName = boatName;
  }
  float motorCoef = [standardUserDefaults floatForKey:kMotorCoefKey];
  if (motorCoef <= 0 || motorCoef > 1.0) {
    motorCoef = 0.5;
  }
  _ulysse.motorCoef = motorCoef;
}

- (void)updateBoat {
  [[NSUserDefaults standardUserDefaults] setObject:_config.boatName forKey:kBoatNameKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
  if (object == _config) {
    [self updateBoat];
  }
}

@end
