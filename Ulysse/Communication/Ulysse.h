#import <Foundation/Foundation.h>

#if 1
#define DEBUGLOG NSLog
#else
#define DEBUGLOG(x,...)
#endif

extern NSString *UlysseValuesDidUpdate;
extern NSString *UlysseWaitedTooLong;

@class Config;
@class Domains;

typedef NS_ENUM(NSUInteger, UlysseConnectionState) {
  UlysseConnectionStateClosed,
  UlysseConnectionStateOpening,
  UlysseConnectionStateWaitingForData,
  UlysseConnectionStateData,
};

@interface Ulysse : NSObject

@property(nonatomic, readonly) NSDictionary<NSString *, id> *allValues;
@property(nonatomic, readonly) NSDictionary<NSString *, id> *arduinoInfo;
@property(nonatomic, readonly) BOOL waitingTooLong;
@property(nonatomic) float motorCoef;
@property(nonatomic) float extraMotorCoef;
@property(nonatomic, readonly) BOOL isConnected;
@property(nonatomic, readonly) UlysseConnectionState state;

- (instancetype)initWithConfig:(Config *)config domains:(Domains*)domains;

- (void)open;
- (void)close;

- (void)setValues:(id)values;
- (void)setLeftMotor:(float)leftMotor rightMotor:(float)rightMotor;
- (void)sendCommand:(NSString *)command;

@end
