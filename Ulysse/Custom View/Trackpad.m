#import "Trackpad.h"

#define Margin 20.0

@interface Trackpad () {
    __weak NSObject *_target;
    CGPoint _lastTouchPosition;
    SEL _action;
}
@end

@implementation Trackpad

- (void)awakeFromNib {
  [super awakeFromNib];
  _lastTouchPosition.x = -1;
  _lastTouchPosition.y = -1;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
    CGContextAddRect(context, self.bounds);
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextMoveToPoint(context, self.bounds.size.width, 0);
    CGContextAddLineToPoint(context, 0, self.bounds.size.height);
    CGContextMoveToPoint(context, self.bounds.size.width / 2, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width / 2, self.bounds.size.height);
    CGContextMoveToPoint(context, 0, self.bounds.size.height / 2);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height / 2);
    CGContextStrokePath(context);

    if (_lastTouchPosition.x >= 0) {
        [[UIColor colorWithWhite:1 alpha:0.5] setFill];
        CGRect circleRect = CGRectMake(_lastTouchPosition.x - 10, _lastTouchPosition.y - 10,
                                       20,
                                       20);
        CGContextFillEllipseInRect(context, circleRect);
        [[UIColor colorWithWhite:0 alpha:0.5] setStroke];
        CGContextStrokeEllipseInRect(context, circleRect);
    }
}

- (void)setAction:(SEL)action target:(id)target {
    _target = target;
    _action = action;
}

- (void)processTouchEvent:(UITouch *)touch {
    _lastTouchPosition = [touch locationInView:self];
    CGPoint location = _lastTouchPosition;
    CGRect bounds = self.bounds;
    CGPoint middle = CGPointMake((bounds.size.width - bounds.origin.x) / 2.0, (bounds.size.height - bounds.origin.y) / 2.0);
    location.x = location.x - middle.x;
    location.y = location.y - middle.y;
    if (location.x > -Margin && location.x < Margin) {
        _lastTouchPosition.x = middle.x;
        location.x = 0;
    } else if (location.x < -Margin) {
        location.x += Margin;
    } else if (location.x > Margin) {
        location.x -= Margin;
    }
    if (location.y > -Margin && location.y < Margin) {
        _lastTouchPosition.y = middle.y;
        location.y = 0;
    } else if (location.y < -Margin) {
        location.y += Margin;
    } else if (location.y > Margin) {
        location.y -= Margin;
    }
    CGSize maxSize = CGSizeMake(middle.x - Margin * 2, middle.y - Margin * 2);
    location.x = location.x / maxSize.width;
    location.y = -(location.y / maxSize.height);
    if (location.x > 1.0) {
        _lastTouchPosition.x = bounds.origin.x + bounds.size.width;
        location.x = 1.0;
    } else if (location.x < -1.0) {
        _lastTouchPosition.x = bounds.origin.x;
        location.x = -1.0;
    }
    if (location.y > 1.0) {
        _lastTouchPosition.y = bounds.origin.y;
        location.y = 1.0;
    } else if (location.y < -1.0) {
        _lastTouchPosition.y = bounds.origin.y + bounds.size.height;
        location.y = -1.0;
    }
    _position = location;
    [_delegate trackpadDidUpdate:self];
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self processTouchEvent:touches.anyObject];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self processTouchEvent:touches.anyObject];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self processTouchEvent:touches.anyObject];
}

@end
