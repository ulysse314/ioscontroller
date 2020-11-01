#import <Foundation/Foundation.h>

#import "Communication.h"

NS_ASSUME_NONNULL_BEGIN

@class ConnectionController;
@class Domains;

@interface MavLinkCommunication : NSObject<Communication>

- (instancetype)initWithConnectionController:(ConnectionController *)connectionController domains:(Domains*)domains;

@end

NS_ASSUME_NONNULL_END
