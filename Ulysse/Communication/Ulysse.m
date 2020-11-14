#import "Ulysse.h"

#import <CommonCrypto/CommonDigest.h>

#import "AppDelegate.h"
#import "Config.h"

#import "Ulysse-Swift.h"

#define DelayTrigger 4
#define BUFFER_SIZE 2048

NSString *UlysseValuesDidUpdate = @"UlysseValuesDidUpdate";
NSString *UlysseWaitedTooLong = @"UlysseWaitedTooLong";

@interface Ulysse ()<ConnectionControllerDelegate> {
  NSMutableDictionary<NSString *, id> *_allValues;
  NSMutableDictionary *_valuesToSend;
  float _leftMotor;
  float _rightMotor;
  float _motorCoef;
  NSMutableData *_incompleteDataReceived;
  uint8_t *_tmpBuffer;
}

@property(nonatomic, strong) Domains *domains;
@property(nonatomic, assign, readwrite) UlysseConnectionState state;
@property(nonatomic, strong) ConnectionController *connectionController;
@property(nonatomic, strong) NSTimer *pingTimer;
@property(nonatomic, assign) NSInteger waitingCounter;

@end

@implementation Ulysse

@synthesize allValues = _allValues;
@synthesize motorCoef = _motorCoef;
@synthesize extraMotorCoef = _extraMotorCoef;
@synthesize arduinoInfo = _arduinoInfo;

- (instancetype)initWithConnectionController:(ConnectionController *)connectionController domains:(Domains*)domains {
  self = [super init];
  if (self) {
    _connectionController = connectionController;
    _connectionController.delegate = self;
    _motorCoef = 0.5;
    _tmpBuffer = malloc(BUFFER_SIZE);
    self.domains = domains;
    [_connectionController addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
  }
  return self;
}

- (void)dealloc {
  [_connectionController removeObserver:self forKeyPath:@"state"];
  free(_tmpBuffer);
}

- (void)open {
  DEBUGLOG(@"Opening streams.");
  self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:DelayTrigger target:self selector:@selector(pingTimer:) userInfo:nil repeats:YES];
  [self internalOpen];
}

- (void)close {
  [self.pingTimer invalidate];
  self.pingTimer = nil;
  [self internalClose];
}

- (void)setValues:(NSDictionary *)values {
  if (!_valuesToSend) {
    _valuesToSend = [NSMutableDictionary dictionary];
  }
  for (NSString *key in values) {
    if (![_valuesToSend[key] isEqual:values[key]]) {
      [_valuesToSend setObject:values[key] forKey:key];
      [_allValues setObject:values[key] forKey:key];
    }
  }
  if (self.isConnected) {
    [self sendValues];
  }
}

- (void)setLeftMotor:(float)leftMotor rightMotor:(float)rightMotor {
  if (_leftMotor != leftMotor || _rightMotor != rightMotor) {
    _leftMotor = leftMotor;
    _rightMotor = rightMotor;
    [self updateMotors];
  }
}

- (void)setMotorCoef:(float)motorCoef {
  _motorCoef = motorCoef;
  [self updateMotors];
}

- (void)setExtraMotorCoef:(float)extraMotorCoef {
  _extraMotorCoef = extraMotorCoef;
  [self updateMotors];
}

- (float)extraMotorCoef {
  return _extraMotorCoef;
}

- (void)sendCommand:(NSString *)command {
  [self setValues:@{@"command": command}];
}

- (void)sendPing {
  [self setValues:@{@"ping": @YES}];
}

- (BOOL)isConnected {
  switch (self.connectionController.state) {
    case ConnectionControllerStateStopped:
    case ConnectionControllerStateConnecting:
    case ConnectionControllerStateHandshake:
      return NO;
    case ConnectionControllerStateOpened:
      return YES;
  }
}

#pragma mark - Private

- (void)internalOpen {
  self.state = UlysseConnectionStateOpening;
  [self.connectionController start];
}

- (void)internalClose {
  self.state = UlysseConnectionStateClosed;
  [self.connectionController stop];
}

- (void)newValues:(NSDictionary *)values {
  _allValues = [values mutableCopy];
  [self.domains.arduinoDomain valueUpdateStart];
  if (_allValues[@"ard"]) {
    _arduinoInfo = _allValues[@"ard"];
    [self.domains.arduinoDomain addValuesWithModuleName:@"arduino" values:_allValues[@"ard"]];
  }
  [self.domains.arduinoDomain valueUpdateDone];
  [self.domains.batteryDomain valueUpdateStart];
  if (_allValues[@"batt"]) {
    [self.domains.batteryDomain addValuesWithModuleName:@"battery" values:_allValues[@"batt"]];
  }
  [self.domains.batteryDomain valueUpdateDone];
  [self.domains.gpsDomain valueUpdateStart];
  if (_allValues[@"gps"]) {
    [self.domains.gpsDomain addValuesWithModuleName:@"gps" values:_allValues[@"gps"]];
  }
  [self.domains.gpsDomain valueUpdateDone];
  [self.domains.cellularDomain valueUpdateStart];
  if (_allValues[@"cell"]) {
    [self.domains.cellularDomain addValuesWithModuleName:@"cellular" values:_allValues[@"cell"]];
  }
  [self.domains.cellularDomain valueUpdateDone];
  [self.domains.raspberryPiDomain valueUpdateStart];
  if (_allValues[@"pi"]) {
    [self.domains.raspberryPiDomain addValuesWithModuleName:@"pi" values:_allValues[@"pi"]];
  }
  [self.domains.raspberryPiDomain valueUpdateDone];
  [self.domains.hullDomain valueUpdateStart];
  if (_allValues[@"hll"]) {
    [self.domains.hullDomain addValuesWithModuleName:@"hull" values:_allValues[@"hll"]];
  }
  [self.domains.hullDomain valueUpdateDone];
  [self.domains.motorsDomain valueUpdateStart];
  for (NSString *key in _allValues.allKeys) {
    if ([key hasPrefix:@"mtr-"]) {
      [self.domains.motorsDomain addValuesWithModuleName:key values:_allValues[key]];
    }
  }
  [self.domains.motorsDomain valueUpdateDone];
  [[NSNotificationCenter defaultCenter] postNotificationName:UlysseValuesDidUpdate object:self];
  [self resetWaitingCount];
}

- (void)updateMotors {
  float realMotorCoef = _motorCoef + (_extraMotorCoef * (1 - _motorCoef));
  [self setValues:@{ @"motor": @{@"right%": @((int)(_rightMotor * realMotorCoef * 100)), @"left%": @((int)(_leftMotor * realMotorCoef * 100)) }}];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
  if ([keyPath isEqualToString:@"state"] && object == self.connectionController) {
    switch (self.connectionController.state) {
      case ConnectionControllerStateStopped:
        switch (self.state) {
          case UlysseConnectionStateOpened:
            self.state = UlysseConnectionStateOpening;
            [self.connectionController start];
            break;
          case UlysseConnectionStateOpening:
            [self.connectionController start];
            break;
          case UlysseConnectionStateClosed:
            break;
        }
        break;
      case ConnectionControllerStateConnecting:
        switch (self.state) {
          case UlysseConnectionStateOpened:
            self.state = UlysseConnectionStateOpening;
            break;
          case UlysseConnectionStateOpening:
            break;
          case UlysseConnectionStateClosed:
            [self.connectionController stop];
            break;
        }
        break;
      case ConnectionControllerStateHandshake:
        switch (self.state) {
          case UlysseConnectionStateOpened:
            self.state = UlysseConnectionStateOpening;
            break;
          case UlysseConnectionStateOpening:
            break;
          case UlysseConnectionStateClosed:
            [self.connectionController stop];
            break;
        }
        break;
      case ConnectionControllerStateOpened:
        switch (self.state) {
          case UlysseConnectionStateOpened:
            break;
          case UlysseConnectionStateOpening:
            self.state = UlysseConnectionStateOpened;
            break;
          case UlysseConnectionStateClosed:
            [self.connectionController stop];
            break;
        }
        break;
    }
    return;
  }
  [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)pingTimer:(NSTimer *)timer {
//  DEBUGLOG(@"ping %lu", (unsigned long)self.state);
  switch (self.state) {
    case UlysseConnectionStateClosed:
    case UlysseConnectionStateOpening:
      break;
    case UlysseConnectionStateOpened:
      [self increaseWaitingCount];
      break;
  }
}

- (void)sendValues {
  if (self.connectionController.hasSpaceAvailable && _valuesToSend) {
    NSError *error = nil;
    NSInteger count = [NSJSONSerialization writeJSONObject:_valuesToSend toStream:self.connectionController.outputStream options:0 error:&error];
    _valuesToSend = nil;
    if (error) {
      DEBUGLOG(@"Error sending %@", error);
    } else {
      count = [self.connectionController write:(const uint8_t *)"\n" maxLength:1];
#pragma unused(count)
    }
  }
}

- (void)increaseWaitingCount {
  if (self.state != UlysseConnectionStateOpened) {
    return;
  }
  self.waitingCounter++;
//  DEBUGLOG(@"increase waiting count %ld", self.waitingCounter);
  if (self.waitingCounter == 2) {
    [self.connectionController stop];
    [self internalOpen];
    [[NSNotificationCenter defaultCenter] postNotificationName:UlysseWaitedTooLong object:self];
  }
  if (self.waitingCounter != 0 && self.waitingCounter % 5 == 0) {
    [self sendPing];
  }
}

- (void)resetWaitingCount {
  self.waitingCounter = 0;
}

#pragma mark - ConnectionControllerDelegate

- (void)inputAvailableWithConnectionController:(ConnectionController * _Nonnull)connectionController {
  NSError *error = nil;
  id objects = nil;
  NSInteger dataRead = [self.connectionController read:_tmpBuffer maxLength:BUFFER_SIZE];
    if (!_incompleteDataReceived) {
    _incompleteDataReceived = [NSMutableData data];
  }
  if (dataRead > 0) {
    [_incompleteDataReceived appendBytes:_tmpBuffer length:dataRead];
    NSInteger ii = 0;
    for (ii = 0; ii < dataRead; ii++) {
      if (_tmpBuffer[ii] == '\n' || _tmpBuffer[ii] == '\r') {
        break;
      }
    }
    if (ii < dataRead) {
      NSData *line = [_incompleteDataReceived subdataWithRange:NSMakeRange(0, _incompleteDataReceived.length - (dataRead - ii))];
      objects = [NSJSONSerialization JSONObjectWithData:line options:0 error:&error];
      NSUInteger length = line.length + 1;
      ii++;
      while (ii < dataRead && (_tmpBuffer[ii] == '\n' || _tmpBuffer[ii] == '\r')) {
        ii++;
        length++;
      }
      [_incompleteDataReceived replaceBytesInRange:NSMakeRange(0, length) withBytes:NULL length:0];
    }
  }
  if (error) {
    DEBUGLOG(@"Error decoding %@", error);
  } else if (objects) {
    [self newValues:objects];
    [self sendPing];
  }
}

- (void)outputReadyWithConnectionController:(ConnectionController * _Nonnull)connectionController {
}

@end
