#import <UIKit/UIKit.h>

@class Config;
@class Domains;
@class GamepadController;
@class PListCommunication;

typedef NS_OPTIONS(NSUInteger, Alert) {
  WaterAlert = 1 << 0,
  GpsLowSatelliteAlert = 1 << 1,
  GpsNoSatelliteAlert = 1 << 2,
  BoatLowConnectionAlert = 1 << 3,
  BoatNoConnectionAlert = 1 << 4,
  NoValuesAlert = 1 << 5,
  iPhoneNoConnectionAlert = 1 << 6,
  EscTemperatureAlert = 1 << 7,
  LowVoltageAlert = 1 << 8,
  HighAmperAlert = 1 << 9,
  PiTemperatureAlert = 1 << 10,
  PiCpuAlert = 1 << 11,
};

typedef NS_ENUM(NSUInteger, AlertLevel) {
  NoAlertLevel,
  LowAlertLevel,
  MediumAlertLeve,
  HighAlertLevel,
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(nonatomic, strong, readonly) Config *config;
@property(nonatomic, strong, readonly) PListCommunication *communication;
@property(nonatomic, strong) UIWindow *window;
@property(nonatomic) float motorCoef;
@property(nonatomic, readonly) Alert alert;
@property(nonatomic, strong, readonly) GamepadController *gamepadController;
@property(nonatomic, strong, readonly) Domains *domains;

+ (NSString *)stringWithTimestamp:(NSTimeInterval)timestamp;
+ (NSString *)stringWithDate:(NSDate *)date;

- (void)addAlert:(Alert)alert;
- (void)removeAlert:(Alert)alert;

@end
