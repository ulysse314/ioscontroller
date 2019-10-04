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

@interface ControlViewController ()<ModuleListViewControllerDelegate, WKNavigationDelegate> {
  Ulysse *_ulysse;
  IBOutlet __weak UIView *_squareView;
  WKWebView *_webView;
  BOOL _camStarted;
}

@property (nonatomic, strong) MapViewController *mapViewController;
@property (nonatomic, strong) StatusViewController *statusViewController;
@property (nonatomic, strong) ModuleListViewController *moduleListViewController;
@property (nonatomic, strong) ViewControllerPresenterViewController *viewControllerPresenterViewController;
@property (nonatomic, strong) UIButton *backgroundExitButton;
@property (nonatomic, assign) BOOL isVertical;

@property (nonatomic, strong) Modules *modules;

@property (nonatomic, weak) AppDelegate *appDelegate;

@end

@implementation ControlViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.isVertical = [NSUserDefaults.standardUserDefaults boolForKey:@"vertical_buttons"];
  self.appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
  self.modules = self.appDelegate.modules;

  // Add view controllers.
  self.mapViewController = [[MapViewController alloc] init];
  [self addChildViewController:self.mapViewController];
  [self.view insertSubview:self.mapViewController.view atIndex:0];
  [self.mapViewController didMoveToParentViewController:self];

  self.statusViewController = [[StatusViewController alloc] init];
  [self addChildViewController:self.statusViewController];
  [self.view addSubview:self.statusViewController.view];
  [self.statusViewController didMoveToParentViewController:self];

  self.moduleListViewController = [[ModuleListViewController alloc] initWithModules:self.modules];
  [self addChildViewController:self.moduleListViewController];
  [self.view addSubview:self.moduleListViewController.view];
  [self.moduleListViewController didMoveToParentViewController:self];
  
  self.statusViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
  [self.statusViewController.view.leadingAnchor constraintEqualToAnchor:self.moduleListViewController.view.trailingAnchor constant:10].active = YES;
  [self.view.trailingAnchor constraintEqualToAnchor:self.statusViewController.view.trailingAnchor constant:10].active = YES;
  [self.statusViewController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:10].active = YES;
  [self.statusViewController.view.heightAnchor constraintEqualToConstant:34].active = YES;

  // Configure views.
  self.mapViewController.view.frame = self.view.bounds;

  self.moduleListViewController.delegate = self;
  self.moduleListViewController.isVertical = self.isVertical;
  self.moduleListViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
  [NSLayoutConstraint activateConstraints:@[
    [self.moduleListViewController.view.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor constant:-10],
    [self.moduleListViewController.view.topAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.topAnchor constant:10],
  ]];

  // Rest of config.
  [self.appDelegate addObserver:self forKeyPath:@"gameControlleur" options:NSKeyValueObservingOptionNew context:nil];
  _ulysse = self.appDelegate.ulysse;
  self.view.autoresizesSubviews = NO;
  // Do any additional setup after loading the view, typically from a nib.
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ulysseValuesDidChange:) name:UlysseValuesDidUpdate object:_ulysse];

  [self ulysseValuesDidChange:nil];
  [self startCam];
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

- (void)removePresentedViewController {
  [self.viewControllerPresenterViewController.view removeFromSuperview];
  [self.viewControllerPresenterViewController removeFromParentViewController];
  self.viewControllerPresenterViewController = nil;
  [self.backgroundExitButton removeFromSuperview];
  self.backgroundExitButton = nil;
}

- (void)backgroundExitButtonAction:(id)sender {
  [self.moduleListViewController unselectCurrentButton];
}

- (UIViewController *)viewControllerWithModule:(Module *)module {
  if (module.identifier == ModuleIdentifierSettings) {
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    UIViewController *viewController = [storyBoard instantiateInitialViewController];
    viewController.title = module.name;
    return viewController;
  }
  return [[ModuleViewController alloc] initWithModule:module];
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

#pragma mark - ModuleListViewControllerDelegate

- (void)moduleButtonWasSelectedWithModule:(Module * _Nonnull)module position:(CGFloat)position {
  if (!self.viewControllerPresenterViewController) {
    self.backgroundExitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backgroundExitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundExitButton addTarget:self action:@selector(backgroundExitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.backgroundExitButton belowSubview:self.moduleListViewController.view];
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
        [self.viewControllerPresenterViewController.view.topAnchor constraintEqualToAnchor:self.moduleListViewController.view.topAnchor],
        [self.viewControllerPresenterViewController.view.leadingAnchor constraintEqualToAnchor:self.moduleListViewController.view.trailingAnchor constant:8],
        [self.viewControllerPresenterViewController.view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-32],
        [self.viewControllerPresenterViewController.view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-16],
      ]];
    } else {
      [NSLayoutConstraint activateConstraints:@[
        [self.viewControllerPresenterViewController.view.topAnchor constraintEqualToAnchor:self.moduleListViewController.view.bottomAnchor constant:8],
        [self.viewControllerPresenterViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant: 10],
        [self.viewControllerPresenterViewController.view.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-10],
        [self.viewControllerPresenterViewController.view.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-10],
      ]];
    }
  }
  UINavigationController *navigationController = [[UINavigationController alloc] initWithNibName:nil bundle:nil];
  self.viewControllerPresenterViewController.viewController = navigationController;
  UIViewController *viewController = [self viewControllerWithModule:module];
  [navigationController pushViewController:viewController animated:NO];
  [self.viewControllerPresenterViewController openViewControllerWithPosition:position];
}

- (void)moduleButtonWasUnselectedWithModule:(Module* _Nonnull)module {
  [self removePresentedViewController];
}

@end
