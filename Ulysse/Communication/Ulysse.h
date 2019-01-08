#import <Foundation/Foundation.h>

#if 1
#define DEBUGLOG NSLog
#else
#define DEBUGLOG(x,...)
#endif

extern NSString *UlysseValuesDidUpdate;
extern NSString *UlysseWaitedTooLong;

@class Config;

@interface Ulysse : NSObject

@property(nonatomic, readonly) NSDictionary<NSString *, id> *allValues;
@property(nonatomic, readonly) NSDictionary<NSString *, id> *arduinoInfo;
@property(nonatomic, readonly) BOOL waitingTooLong;
@property(nonatomic) float motorCoef;
@property(nonatomic) float extraMotorCoef;

- (instancetype)initWithConfig:(Config *)config;

- (void)open;
- (void)close;

- (void)setValues:(id)values;
- (void)setLeftMotor:(float)leftMotor rightMotor:(float)rightMotor;
- (void)sendCommand:(NSString *)command;

@end
