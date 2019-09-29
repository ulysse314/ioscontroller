#import "GamepadController.h"

#import <GameController/GameController.h>

#include "Config.h"
#include "Ulysse.h"

#define PLAYER_INDEX_START_FLASH_TIMER 0.25
#define PLAYER_INDEX_SLOW_FLASH_TIMER 1.
#define PLAYER_INDEX_FAST_FLASH_TIMER .5

@interface GamepadController() {
  NSTimer *_timer;
}

@property(nonatomic, strong) GCController *gameController;
@end

@implementation GamepadController

@synthesize config = _config;
@synthesize gameController = _gameController;
@synthesize ulysse = _ulysse;
@synthesize playerIndexFlash = _playerIndexFlash;

- (instancetype)init {
  self = [super init];
  if (self) {
    _playerIndexFlash = StillPlayerIndexFlash;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameControllerDidConnect:)
                                                 name:GCControllerDidConnectNotification
                                               object:nil];
  }
  return self;
}

- (void)setConfig:(Config *)config {
  if (_config) {
    [_config removeObserver:self forKeyPath:@"boatName" context:nil];
  }
  _config = config;
  if (_config) {
    [_config addObserver:self forKeyPath:@"boatName" options:NSKeyValueObservingOptionNew context:nil];
  }
}

#pragma mark - Private

- (void)updatePlayerIndex {
  NSInteger index = [self.config.boatNameList indexOfObject:self.config.boatName];
  self.gameController.playerIndex = index;
}

- (void)setPlayerIndexTimer {
  BOOL playerIndexOn = self.gameController.playerIndex != GCControllerPlayerIndexUnset;
  NSTimeInterval nextTimer = -1;
  switch (self.playerIndexFlash) {
    case StillPlayerIndexFlash:
      break;
    case SlowPlayerIndexFlash:
      nextTimer = PLAYER_INDEX_SLOW_FLASH_TIMER;
      break;
    case FastPlayerIndexFlash:
      nextTimer = PLAYER_INDEX_FAST_FLASH_TIMER;
      break;
  }
  if (playerIndexOn) {
    self.gameController.playerIndex = GCControllerPlayerIndexUnset;
  } else {
    [self updatePlayerIndex];
  }
  if (nextTimer > 0) {
    _timer = [NSTimer scheduledTimerWithTimeInterval:nextTimer target:self selector:@selector(setPlayerIndexTimer) userInfo:nil repeats:NO];
  }
}

- (void)smallPlayerIndexFlash {
  self.gameController.playerIndex = GCControllerPlayerIndexUnset;
  [_timer invalidate];
  _timer = [NSTimer scheduledTimerWithTimeInterval:PLAYER_INDEX_START_FLASH_TIMER target:self selector:@selector(setPlayerIndexTimer) userInfo:nil repeats:NO];
}

- (void)updateMotorWithGamepad {
  float xValue = self.gameController.extendedGamepad.rightThumbstick.xAxis.value;
  float yValue = self.gameController.extendedGamepad.rightThumbstick.yAxis.value;
  [self updateMotorWithXValue:xValue yValue:yValue];
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
  [self.ulysse setLeftMotor:leftMotor rightMotor:rightMotor];
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
  if (object == self.config) {
    if (self.gameController.playerIndex != GCControllerPlayerIndexUnset) {
      [self updatePlayerIndex];
    }
  }
}

#pragma mark - Game controller notification

- (void)gameControllerDidConnect:(NSNotification *)notification {
  if (self.gameController) {
    return;
  }
  self.gameController = notification.object;
  __weak __typeof(self) weakSelf = self;
  self.gameController.extendedGamepad.buttonMenu.valueChangedHandler = ^(GCControllerButtonInput * _Nonnull button, float value, BOOL pressed) {
    if (pressed) {
      [weakSelf smallPlayerIndexFlash];
    }
  };
  self.gameController.extendedGamepad.rightThumbstick.valueChangedHandler = ^(GCControllerDirectionPad * _Nonnull dpad, float xValue, float yValue) {
    [self updateMotorWithGamepad];
  };
  self.gameController.extendedGamepad.rightTrigger.valueChangedHandler = ^(GCControllerButtonInput * _Nonnull button, float value, BOOL pressed) {
    self.ulysse.extraMotorCoef = value;
  };
  self.gameController.extendedGamepad.rightShoulder.valueChangedHandler = ^(GCControllerButtonInput * _Nonnull button, float value, BOOL pressed) {
    [self.ulysse setValues: @{ @"led": @{ @"right%": pressed ? @(100) : @(0) }}];
  };
  self.gameController.extendedGamepad.leftShoulder.valueChangedHandler = ^(GCControllerButtonInput * _Nonnull button, float value, BOOL pressed) {
    [self.ulysse setValues: @{ @"led": @{ @"left%": pressed ? @(100) : @(0) }}];
  };
  [self updateMotorWithGamepad];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameControllerDidDisconnected:) name:GCControllerDidDisconnectNotification object:self.gameController];
  [weakSelf smallPlayerIndexFlash];
}

- (void)gameControllerDidDisconnected:(NSNotification *)notification {
  NSAssert(self.gameController == notification.object, @"Unknown game controller");
  [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:notification.object];
  self.gameController = nil;
  [self updateMotorWithXValue:0 yValue:0];
}

@end
