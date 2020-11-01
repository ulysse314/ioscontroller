#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CommunicationState) {
  CommunicationStateClosed,
  CommunicationStateOpening,
  CommunicationStateOpened,
};

extern NSString *UlysseWaitedTooLong;

@protocol Communication <NSObject>

@property(nonatomic, readonly) CommunicationState state;

- (void)open;
- (void)close;

@end

NS_ASSUME_NONNULL_END
