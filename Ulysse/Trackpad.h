#import <UIKit/UIKit.h>

@class Trackpad;

@protocol TrackpadDelegate <NSObject>

- (void)trackpadDidUpdate:(Trackpad *)trackpad;

@end

@interface Trackpad : UIView

@property (nonatomic, weak) id<TrackpadDelegate> delegate;
@property (nonatomic) CGPoint position;

- (void)setAction:(SEL)action target:(id)target;

@end
