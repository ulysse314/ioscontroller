#import "MotorPowerView.h"

@implementation MotorPowerView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self communInit];
  }
  return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)decoder {
  self = [super initWithCoder:decoder];
  if (self) {
    [self communInit];
  }
  return self;
}

- (void)communInit {
//  self.layer.borderColor = UIColor.lightGrayColor.CGColor;
//  self.layer.borderWidth = 1.0f;
  self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.75];
  static BOOL test = YES;
  if (test) {
    self.value = 25;
  } else {
    self.value = -25;
  }
  test = !test;
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  CGRect bounds = self.bounds;
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSetFillColorWithColor(context, UIColor.blueColor.CGColor);
  CGRect powerMotorRect;
  CGFloat mid = bounds.origin.y + bounds.size.height / 2;
  CGFloat powerMotorHeight = fabs(self.value * bounds.size.height / 2 / 100);
  if (self.value > 0) {
    powerMotorRect = CGRectMake(bounds.origin.x, mid - powerMotorHeight, bounds.origin.x + bounds.size.width, powerMotorHeight);
  } else {
    powerMotorRect = CGRectMake(bounds.origin.x, mid, bounds.origin.x + bounds.size.width, powerMotorHeight);
  }
  CGContextFillRect(context, powerMotorRect);

  CGContextSetLineWidth(context, 1.0f);
  CGContextSetStrokeColorWithColor(context, UIColor.blackColor.CGColor);
  CGContextMoveToPoint(context, bounds.origin.x, bounds.origin.y + bounds.size.height / 2.0);
  CGContextAddLineToPoint(context, bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height / 2.0);
  CGContextMoveToPoint(context, bounds.origin.x, bounds.origin.y + 0.5);
  CGContextAddLineToPoint(context, bounds.origin.x + bounds.size.width, bounds.origin.y + 0.5);
  CGContextMoveToPoint(context, bounds.origin.x, bounds.origin.y + bounds.size.height - 0.5);
  CGContextAddLineToPoint(context, bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height - 0.5);
  CGContextStrokePath(context);
  CGContextSetStrokeColorWithColor(context, UIColor.lightGrayColor.CGColor);
  CGContextMoveToPoint(context, bounds.origin.x, bounds.origin.y + bounds.size.height / 4.0);
  CGContextAddLineToPoint(context, bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height / 4.0);
  CGContextMoveToPoint(context, bounds.origin.x, bounds.origin.y + bounds.size.height * 3.0 / 4.0);
  CGContextAddLineToPoint(context, bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height * 3.0 / 4.0);
  CGContextStrokePath(context);
}

- (void)setValue:(NSInteger)value {
  _value = value;
  [self setNeedsDisplay];
}

@end
