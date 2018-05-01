#import "UITabBarController+HideTabBar.h"

#define kAnimationDuration .3


@implementation UITabBarController (HideTabBar)

- (void)setTabBarHidden:(BOOL)hidden
{
  [self setTabBarHidden:hidden animated:YES];
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated
{
  if ( [self.view.subviews count] < 2 )
    return;
  
  UIView *contentView;
  
  if ( [[self.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )
    contentView = [self.view.subviews objectAtIndex:1];
  else
    contentView = [self.view.subviews objectAtIndex:0];
  
  if ( hidden )
  {
    contentView.frame = self.view.bounds;
  }
  else
  {
    contentView.frame = CGRectMake(self.view.bounds.origin.x,
                                   self.view.bounds.origin.y,
                                   self.view.bounds.size.width,
                                   self.view.bounds.size.height - self.tabBar.frame.size.height);
  }
  [contentView layoutSubviews];
  self.tabBar.hidden = hidden;
}

@end
