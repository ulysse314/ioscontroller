#import <Foundation/Foundation.h>

#if TARGET_OS_SIMULATOR
#define DEBUGLOG NSLog
#else
#define DEBUGLOG(x,...)
#endif

extern NSString *UlysseValuesDidUpdate;
extern NSString *UlysseWaitedTooLong;

@class Boat;
@class Config;

@class ConnectionController;

typedef NS_ENUM(NSUInteger, CommunicationState) {
  CommunicationStateClosed,
  CommunicationStateOpening,
  CommunicationStateOpened,
};

@interface PListCommunication : NSObject

@property(nonatomic, readonly) NSDictionary<NSString *, id> *allValues;
@property(nonatomic, readonly) NSDictionary<NSString *, id> *arduinoInfo;
@property(nonatomic, readonly) BOOL waitingTooLong;
@property(nonatomic) float motorCoef;
@property(nonatomic) float extraMotorCoef;
@property(nonatomic, readonly) BOOL isConnected;
@property(nonatomic, readonly) CommunicationState state;

- (instancetype)initWithConnectionController:(ConnectionController *)connectionController boat:(Boat*)boat;

- (void)open;
- (void)close;

- (void)setValues:(id)values;
- (void)setLeftMotor:(float)leftMotor rightMotor:(float)rightMotor;
- (void)sendCommand:(NSString *)command;

@end
