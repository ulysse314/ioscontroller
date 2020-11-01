#import <Foundation/Foundation.h>

#import "Communication.h"

#if TARGET_OS_SIMULATOR
#define DEBUGLOG NSLog
#else
#define DEBUGLOG(x,...)
#endif

extern NSString *UlysseValuesDidUpdate;

@class Boat;
@class Config;

@class ConnectionController;

@interface PListCommunication : NSObject<Communication>

@property(nonatomic, readonly) NSDictionary<NSString *, id> *allValues;
@property(nonatomic, readonly) NSDictionary<NSString *, id> *arduinoInfo;
@property(nonatomic, readonly) BOOL waitingTooLong;
@property(nonatomic) float motorCoef;
@property(nonatomic) float extraMotorCoef;
@property(nonatomic, readonly) BOOL isConnected;

- (instancetype)initWithConnectionController:(ConnectionController *)connectionController boat:(Boat*)boat;

- (void)setValues:(id)values;
- (void)setLeftMotor:(float)leftMotor rightMotor:(float)rightMotor;
- (void)sendCommand:(NSString *)command;

@end
