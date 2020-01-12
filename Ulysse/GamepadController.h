#import <Foundation/Foundation.h>

@class Config;
@class Ulysse;

typedef enum {
  StillPlayerIndexFlash,
  SlowPlayerIndexFlash,
  FastPlayerIndexFlash,
} PlayerIndexFlash;

@interface GamepadController : NSObject

@property(nonatomic, weak) Config *config;
@property(nonatomic, weak) Ulysse *ulysse;
@property(nonatomic) PlayerIndexFlash playerIndexFlash;
@property(nonatomic, readonly) BOOL isConnected;

- (void)updateMotorWithGamepad;
- (void)stopMotors;

@end
