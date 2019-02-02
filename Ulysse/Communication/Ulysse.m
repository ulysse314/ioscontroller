#import "Ulysse.h"

#import <CommonCrypto/CommonDigest.h>

#import "AppDelegate.h"
#import "Config.h"

#import "Ulysse-Swift.h"

#define DelayTrigger 4
#define BUFFER_SIZE 2048

NSString *UlysseValuesDidUpdate = @"UlysseValuesDidUpdate";
NSString *UlysseWaitedTooLong = @"UlysseWaitedTooLong";

typedef NS_ENUM(NSUInteger, UlysseConnectionState) {
  UlysseConnectionStateClosed,
  UlysseConnectionStateOpening,
  UlysseConnectionStateOpened,
};

NSString *StreamStatusString(NSStreamStatus status) {
  switch (status) {
    case NSStreamStatusNotOpen:
      return @"NSStreamStatusNotOpen";
    case NSStreamStatusOpening:
      return @"NSStreamStatusOpening";
    case NSStreamStatusOpen:
      return @"NSStreamStatusOpen";
    case NSStreamStatusReading:
      return @"NSStreamStatusReading";
    case NSStreamStatusWriting:
      return @"NSStreamStatusWriting";
    case NSStreamStatusAtEnd:
      return @"NSStreamStatusAtEnd";
    case NSStreamStatusClosed:
      return @"NSStreamStatusClosed";
    case NSStreamStatusError:
      return @"NSStreamStatusError";
  }
  return @"Unknown NSStreamStatus";
}

NSArray<NSString *>* StreamEvent(NSStreamEvent event) {
  NSMutableArray<NSString *>* array = [NSMutableArray array];
  if (event & NSStreamEventOpenCompleted) {
    [array addObject:@"OpenCompleted"];
  }
  if (event & NSStreamEventHasBytesAvailable) {
    [array addObject:@"HasBytesAvailable"];
  }
  if (event & NSStreamEventHasSpaceAvailable) {
    [array addObject:@"SpaceAvailable"];
  }
  if (event & NSStreamEventEndEncountered) {
    [array addObject:@"EndEncountered"];
  }
  if (event & NSStreamEventErrorOccurred) {
    [array addObject:@"ErrorOccurred"];
  }
  return array;
}

@interface Ulysse ()<NSStreamDelegate> {
  Config *_config;
  NSMutableDictionary<NSString *, id> *_allValues;
  NSInputStream *_inputStream;
  NSOutputStream *_outputStream;
  NSMutableDictionary *_valuesToSend;
  NSTimer *_pingTimer;
  UlysseConnectionState _state;
  BOOL _shouldOpen;
  NSInteger _waitingCounter;
  float _leftMotor;
  float _rightMotor;
  float _motorCoef;
  NSMutableData *_incompleteDataReceived;
  uint8_t *_tmpBuffer;
}

@property(nonatomic, strong) Modules *modules;

@end

@implementation Ulysse

@synthesize allValues = _allValues;
@synthesize motorCoef = _motorCoef;
@synthesize extraMotorCoef = _extraMotorCoef;
@synthesize arduinoInfo = _arduinoInfo;

- (instancetype)initWithConfig:(Config *)config modules:(Modules*)modules {
  self = [super init];
  if (self) {
    _config = config;
    [_config addObserver:self forKeyPath:@"boatName" options:NSKeyValueObservingOptionNew context:nil];
    _motorCoef = 0.5;
    _tmpBuffer = malloc(BUFFER_SIZE);
    self.modules = modules;
  }
  return self;
}

- (void)dealloc {
  free(_tmpBuffer);
}

- (void)open {
  DEBUGLOG(@"Opening streams.");
  _pingTimer = [NSTimer scheduledTimerWithTimeInterval:DelayTrigger target:self selector:@selector(pingTimer:) userInfo:nil repeats:YES];
  _shouldOpen = YES;
  [self openInternal];
}

- (void)close {
  [_pingTimer invalidate];
  _pingTimer = nil;
  _shouldOpen = NO;
  [self closeInternal];
}

- (void)setValues:(NSDictionary *)values {
  DEBUGLOG(@"%@", values);
  if (!_valuesToSend) {
    _valuesToSend = [NSMutableDictionary dictionary];
  }
  for (NSString *key in values) {
    if (![_valuesToSend[key] isEqual:values[key]]) {
      [_valuesToSend setObject:values[key] forKey:key];
      [_allValues setObject:values[key] forKey:key];
    }
  }
  if (_state == UlysseConnectionStateOpened) {
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

#pragma mark - Private

- (void)openInternal {
  _state = UlysseConnectionStateOpening;
  CFReadStreamRef readStream;
  CFWriteStreamRef writeStream;
  NSString *server = [_config valueForKey:@"value_relay_server"];
  UInt32 port = (UInt32)[[_config valueForKey:@"controller_port"] integerValue];
  DEBUGLOG(@"Connected to %@:%d", server, port);
  CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)server, port, &readStream, &writeStream);
  _inputStream = (__bridge_transfer NSInputStream *)readStream;
  _outputStream = (__bridge_transfer NSOutputStream *)writeStream;
  
  _inputStream.delegate = self;
  _outputStream.delegate = self;
  
  [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  
  [_inputStream open];
  [_outputStream open];
}

- (void)closeInternal {
  DEBUGLOG(@"Closing streams.");
  
  [_inputStream close];
  [_outputStream close];
  
  [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  
  _inputStream.delegate = nil;
  _outputStream.delegate = nil;
  _state = UlysseConnectionStateClosed;
}

- (void)inputStreamHandleEvent:(NSStreamEvent)eventCode {
  if (eventCode & NSStreamEventHasBytesAvailable) {
//    DEBUGLOG(@"Reading data %@...", _inputStream.hasBytesAvailable ? @"YES" : @"NO");
    NSError *error = nil;
    id objects = nil;
    NSInteger dataRead = [_inputStream read:_tmpBuffer maxLength:BUFFER_SIZE];
//    DEBUGLOG(@"  %ld", dataRead);
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
//        DEBUGLOG(@"line %@", [[NSString alloc] initWithData:line encoding:NSUTF8StringEncoding]);
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
    }
  }
}

- (void)newValues:(NSDictionary *)values {
  _allValues = [values mutableCopy];
  if (_allValues[@"arduino"]) {
    _arduinoInfo = _allValues[@"arduino"];
    self.modules.arduinoModule.values = _allValues[@"arduino"];
  } else {
    self.modules.arduinoModule.values = @{};
  }
  if (_allValues[@"gps"]) {
    self.modules.gpsModule.values = _allValues[@"gps"];
  } else {
    self.modules.gpsModule.values = @{};
  }
  if (_allValues[@"cellular"]) {
    self.modules.cellularModule.values = _allValues[@"cellular"];
  } else {
    self.modules.cellularModule.values = @{};
  }
  [[NSNotificationCenter defaultCenter] postNotificationName:UlysseValuesDidUpdate object:self];
  [self resetWaitingCount];
}

- (void)outputStreamHandleEvent:(NSStreamEvent)eventCode {
  if ((eventCode & NSStreamEventHasSpaceAvailable) && _state == UlysseConnectionStateOpening) {
    [self sendValidToken];
  }
}

- (void)updateMotors {
  float realMotorCoef = _motorCoef + (_extraMotorCoef * (1 - _motorCoef));
  [self setValues:@{ @"motor": @{@"right%": @((int)(_rightMotor * realMotorCoef * 100)), @"left%": @((int)(_leftMotor * realMotorCoef * 100)) }}];
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
//  DEBUGLOG(@"Stream: %@, Status: %@, Event: %@", (stream == _inputStream) ? @"Input" : @"Output", StreamStatusString(stream.streamStatus), StreamEvent(eventCode));
  if (eventCode & NSStreamEventErrorOccurred) {
    DEBUGLOG(@"Error %@", stream.streamError);
    [self closeInternal];
    return;
  }
  if (eventCode & NSStreamEventEndEncountered) {
    DEBUGLOG(@"End");
    [self closeInternal];
    return;
  }
  if (stream == _inputStream) {
    [self inputStreamHandleEvent:eventCode];
  } else if (stream == _outputStream) {
    [self outputStreamHandleEvent:eventCode];
  }
}

- (void)pingTimer:(NSTimer *)timer {
//  DEBUGLOG(@"ping %lu", (unsigned long)_state);
  switch (_state) {
    case UlysseConnectionStateClosed:
      [self increaseWaitingCount];
      if (_shouldOpen) {
        [self openInternal];
      }
      break;
    case UlysseConnectionStateOpening:
      [self increaseWaitingCount];
      break;
    case UlysseConnectionStateOpened:
      [self increaseWaitingCount];
      break;
  }
}

- (void)sendValidToken {
  NSString *token = [_config valueForKey:@"controller_key"];
  NSData *data = [token dataUsingEncoding:NSUTF8StringEncoding];
  NSInteger count = [_outputStream write:[data bytes] maxLength:[data length]];
  DEBUGLOG(@"sent %ld %ld", count, [data length]);
  [_outputStream write:(const uint8_t *)"\n" maxLength:1];
#pragma unused(count)
  _state = UlysseConnectionStateOpened;
  DEBUGLOG(@"Token sent");
}

- (void)sendValues {
  if (_outputStream.hasSpaceAvailable && _valuesToSend) {
    NSError *error = nil;
    NSInteger count = [NSJSONSerialization writeJSONObject:_valuesToSend toStream:_outputStream options:0 error:&error];
    _valuesToSend = nil;
    if (error) {
      DEBUGLOG(@"Error sending %@", error);
    } else {
//      DEBUGLOG(@"Sending command %ld", count);
      [_outputStream write:(const uint8_t *)"\n" maxLength:1];
#pragma unused(count)
    }
  } else {
    [self increaseWaitingCount];
  }
}

- (void)increaseWaitingCount {
  if (!_shouldOpen) {
    return;
  }
  if (_state == UlysseConnectionStateClosed || _state == UlysseConnectionStateOpening) {
    _waitingCounter = 2;
  } else {
    _waitingCounter++;
  }
//  DEBUGLOG(@"increase waiting count %ld", _waitingCounter);
  NSInteger previousWaitingTooLong = _waitingTooLong;
  if (_waitingCounter == 2) {
    _waitingTooLong = YES;
  }
  if (previousWaitingTooLong != _waitingTooLong) {
    [[NSNotificationCenter defaultCenter] postNotificationName:UlysseWaitedTooLong object:self];
  }
}

- (void)resetWaitingCount {
  NSInteger previousWaitingTooLong = _waitingTooLong;
  _waitingCounter = 0;
  _waitingTooLong = NO;
  if (previousWaitingTooLong != _waitingTooLong) {
    [[NSNotificationCenter defaultCenter] postNotificationName:UlysseWaitedTooLong object:self];
  }
}

#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
  if (object == _config && [keyPath isEqualToString:@"boatName"]) {
    if (_shouldOpen) {
      [self close];
      [self open];
    }
  }
}

@end
