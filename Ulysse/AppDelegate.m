#import "AppDelegate.h"

#import <AudioToolbox/AudioToolbox.h>
#import <GameController/GameController.h>
#import <math.h>

#import "Config.h"
#import "GamepadController.h"
#import "PListCommunication.h"

#import "Ulysse-Swift.h"

static NSString *kBoatNameKey = @"BoatName";
static NSString *kMotorCoefKey = @"MotorCoef";

@interface AppDelegate ()

@property(nonatomic, strong, readwrite) Config *config;
@property(nonatomic, strong, readwrite) PListCommunication *communication;
@property(nonatomic, strong, readwrite) GamepadController *gamepadController;
@property(nonatomic, strong, readwrite) Boat *boat;
@property(nonatomic, strong) ConnectionController *connectionController;

@end

@implementation AppDelegate

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
  [UIDevice currentDevice].batteryMonitoringEnabled = YES;
  self.config = [Config sharedInstance];
  [self.config addObserver:self forKeyPath:@"boatName" options:NSKeyValueObservingOptionNew context:nil];
  self.boat = [[Boat alloc] init];
  self.connectionController = [[ConnectionController alloc] initWithConfig:self.config];
  self.communication = [[PListCommunication alloc] initWithConnectionController:self.connectionController boat:self.boat];
  [self loadPreferences];
  // Blocking iOS to go to sleep.
  UIApplication.sharedApplication.idleTimerDisabled = YES;
  [self.communication open];
  self.gamepadController = [[GamepadController alloc] init];
  self.gamepadController.communication = self.communication;
  self.gamepadController.config = self.config;
  return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  [self.gamepadController updateMotorWithGamepad];
}

- (void)applicationWillResignActive:(UIApplication *)application {
  [self.gamepadController stopMotors];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
  return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (void)setMotorCoef:(float)motorCoef {
  [NSUserDefaults.standardUserDefaults setFloat:motorCoef forKey:kMotorCoefKey];
  [NSUserDefaults.standardUserDefaults synchronize];
  [self.communication setMotorCoef:motorCoef];
}

- (float)motorCoef {
  return self.communication.motorCoef;
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
    self.config.boatName = boatName;
  }
  float motorCoef = [standardUserDefaults floatForKey:kMotorCoefKey];
  if (motorCoef <= 0 || motorCoef > 1.0) {
    motorCoef = 0.5;
  }
  self.communication.motorCoef = motorCoef;
}

- (void)updateBoat {
  [[NSUserDefaults standardUserDefaults] setObject:self.config.boatName forKey:kBoatNameKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
  if (object == self.config) {
    [self updateBoat];
  }
}

@end
