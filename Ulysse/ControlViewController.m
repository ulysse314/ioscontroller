#import "ControlViewController.h"

#import <AudioToolbox/AudioToolbox.h>
#import <MapKit/MapKit.h>
#include <math.h>
#import <WebKit/WebKit.h>

#import "AppDelegate.h"
#import "SettingsTableViewController.h"
#import "UITabBarController+HideTabBar.h"
#import "Ulysse.h"

#import "Ulysse-Swift.h"

typedef NS_ENUM(NSInteger, ButtonTag) {
  BatteryButtonTag,
  CellularButtonTag,
  GPSButtonTag,
  MotorsButtonTag,
  BoatButtonTag,
  ArduinoButtonTag,
  RaspberryPiButtonTag,
  SettingsButtonTag,
};

@interface ControlViewController ()<ModuleListViewDelegate, WKNavigationDelegate> {
  Ulysse *_ulysse;
  IBOutlet __weak UIView *_squareView;
  WKWebView *_webView;
  BOOL _camStarted;
}

@property (nonatomic, strong) MapViewController *mapViewController;
@property (nonatomic, strong) StatusViewController *statusViewController;
@property (nonatomic, strong) ViewControllerPresenterViewController *viewControllerPresenterViewController;
@property (nonatomic, strong) ModuleListView *moduleListView;
@property (nonatomic, strong) UIButton *backgroundExitButton;
@property (nonatomic, assign) BOOL isVertical;

@property (nonatomic, strong) Modules *modules;

@property (nonatomic, weak) AppDelegate *appDelegate;

@end

@implementation ControlViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.isVertical = NO;
  self.mapViewController = [[MapViewController alloc] init];
  [self addChildViewController:self.mapViewController];
  self.mapViewController.view.frame = self.view.bounds;
  [self.view insertSubview:self.mapViewController.view atIndex:0];
  [self.mapViewController didMoveToParentViewController:self];

  self.appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
  self.modules = self.appDelegate.modules;
  for (Module *module in self.modules.list) {
    [module addObserver:self forKeyPath:@"errors" options:NSKeyValueObservingOptionNew context:nil];
  }
  [self.appDelegate addObserver:self forKeyPath:@"gameControlleur" options:NSKeyValueObservingOptionNew context:nil];
  _ulysse = self.appDelegate.ulysse;
  self.view.autoresizesSubviews = NO;
  // Do any additional setup after loading the view, typically from a nib.
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ulysseValuesDidChange:) name:UlysseValuesDidUpdate object:_ulysse];

  [self ulysseValuesDidChange:nil];
  [self startCam];
  self.moduleListView = [[ModuleListView alloc] initWithFrame:CGRectZero];
  self.moduleListView.isVertical = self.isVertical;
  self.moduleListView.delegate = self;
  self.moduleListView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:self.moduleListView];
  [NSLayoutConstraint activateConstraints:@[
    [self.moduleListView.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor constant:-10],
    [self.moduleListView.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor constant:10],
  ]];
  [self.moduleListView addModuleButtonWithImage:[UIImage imageNamed:@"battery"] buttonTag:BatteryButtonTag];
  [self.moduleListView addModuleButtonWithImage:[UIImage imageNamed:@"cellular"] buttonTag:CellularButtonTag];
  [self.moduleListView addModuleButtonWithImage:[UIImage imageNamed:@"satellite"] buttonTag:GPSButtonTag];
  [self.moduleListView addModuleButtonWithImage:[UIImage imageNamed:@"motor"] buttonTag:MotorsButtonTag];
  [self.moduleListView addModuleButtonWithImage:[UIImage imageNamed:@"boat"] buttonTag:BoatButtonTag];
  [self.moduleListView addModuleButtonWithImage:[UIImage imageNamed:@"arduino"] buttonTag:ArduinoButtonTag];
  [self.moduleListView addModuleButtonWithImage:[UIImage imageNamed:@"raspberrypi"] buttonTag:RaspberryPiButtonTag];
  [self.moduleListView addModuleButtonWithImage:[UIImage imageNamed:@"settings"] buttonTag:SettingsButtonTag];
  
  self.statusViewController = [[StatusViewController alloc] init];
  [self addChildViewController:self.statusViewController];
  [self.view addSubview:self.statusViewController.view];
  self.statusViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
  [self.statusViewController.view.leadingAnchor constraintEqualToAnchor:self.moduleListView.trailingAnchor constant:10].active = YES;
  [self.view.trailingAnchor constraintEqualToAnchor:self.statusViewController.view.trailingAnchor constant:10].active = YES;
  [self.statusViewController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:10].active = YES;
  [self.statusViewController.view.heightAnchor constraintEqualToConstant:34].active = YES;
  [self.statusViewController didMoveToParentViewController:self];
}

- (BOOL)prefersStatusBarHidden {
  return NO;
}

- (void)viewDidUnload {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UlysseValuesDidUpdate object:_ulysse];
}

- (void)ulysseValuesDidChange:(NSNotification *)notification {
  Ulysse *ulysse = _ulysse;
  NSDictionary *allValues = ulysse.allValues;
  [self.mapViewController updateWithValues:_ulysse.allValues];
  [self.statusViewController updateWithValues:_ulysse.allValues];
  if (_camStarted && ![[allValues[@"camera"] objectForKey:@"state"] boolValue]) {
    //[self stopCam];
  } else if (!_camStarted && [[allValues[@"camera"] objectForKey:@"state"] boolValue]) {
    //[self startCam];
  }
  if (_squareView.backgroundColor == [UIColor blackColor]) {
    _squareView.backgroundColor = [UIColor whiteColor];
  } else {
    _squareView.backgroundColor = [UIColor blackColor];
  }
}

- (void)startCam {
  NSURL *url = [NSURL URLWithString:@""];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  [_webView loadRequest:request];
//  [_webView loadHTMLString:@"HELLO" baseURL:nil];
  _camStarted = YES;
}

- (void)stopCam {
    NSURL *url = [NSURL URLWithString:@""];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    _camStarted = NO;
}

- (UIViewController*)viewControllerForButtonTag:(ButtonTag)buttonTag {
  UIViewController *viewController = nil;
  switch (buttonTag) {
    case BatteryButtonTag:
      viewController = [[ModuleViewController alloc] initWithModule:self.modules.batteryModule];
      break;
    case CellularButtonTag:
      viewController = [[ModuleViewController alloc] initWithModule:self.modules.cellularModule];
      break;
    case GPSButtonTag:
      viewController = [[ModuleViewController alloc] initWithModule:self.modules.gpsModule];
      break;
    case MotorsButtonTag:
      viewController = [[ModuleViewController alloc] initWithModule:self.modules.motorsModule];
      break;
    case BoatButtonTag:
      viewController = [[ModuleViewController alloc] initWithModule:self.modules.boatModule];
      break;
    case ArduinoButtonTag:
      viewController = [[ModuleViewController alloc] initWithModule:self.modules.arduinoModule];
      break;
    case RaspberryPiButtonTag:
      viewController = [[ModuleViewController alloc] initWithModule:self.modules.raspberryPiModule];
      break;
    case SettingsButtonTag: {
      UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
      viewController = [storyBoard instantiateInitialViewController];
      viewController.title = @"Settings";
      break;
    }
  }
  return viewController;
}

- (ButtonTag)buttonTagWithModule:(Module*)module {
  if (module == self.modules.batteryModule) {
    return BatteryButtonTag;
  } else if (module == self.modules.cellularModule) {
    return CellularButtonTag;
  } else if (module == self.modules.gpsModule) {
    return GPSButtonTag;
  } else if (module == self.modules.motorsModule) {
    return MotorsButtonTag;
  } else if (module == self.modules.boatModule) {
    return BoatButtonTag;
  } else if (module == self.modules.arduinoModule) {
    return ArduinoButtonTag;
  } else if (module == self.modules.raspberryPiModule) {
    return RaspberryPiButtonTag;
  }
  return (ButtonTag)-1;
}

- (void)removePresentedViewController {
  [self.viewControllerPresenterViewController.view removeFromSuperview];
  [self.viewControllerPresenterViewController removeFromParentViewController];
  self.viewControllerPresenterViewController = nil;
  [self.backgroundExitButton removeFromSuperview];
  self.backgroundExitButton = nil;
}

- (void)backgroundExitButtonAction:(id)sender {
  [self.moduleListView unselectCurrentButton];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
  ButtonTag buttonTag = [self buttonTagWithModule:object];
  ModuleButton *moduleButton = [self.moduleListView moduleButtonWithButtonTag:buttonTag];
  NSInteger errorCount = [object errors].count;
  if (moduleButton.errorNumber != errorCount) {
    moduleButton.errorNumber = [object errors].count;
  }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
  DEBUGLOG(@"Good");
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
  DEBUGLOG(@"error : %@", error);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
  DEBUGLOG(@"error : %@", error);
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
  DEBUGLOG(@"webViewWebContentProcessDidTerminate");
}

#pragma mark - ModuleListViewDelegate

- (void)moduleButtonWasSelectedWithButton:(ModuleButton*)button {
  if (!self.viewControllerPresenterViewController) {
    self.backgroundExitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backgroundExitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundExitButton addTarget:self action:@selector(backgroundExitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backgroundExitButton];
    [NSLayoutConstraint activateConstraints:@[
      [self.backgroundExitButton.topAnchor constraintEqualToAnchor:self.view.topAnchor],
      [self.backgroundExitButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
      [self.backgroundExitButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
      [self.backgroundExitButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    self.viewControllerPresenterViewController = [[ViewControllerPresenterViewController alloc] initWithNibName:nil bundle:nil];
    self.viewControllerPresenterViewController.isVertical = self.isVertical;
    [self addChildViewController:self.viewControllerPresenterViewController];
    self.viewControllerPresenterViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundExitButton addSubview:self.viewControllerPresenterViewController.view];
    if (self.isVertical) {
      [NSLayoutConstraint activateConstraints:@[
        [self.viewControllerPresenterViewController.view.topAnchor constraintEqualToAnchor:self.moduleListView.topAnchor],
        [self.viewControllerPresenterViewController.view.leadingAnchor constraintEqualToAnchor:self.moduleListView.trailingAnchor constant:8],
        [self.viewControllerPresenterViewController.view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-32],
        [self.viewControllerPresenterViewController.view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-16],
      ]];
    } else {
      [NSLayoutConstraint activateConstraints:@[
        [self.viewControllerPresenterViewController.view.topAnchor constraintEqualToAnchor:self.moduleListView.bottomAnchor constant:8],
        [self.viewControllerPresenterViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant: 10],
        [self.viewControllerPresenterViewController.view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-10],
        [self.viewControllerPresenterViewController.view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-10],
      ]];
    }
  }
  UINavigationController *navigationController = [[UINavigationController alloc] initWithNibName:nil bundle:nil];
  self.viewControllerPresenterViewController.viewController = navigationController;
  UIViewController *viewController = [self viewControllerForButtonTag:button.tag];
  [navigationController pushViewController:viewController animated:NO];
  CGPoint point = CGPointMake(button.bounds.origin.x + button.bounds.size.width / 2, button.bounds.origin.y + button.bounds.size.height / 2);
  point = [button convertPoint:point toView:nil];
  CGFloat position = 0;
  if (self.isVertical) {
    position = point.y;
  } else {
    position = point.x;
  }
  [self.viewControllerPresenterViewController openViewControllerWithPosition:position];
}

- (void)moduleButtonWasUnselectedWithButton:(ModuleButton*)button {
  [self removePresentedViewController];
}

@end
