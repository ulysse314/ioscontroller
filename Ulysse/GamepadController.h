#import <Foundation/Foundation.h>

@class Config;
@class GamepadController;
@class MainViewLayoutController;
@class Ulysse;

typedef enum {
  StillPlayerIndexFlash,
  SlowPlayerIndexFlash,
  FastPlayerIndexFlash,
} PlayerIndexFlash;

@protocol GamepadControllerDelegate <NSObject>

- (void)gamepadController:(GamepadController *)gamepadController isConnected:(BOOL)isConnected;
- (void)gamepadControllerMapButtonPressed:(GamepadController *)gamepadController;
- (void)gamepadControllerTurnOnLEDs:(GamepadController *)gamepadController;
- (void)gamepadControllerTurnOffLEDs:(GamepadController *)gamepadController;

@end

@interface GamepadController : NSObject

@property(nonatomic, weak) Config *config;
@property(nonatomic, weak) Ulysse *ulysse;
@property(nonatomic) PlayerIndexFlash playerIndexFlash;
@property(nonatomic, readonly) BOOL isConnected;
@property(nonatomic, weak) id<GamepadControllerDelegate> delegate;

- (void)updateMotorWithGamepad;
- (void)stopMotors;

@end
