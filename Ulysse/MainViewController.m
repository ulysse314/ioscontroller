#import "MainViewController.h"

#import <AudioToolbox/AudioToolbox.h>
#import <MapKit/MapKit.h>
#import <math.h>
#import <WebKit/WebKit.h>

#import "AppDelegate.h"
#import "Config.h"
#import "GamepadController.h"
#import "PListCommunication.h"
#import "SettingsTableViewController.h"
#import "UITabBarController+HideTabBar.h"

#import "Ulysse-Swift.h"

#define kVerticalButtonsPReference   @"vertical_buttons"
#define MAX_BATTERY_AH               17

@interface MainViewController ()<CameraViewControllerDelegate, DomainButtonListViewControllerDelegate, GamepadControllerDelegate, WKNavigationDelegate> {
  PListCommunication *_communication;
  IBOutlet __weak UIView *_squareView;
  BOOL _camStarted;
}

@property (nonatomic, strong) MapViewController *mapViewController;
@property (nonatomic, strong) StatusViewController *statusViewController;
@property (nonatomic, strong) DomainButtonListViewController *domainButtonListViewController;
@property (nonatomic, strong) ViewControllerPresenterViewController *viewControllerPresenterViewController;
@property (nonatomic, strong) UIButton *backgroundExitButton;
@property (nonatomic, assign) BOOL verticalButtons;
@property (nonatomic, strong) CameraViewController *cameraViewController;
@property (nonatomic, strong) UIProgressView *currentConsumptionProgressView;
@property (nonatomic, strong) MainViewLayoutController *layoutController;

@property (nonatomic, strong) Domains *domains;

@property (nonatomic, weak) AppDelegate *appDelegate;

@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [NSUserDefaults.standardUserDefaults addObserver:self forKeyPath:kVerticalButtonsPReference options:NSKeyValueObservingOptionNew context:nil];
  self.appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
  self.domains = self.appDelegate.domains;
  self.layoutController = [[MainViewLayoutController alloc] initWithMainView:self.view];

  // Add view controllers.
  self.mapViewController = [[MapViewController alloc] init];
  [self addChildViewController:self.mapViewController];
  self.layoutController.mapView = self.mapViewController.view;
  [self.mapViewController didMoveToParentViewController:self];

  self.statusViewController = [[StatusViewController alloc] init];
  [self addChildViewController:self.statusViewController];
  self.layoutController.statusView = self.statusViewController.view;
  [self.statusViewController didMoveToParentViewController:self];

  self.domainButtonListViewController = [[DomainButtonListViewController alloc] initWithDomains:self.domains];
  self.domainButtonListViewController.delegate = self;
  self.domainButtonListViewController.verticalButtons = self.verticalButtons;
  [self addChildViewController:self.domainButtonListViewController];
  self.layoutController.domainButtonListView = self.domainButtonListViewController.view;
  [self.domainButtonListViewController didMoveToParentViewController:self];

  self.currentConsumptionProgressView = [[UIProgressView alloc] init];
  self.layoutController.currentConsumptionProgressView = self.currentConsumptionProgressView;

  [self.layoutController setupLayouts];

  self.appDelegate.gamepadController.delegate = self;
  _communication = self.appDelegate.communication;
  self.view.autoresizesSubviews = NO;
  // Do any additional setup after loading the view, typically from a nib.
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ulysseValuesDidChange:) name:UlysseValuesDidUpdate object:_communication];

  [self ulysseValuesDidChange:nil];
  [self updateGamepadController];
  [self updateVerticalPreference];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
  if (object == NSUserDefaults.standardUserDefaults) {
    [self updateVerticalPreference];
  }
}

- (void)updateVerticalPreference {
  if ([NSUserDefaults.standardUserDefaults objectForKey:kVerticalButtonsPReference]) {
    self.verticalButtons = [NSUserDefaults.standardUserDefaults boolForKey:kVerticalButtonsPReference];
  } else {
    self.verticalButtons = YES;
  }
  self.domainButtonListViewController.verticalButtons = self.verticalButtons;
  self.viewControllerPresenterViewController.verticalButtons = self.verticalButtons;
}

- (void)updateGamepadController {
  self.statusViewController.gamepadConnected = self.appDelegate.gamepadController.isConnected;
}

- (void)viewDidUnload {
  [super viewDidUnload];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UlysseValuesDidUpdate object:_communication];
}

- (void)ulysseValuesDidChange:(NSNotification *)notification {
  PListCommunication *communication = _communication;
  NSDictionary *allValues = communication.allValues;
  [self.mapViewController updateWithValues:allValues];
  [self.statusViewController updateWithValues:allValues];
  if (_camStarted && ![[allValues[@"camera"] objectForKey:@"state"] boolValue]) {
    [self stopCam];
  } else if (!_camStarted && [[allValues[@"camera"] objectForKey:@"state"] boolValue]) {
    [self startCam];
  }
  if (_squareView.backgroundColor != UIColor.whiteColor) {
    _squareView.backgroundColor = UIColor.whiteColor;
  } else {
    UIColor *color = UIColor.blackColor;
    if ([allValues[@"record"] boolValue]) {
      color = UIColor.redColor;
    }
    _squareView.backgroundColor = color;
  }
  [self.domainButtonListViewController updateDomainButtonValues];
  NSNumber *currentConsumption = [allValues[@"batt"] objectForKey:@"ah"];
  if (currentConsumption && [currentConsumption isKindOfClass:[NSNumber class]]) {
    double value = currentConsumption.doubleValue;
    self.currentConsumptionProgressView.progress = (MAX_BATTERY_AH - value) / MAX_BATTERY_AH;
  }
}

- (void)startCam {
  if (_camStarted) {
    return;
  }
  NSString *server = [self.appDelegate.config valueForKey:@"value_relay_server"];
  NSString *port = [self.appDelegate.config valueForKey:@"controller_stream_port"];
  NSString *stringURL = [NSString stringWithFormat:@"http://%@:%@", server, port];
  NSURL *url = [NSURL URLWithString:stringURL];
  self.cameraViewController = [[CameraViewController alloc] initWithCameraURL:url];
  [self addChildViewController:self.cameraViewController];
  self.layoutController.cameraView = self.cameraViewController.view;
  [self.cameraViewController didMoveToParentViewController:self];
  self.cameraViewController.delegate = self;
  _camStarted = YES;
}

- (void)stopCam {
  [self.cameraViewController willMoveToParentViewController:nil];
  [self.cameraViewController.view removeFromSuperview];
  [self.cameraViewController removeFromParentViewController];
  self.cameraViewController = nil;
  self.layoutController.cameraView = nil;
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
  [self.domainButtonListViewController unselectCurrentButton];
}

- (UIViewController *)viewControllerWithDomain:(Domain *)domain {
  if (domain.identifier == DomainIdentifierSettings) {
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    UIViewController *viewController = [storyBoard instantiateInitialViewController];
    viewController.title = domain.name;
    return viewController;
  }
  return [[DetailDomainViewController alloc] initWithModuleDomain:(ModuleDomain *)domain];
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

#pragma mark - CameraViewControllerDelegate

- (void)cameraViewControllerWasTapped:(CameraViewController *)cameraViewController {
  [self.layoutController swithcMainView];
}

#pragma mark - DomainButtonListViewControllerDelegate

- (void)domainButtonWasSelectedWithDomain:(Domain * _Nonnull)domain buttonFrame:(CGRect)buttonFrame {
  if (!self.viewControllerPresenterViewController) {
    self.backgroundExitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backgroundExitButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundExitButton addTarget:self action:@selector(backgroundExitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:self.backgroundExitButton belowSubview:self.domainButtonListViewController.view];
    [NSLayoutConstraint activateConstraints:@[
      [self.backgroundExitButton.topAnchor constraintEqualToAnchor:self.view.topAnchor],
      [self.backgroundExitButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
      [self.backgroundExitButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
      [self.backgroundExitButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    self.viewControllerPresenterViewController = [[ViewControllerPresenterViewController alloc] initWithNibName:nil bundle:nil];
    self.viewControllerPresenterViewController.verticalButtons = self.verticalButtons;
    [self addChildViewController:self.viewControllerPresenterViewController];
    self.viewControllerPresenterViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundExitButton addSubview:self.viewControllerPresenterViewController.view];
    if (self.verticalButtons) {
      [NSLayoutConstraint activateConstraints:@[
        [self.viewControllerPresenterViewController.view.leadingAnchor constraintEqualToAnchor:self.domainButtonListViewController.view.trailingAnchor],
        [self.view.safeAreaLayoutGuide.trailingAnchor constraintEqualToAnchor:self.viewControllerPresenterViewController.view.trailingAnchor constant:10],
        [self.viewControllerPresenterViewController.view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
        [self.viewControllerPresenterViewController.view.bottomAnchor constraintEqualToAnchor:self.domainButtonListViewController.view.bottomAnchor],
      ]];
    } else {
      [NSLayoutConstraint activateConstraints:@[
        [self.viewControllerPresenterViewController.view.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:10],
        [self.view.safeAreaLayoutGuide.trailingAnchor constraintEqualToAnchor:self.viewControllerPresenterViewController.view.trailingAnchor constant:10],
        [self.viewControllerPresenterViewController.view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.domainButtonListViewController.view.topAnchor constraintEqualToAnchor:self.viewControllerPresenterViewController.view.bottomAnchor],
      ]];
    }
  }
  UINavigationController *navigationController = [[UINavigationController alloc] initWithNibName:nil bundle:nil];
  self.viewControllerPresenterViewController.viewController = navigationController;
  UIViewController *viewController = [self viewControllerWithDomain:domain];
  [navigationController pushViewController:viewController animated:NO];
  [self.viewControllerPresenterViewController openViewControllerWithPosition:self.verticalButtons ? (buttonFrame.origin.y + buttonFrame.size.height / 2) : (buttonFrame.origin.x + buttonFrame.size.width / 2)];
}

- (void)domainButtonWasUnselectedWithDomain:(Domain* _Nonnull)domain {
  [self removePresentedViewController];
}

#pragma mark - GamepadControllerDelegate

- (void)gamepadController:(GamepadController *)gamepadController isConnected:(BOOL)isConnected {
  [self updateGamepadController];
}

- (void)gamepadControllerMapButtonPressed:(GamepadController *)gamepadController {
  [self.layoutController swithcMainView];
}

- (void)gamepadControllerTurnOnLEDs:(GamepadController *)gamepadController {
  [_communication setValues: @{ @"light": @(2) }];
}

- (void)gamepadControllerTurnOffLEDs:(GamepadController *)gamepadController {
  [_communication setValues: @{ @"stop light": @(0) }];
}

@end
