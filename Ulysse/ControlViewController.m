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

static NSString *networkName(NSInteger networkType) {
  switch (networkType) {
  case 0:
    return @"No Service";
    case 1:
      // 2G
    return @"GSM";
    case 2:
      // 2G
    return @"GPRS";
    case 3:
      // 2G
    return @"EDGE";
    case 4:
      // 3G
    return @"WCDMA";
    case 5:
      // 3G
    return @"HSDPA";
    case 6:
      // 3G
    return @"HSUPA";
    case 7:
      // 3G
    return @"HSPA";
    case 8:
      // 3G
    return @"TD-SCDMA";
    case 9:
      // 4G
    return @"HSPA+)";
    case 10:
    return @"EV-DO rev. 0";
    case 11:
    return @"EV-DO rev. A";
    case 12:
    return @"EV-DO rev. B";
    case 13:
    return @"1xRTT";
    case 14:
    return @"UMB";
    case 15:
    return @"1xEVDV";
    case 16:
    return @"3xRTT";
    case 17:
    return @"HSPA+ 64QAM";
    case 18:
    return @"HSPA+ MIMO";
    case 19:
      // 4G
    return @"LTE";
    case 41:
      // 3G
    return @"UMTS";
    case 44:
      // 3G
    return @"HSPA";
    case 45:
      // 3G
    return @"HSPA+";
    case 46:
      // 3G
    return @"DC-HSPA+";
    case 64:
      // 3G
    return @"HSPA";
  case 65:
      // 3G
    return @"HSPA+";
  case 101:
      // 4G
    return @"LTE";
  default:
    return @"n/a";
  }
}

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

@interface ControlViewController ()<MKAnnotation, ModuleListViewDelegate, WKNavigationDelegate, MKMapViewDelegate> {
  Ulysse *_ulysse;
  IBOutlet __weak UILabel *_powerLabel;
  IBOutlet __weak UILabel *_networkLabel;
  IBOutlet __weak UILabel *_temperatureLabel;
  IBOutlet __weak UIView *_squareView;
  IBOutlet __weak MKMapView *_mapView;
  WKWebView *_webView;
  BOOL _camStarted;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) ViewControllerPresenterViewController *viewControllerPresenterViewController;
@property (nonatomic, strong) ModuleListView *moduleListView;

@property (nonatomic, strong) Modules *modules;

@property (nonatomic, weak) AppDelegate *appDelegate;

@end

@implementation ControlViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
  self.modules = self.appDelegate.modules;
  [self.appDelegate addObserver:self forKeyPath:@"gameControlleur" options:NSKeyValueObservingOptionNew context:nil];
  _ulysse = self.appDelegate.ulysse;
  self.view.autoresizesSubviews = NO;
  // Do any additional setup after loading the view, typically from a nib.
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ulysseValuesDidChange:) name:UlysseValuesDidUpdate object:_ulysse];
  _temperatureLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
  _networkLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
  _powerLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
  
  _mapView.delegate = self;
  _mapView.showsCompass = NO;
  CLLocationCoordinate2D noLocation = {0, 0};
  MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 100, 100);
  MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
  [_mapView setRegion:adjustedRegion animated:NO];
  [self ulysseValuesDidChange:nil];
  [self startCam];
  self.moduleListView = [[ModuleListView alloc] initWithFrame:CGRectZero];
  self.moduleListView.delegate = self;
  self.moduleListView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:self.moduleListView];
  [NSLayoutConstraint activateConstraints:@[
    [self.moduleListView.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor constant:0],
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
  [self updateGPSValues];
  if (_camStarted && ![[allValues[@"camera"] objectForKey:@"state"] boolValue]) {
    //[self stopCam];
  } else if (!_camStarted && [[allValues[@"camera"] objectForKey:@"state"] boolValue]) {
    //[self startCam];
  }
  [self updatePowerValues];
  [self updateNetworkValues];
  [self updateTemperatureValues];
  if (_squareView.backgroundColor == [UIColor blackColor]) {
    _squareView.backgroundColor = [UIColor whiteColor];
  } else {
    _squareView.backgroundColor = [UIColor blackColor];
  }
}

- (void)updatePowerValues {
  NSDictionary *allValues = _ulysse.allValues;
  NSDictionary *gpsValues = allValues[@"gps"];
  NSDictionary *battery = allValues[@"battery"];
  float volt = [battery[@"volt"] floatValue];
  float ampere = [battery[@"ampere"] floatValue];
  bool water = [[allValues[@"water"] objectForKey:@"detected"] boolValue];
  NSString *waterWarning = @"";
  if (water) {
    waterWarning = [NSString stringWithFormat:@", WATER: %ld", [[allValues[@"water"] objectForKey:@"raw"] integerValue]];
  }
  _powerLabel.text = [NSString stringWithFormat:@"%.2fV, %.2fA%@ %.2fm/s", volt, ampere, waterWarning, [gpsValues[@"speed"] floatValue]];
  if (water) {
    _powerLabel.textColor = [UIColor redColor];
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  } else {
    _powerLabel.textColor = [UIColor blackColor];
  }
}

- (void)updateGPSValues {
  NSDictionary *gpsValues = _ulysse.allValues[@"gps"];
  if (gpsValues && gpsValues[@"lat"] && gpsValues[@"lon"]) {
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[gpsValues objectForKey:@"lat"] floatValue];
    coordinate.longitude = [[gpsValues objectForKey:@"lon"] floatValue];
    self.coordinate = coordinate;
    if (_mapView.annotations.count == 0) {
      [_mapView addAnnotation:self];
      [_mapView setCenterCoordinate:coordinate animated:NO];
    } else {
      [_mapView setCenterCoordinate:coordinate animated:YES];
    }
    NSDictionary<NSString *, NSNumber *> *dof = _ulysse.allValues[@"dof"];
    float heading = dof[@"heading"].floatValue;
    _mapView.camera.heading = heading;
  }
}

- (void)updateNetworkValues {
//  DEBUGLOG(@"ulysse %@", _ulysse);
//  DEBUGLOG(@"values %@", _ulysse.allValues);
  NSDictionary *cellularValues = _ulysse.allValues[@"cellular"];
  NSDictionary *gpsValues = _ulysse.allValues[@"gps"];
  NSInteger signalStrength = [cellularValues[@"SignalIcon"] integerValue];
  NSInteger satCount = [gpsValues[@"sat"] integerValue];
  NSInteger trackCount = [gpsValues[@"tracked"] integerValue];
  _networkLabel.text = [NSString stringWithFormat:@"Signal: %ld/%@, RSSI: %@, RSRQ: %@, Sat: %ld/%ld", signalStrength, networkName([cellularValues[@"CurrentNetworkType"] integerValue]), cellularValues[@"rssi"], cellularValues[@"rsrq"], trackCount, satCount];
  if (signalStrength < 2 || !gpsValues[@"lon"] || !gpsValues[@"lat"]) {
    _networkLabel.textColor = [UIColor redColor];
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  } else {
    _networkLabel.textColor = [UIColor blackColor];
  }
}

- (void)updateTemperatureValues {
  NSDictionary *allValues = _ulysse.allValues;
  NSDictionary<NSString *, NSNumber*>*battery = allValues[@"battery"];
  NSDictionary<NSString *, NSNumber*>*motor = allValues[@"motor"];
  float gt = battery[@"temp"].floatValue;
  float lmt = motor[@"lefttemp"].floatValue;
  float rmt = motor[@"righttemp"].floatValue;
  NSDictionary *pi = allValues[@"pi"];
  float cput = [pi[@"temp"] floatValue];
  float cpuUsage = [pi[@"cpu%"] floatValue];
  _temperatureLabel.text = [NSString stringWithFormat:@"General: %.1f°C, Left: %.1f°C, Right: %.1f°C, CPU: %.1f°C/%.1f%%", gt, lmt, rmt, cput, cpuUsage];
  if (gt > 65 || lmt > 65 || rmt > 65 || cput > 65) {
    _temperatureLabel.textColor = [UIColor redColor];
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  } else {
    _temperatureLabel.textColor = [UIColor blackColor];
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

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id<MKAnnotation>)annotation {
  MKAnnotationView *pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"boat"];
  pinView.canShowCallout = NO;
  pinView.image = [UIImage imageNamed:@"quickaction_icon_location"];
  return pinView;
}

#pragma mark - ModuleListViewDelegate

- (void)moduleButtonWasSelectedWithButton:(ModuleButton*)button {
  if (!self.viewControllerPresenterViewController) {
    self.viewControllerPresenterViewController = [[ViewControllerPresenterViewController alloc] initWithNibName:nil bundle:nil];
    [self addChildViewController:self.viewControllerPresenterViewController];
    self.viewControllerPresenterViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.viewControllerPresenterViewController.view];
    [NSLayoutConstraint activateConstraints:@[
      [self.viewControllerPresenterViewController.view.topAnchor constraintEqualToAnchor:self.moduleListView.topAnchor],
      [self.viewControllerPresenterViewController.view.leadingAnchor constraintEqualToAnchor:self.moduleListView.trailingAnchor constant:8],
      [self.viewControllerPresenterViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-32],
      [self.viewControllerPresenterViewController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-16],
    ]];
  }
  UINavigationController *navigationController = [[UINavigationController alloc] initWithNibName:nil bundle:nil];
  self.viewControllerPresenterViewController.viewController = navigationController;
  UIViewController *viewController = [self viewControllerForButtonTag:button.tag];
  [navigationController pushViewController:viewController animated:NO];
  CGPoint point = CGPointMake(button.bounds.origin.x + button.bounds.size.width / 2, button.bounds.origin.y + button.bounds.size.height / 2);
  point = [button convertPoint:point toView:nil];
  [self.viewControllerPresenterViewController openViewControllerWithVPosition:point.y];
}

- (void)moduleButtonWasUnselectedWithButton:(ModuleButton*)button {
  [self.viewControllerPresenterViewController.view removeFromSuperview];
  [self.viewControllerPresenterViewController removeFromParentViewController];
  self.viewControllerPresenterViewController = nil;
}

@end
