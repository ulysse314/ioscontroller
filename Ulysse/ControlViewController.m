#import "ControlViewController.h"

#import <AudioToolbox/AudioToolbox.h>
#import <GameController/GameController.h>
#import <MapKit/MapKit.h>
#include <math.h>
#import <WebKit/WebKit.h>

#import "AppDelegate.h"
#import "MotorPowerView.h"
#import "Trackpad.h"
#import "UITabBarController+HideTabBar.h"
#import "Ulysse.h"

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

@interface ControlViewController ()<MKAnnotation, WKNavigationDelegate, TrackpadDelegate, MKMapViewDelegate> {
  Ulysse *_ulysse;
  __weak AppDelegate *_appDelegate;
  IBOutlet __weak MotorPowerView *_rightMotorPowerView;
  IBOutlet __weak MotorPowerView *_leftMotorPowerView;
  IBOutlet __weak UILabel *_powerLabel;
  IBOutlet __weak UILabel *_networkLabel;
  IBOutlet __weak UILabel *_temperatureLabel;
  IBOutlet __weak UIView *_squareView;
  IBOutlet __weak MKMapView *_mapView;
  GCController *_gameController;
  WKWebView *_webView;
  BOOL _camStarted;
}

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

@end

@implementation ControlViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  _appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
  [_appDelegate addObserver:self forKeyPath:@"gameControlleur" options:NSKeyValueObservingOptionNew context:nil];
  _ulysse = _appDelegate.ulysse;
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
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(gameControllerDidConnect:)
                                               name:GCControllerDidConnectNotification
                                             object:nil];
}

- (BOOL)prefersStatusBarHidden {
  return NO;
}

- (void)gameControllerDidConnect:(NSNotification *)notification {
  if (_gameController) {
    return;
  }
  _gameController = notification.object;
  _gameController.controllerPausedHandler = ^(GCController * _Nonnull controller) {
  };
  _gameController.extendedGamepad.rightThumbstick.valueChangedHandler = ^(GCControllerDirectionPad * _Nonnull dpad, float xValue, float yValue) {
    NSLog(@"%f %f", xValue, yValue);
  };
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameControllerDidDisconnected:) name:GCControllerDidDisconnectNotification object:_gameController];
  UITabBarController *controller = (UITabBarController *)self.parentViewController;
//  [controller setTabBarHidden:YES animated:YES];
  NSLog(@"-------------------------- connected");
}

- (void)gameControllerDidDisconnected:(NSNotification *)notification {
  NSAssert(_gameController == notification.object, @"Unknown game controller");
  [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:notification.object];
  _gameController = nil;
  UITabBarController *controller = (UITabBarController *)self.parentViewController;
//  [controller setTabBarHidden:NO animated:YES];
  NSLog(@"-------------------------- disconnected");
}

- (void)viewDidUnload {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UlysseValuesDidUpdate object:_ulysse];
}

- (void)ulysseValuesDidChange:(NSNotification *)notification {
  Ulysse *ulysse = _ulysse;
  NSDictionary *allValues = ulysse.allValues;
  NSDictionary *motorValues = ulysse.allValues[@"motor"];
  _rightMotorPowerView.value = [motorValues[@"right%"] integerValue];
  _leftMotorPowerView.value = [motorValues[@"left%"] integerValue];
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

#pragma mark - Private

- (void)createCameraView {
//  WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
//  _webView = [[WKWebView alloc] initWithFrame:_trackpadView.frame configuration:theConfiguration];
//  _webView.navigationDelegate = self;
//  _webView.translatesAutoresizingMaskIntoConstraints = NO;
//  //  [self.view addSubview:_webView];
//  [_trackpadView.superview insertSubview:_webView atIndex:0];
//  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_trackpadView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
//  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_trackpadView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
//  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webview]-0-|" options:0 metrics:nil views:@{ @"webview": _webView }]];
}

- (void)setupGameController:(GCController *)gameController {
  NSLog(@"test");
}

#pragma mark - TrackpadDelegate

- (void)trackpadDidUpdate:(Trackpad *)trackpad {
    CGFloat rightMotor = 0;
    CGFloat leftMotor = 0;
    if (trackpad.position.y >= 0 && trackpad.position.x >= 0 && trackpad.position.x <= trackpad.position.y) {
        // N / NE
        rightMotor = trackpad.position.y - trackpad.position.x;
        leftMotor = trackpad.position.y;
    } else if (trackpad.position.y >= 0 && trackpad.position.x >= trackpad.position.y) {
        // NE / E
        rightMotor = trackpad.position.y - trackpad.position.x;
        leftMotor = trackpad.position.x;
    } else if (trackpad.position.x >= 0 && trackpad.position.y >= -trackpad.position.x) {
        // E / SE
        rightMotor = -trackpad.position.x;
        leftMotor = trackpad.position.x + trackpad.position.y;
    } else if (trackpad.position.x >= 0 && trackpad.position.y <= -trackpad.position.x) {
        // SE / S
        rightMotor = trackpad.position.y;
        leftMotor = trackpad.position.y + trackpad.position.x;
    } else if (trackpad.position.x <= 0 && trackpad.position.y <= trackpad.position.x) {
        // S / SW
        rightMotor = trackpad.position.y - trackpad.position.x;
        leftMotor = trackpad.position.y;
    } else if (trackpad.position.x <= 0 && trackpad.position.y <= 0 && trackpad.position.y >= trackpad.position.x) {
        // SW / W
        rightMotor = trackpad.position.y - trackpad.position.x;
        leftMotor = trackpad.position.x;
    } else if (trackpad.position.x <= 0 && trackpad.position.y >= 0 && trackpad.position.y <= -trackpad.position.x) {
        // W / NW
        rightMotor = -trackpad.position.x;
        leftMotor = trackpad.position.y + trackpad.position.x;
    } else if (trackpad.position.x <= 0 && trackpad.position.y >= -trackpad.position.x) {
        // NW / N
        rightMotor = trackpad.position.y;
        leftMotor = trackpad.position.y + trackpad.position.x;
    } else {
        DEBUGLOG(@"pourri");
    }
    rightMotor = (int)(rightMotor * 100.0);
    leftMotor = (int)(leftMotor * 100.0);
    [_ulysse setValues:@{ @"motor": @{@"right%": @((int)(rightMotor * _ulysse.motorCoef)), @"left%": @((int)(leftMotor * _ulysse.motorCoef)) }}];
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


@end
