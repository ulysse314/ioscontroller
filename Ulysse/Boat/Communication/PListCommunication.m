#import "PListCommunication.h"

#import <CommonCrypto/CommonDigest.h>

#import "AppDelegate.h"
#import "Config.h"

#import "Ulysse-Swift.h"

#define DelayTrigger 4
#define BUFFER_SIZE 2048

NSString *UlysseValuesDidUpdate = @"UlysseValuesDidUpdate";
NSString *UlysseWaitedTooLong = @"UlysseWaitedTooLong";

@interface PListCommunication ()<ConnectionControllerDelegate> {
  NSMutableDictionary<NSString *, id> *_allValues;
  NSMutableDictionary *_valuesToSend;
  float _leftMotor;
  float _rightMotor;
  float _motorCoef;
  NSMutableData *_incompleteDataReceived;
  uint8_t *_tmpBuffer;
}

@property(nonatomic, strong) Boat *boat;
@property(nonatomic, assign, readwrite) CommunicationState state;
@property(nonatomic, strong) ConnectionController *connectionController;
@property(nonatomic, strong) NSTimer *pingTimer;
@property(nonatomic, assign) NSInteger waitingCounter;

@end

@implementation PListCommunication

@synthesize allValues = _allValues;
@synthesize motorCoef = _motorCoef;
@synthesize extraMotorCoef = _extraMotorCoef;
@synthesize arduinoInfo = _arduinoInfo;

- (instancetype)initWithConnectionController:(ConnectionController *)connectionController boat:(Boat*)boat {
  self = [super init];
  if (self) {
    _connectionController = connectionController;
    _connectionController.delegate = self;
    _motorCoef = 0.5;
    _tmpBuffer = malloc(BUFFER_SIZE);
    self.boat = boat;
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
  self.state = CommunicationStateOpening;
  [self.connectionController start];
}

- (void)internalClose {
  self.state = CommunicationStateClosed;
  [self.connectionController stop];
}

- (void)newValues:(NSDictionary *)values {
  _allValues = [values mutableCopy];
  [self.boat valueUpdateStart];
  if (_allValues[@"ard"]) {
    _arduinoInfo = _allValues[@"ard"];
    [self.boat.arduinoBoatComponent setAllValues:_allValues[@"ard"]];
  }
  if (_allValues[@"batt"]) {
    [self.boat.batteryBoatComponent setAllValues:_allValues[@"batt"]];
  }
  if (_allValues[@"gps"]) {
    [self.boat.gpsBoatComponent setAllValues:_allValues[@"gps"]];
  }
  if (_allValues[@"cell"]) {
    [self.boat.cellularBoatComponent setAllValues:_allValues[@"cell"]];
  }
  if (_allValues[@"pi"]) {
    [self.boat.raspberryPiBoatComponent setAllValues:_allValues[@"pi"]];
  }
  if (_allValues[@"hll"]) {
    [self.boat.hullBoatComponent setAllValues:_allValues[@"hll"]];
  }
  if (_allValues[@"hll"]) {
    [self.boat.hullBoatComponent setAllValues:_allValues[@"hll"]];
  }
  if (_allValues[@"mtr-l"]) {
    [self.boat.leftMotorBoatComponent setAllValues:_allValues[@"mtr-l"]];
  }
  if (_allValues[@"mtr-r"]) {
    [self.boat.rightMotorBoatComponent setAllValues:_allValues[@"mtr-r"]];
  }
  [self.boat valueUpdateDone];
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
          case CommunicationStateOpened:
            self.state = CommunicationStateOpening;
            [self.connectionController start];
            break;
          case CommunicationStateOpening:
            [self.connectionController start];
            break;
          case CommunicationStateClosed:
            break;
        }
        break;
      case ConnectionControllerStateConnecting:
        switch (self.state) {
          case CommunicationStateOpened:
            self.state = CommunicationStateOpening;
            break;
          case CommunicationStateOpening:
            break;
          case CommunicationStateClosed:
            [self.connectionController stop];
            break;
        }
        break;
      case ConnectionControllerStateHandshake:
        switch (self.state) {
          case CommunicationStateOpened:
            self.state = CommunicationStateOpening;
            break;
          case CommunicationStateOpening:
            break;
          case CommunicationStateClosed:
            [self.connectionController stop];
            break;
        }
        break;
      case ConnectionControllerStateOpened:
        switch (self.state) {
          case CommunicationStateOpened:
            break;
          case CommunicationStateOpening:
            self.state = CommunicationStateOpened;
            break;
          case CommunicationStateClosed:
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
    case CommunicationStateClosed:
    case CommunicationStateOpening:
      break;
    case CommunicationStateOpened:
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
  if (self.state != CommunicationStateOpened) {
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
