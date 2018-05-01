#import "AppDelegate.h"

#import <AudioToolbox/AudioToolbox.h>
#import <GameController/GameController.h>
#include <math.h>

#import "Ulysse.h"
#import "Config.h"

static NSString *kBoatNameKey = @"BoatName";
static NSString *kMotorCoefKey = @"MotorCoef";

@interface AppDelegate () {
  UIView *_alertView;
}

@end

@implementation AppDelegate

@synthesize config = _config;
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
  self.ulysse = [[Ulysse alloc] initWithConfig:_config];
  [self loadPreferences];
  UIApplication.sharedApplication.idleTimerDisabled = YES;
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(ulysseWaitingCount:) name:UlysseWaitedTooLong object:_ulysse];
  [self.ulysse open];
  _alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
  _alertView.backgroundColor = UIColor.redColor;
  _alertView.alpha = 0;
  UIView *superview = self.window.rootViewController.view;
  [superview addSubview:_alertView];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(gameControllerDidConnect:)
                                               name:GCControllerDidConnectNotification
                                             object:nil];
  return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
  return UIInterfaceOrientationMaskAll;
}

- (void)ulysseWaitingCount:(NSNotification *)notification {
  if (self.ulysse.waitingTooLong) {
    if (_alertView.alpha == 0) {
//      AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
      _alertView.alpha = 0.4;
    }
  } else {
    _alertView.alpha = 0;
  }
}

- (Config *)config {
  return _config;
}

- (void)updateMotorWithXValue:(float)xValue yValue:(float)yValue {
  float angle = atan2f(yValue, xValue);
  float power = sqrtf(xValue * xValue + yValue * yValue);
  if (power > 1.0) {
    power = 1.0;
  }
  float rightMotor = 0;
  float leftMotor = 0;
  const float pi = 3.14159265358979323846;
  if (pi / 2.0 <= angle && angle <= pi * 3.0 / 4.0) {
    // N / NE => 1 0 / 1
    leftMotor = 1 - (angle - pi / 2.0) / (pi / 4.0);
    rightMotor = 1;
  } else if (pi * 3.0 / 4.0 <= angle) {
    // NE / E => 0 -1 / 1
    leftMotor = -(angle - 3.0 * pi / 4.0) / (pi / 4.0);
    rightMotor = 1;
  } else if (angle <= -pi * 3.0 / 4.0) {
    // E / SE => -1 / 1 0
    leftMotor = -1;
    rightMotor = 1 - (angle + pi) / (pi / 4.0);
  } else if (-pi * 3.0 / 4.0 <= angle && angle <= -pi / 2.0) {
    // SE / S => -1 / 0 -1
    leftMotor = -1;
    rightMotor = - (angle + 3.0 * pi / 4.0) / (pi / 4.0);
  } else if (-pi / 2.0 <= angle && angle <= -pi / 4.0) {
    // S / SW => -1 0 / -1
    leftMotor = -1 + (angle + pi / 2.0) / (pi / 4.0);
    rightMotor = -1;
  } else if (-pi / 4.0 <= angle && angle <= 0) {
    // SW / W => 0 1 / -1
    leftMotor = angle + pi / 4.0;
    rightMotor = -1;
  } else if (0 <= angle && angle <= pi / 4.0) {
    // W / NW => 1 / -1 0
    leftMotor = 1;
    rightMotor = -1 + angle / (pi / 4.0);
  } else if (pi / 4.0 <= angle && angle <= pi / 2.0) {
    // NW / N => 1 / 0 -1
    leftMotor = 1;
    rightMotor = (angle - pi / 4.0) / (pi / 4.0);
  } else {
    DEBUGLOG(@"pourri");
  }
  leftMotor *= power;
  rightMotor *= power;
  [_ulysse setLeftMotor:leftMotor rightMotor:rightMotor];
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
  NSInteger index = [_config.boatNameList indexOfObject:_config.boatName];
  dispatch_async(dispatch_get_main_queue(), ^{
    self.gameController.playerIndex = index;
  });
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
  if (object == _config) {
    [self updateBoat];
  }
}

#pragma mark - Game controller notification

- (void)gameControllerDidConnect:(NSNotification *)notification {
  if (self.gameController) {
    return;
  }
  self.gameController = notification.object;
  self.gameController.controllerPausedHandler = ^(GCController * _Nonnull controller) {
  };
  self.gameController.extendedGamepad.rightThumbstick.valueChangedHandler = ^(GCControllerDirectionPad * _Nonnull dpad, float xValue, float yValue) {
    [self updateMotorWithXValue:xValue yValue:yValue];
  };
  self.gameController.extendedGamepad.rightTrigger.valueChangedHandler = ^(GCControllerButtonInput * _Nonnull button, float value, BOOL pressed) {
    _ulysse.extraMotorCoef = value;
  };
  self.gameController.extendedGamepad.rightShoulder.valueChangedHandler = ^(GCControllerButtonInput * _Nonnull button, float value, BOOL pressed) {
    [_ulysse setValues: @{ @"led": @{ @"right%": pressed ? @(100) : @(0) }}];
  };
  self.gameController.extendedGamepad.leftShoulder.valueChangedHandler = ^(GCControllerButtonInput * _Nonnull button, float value, BOOL pressed) {
    [_ulysse setValues: @{ @"led": @{ @"left%": pressed ? @(100) : @(0) }}];
  };
  [self updateBoat];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameControllerDidDisconnected:) name:GCControllerDidDisconnectNotification object:self.gameController];
}

- (void)gameControllerDidDisconnected:(NSNotification *)notification {
  NSAssert(self.gameController == notification.object, @"Unknown game controller");
  [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:notification.object];
  self.gameController = nil;
}

@end
