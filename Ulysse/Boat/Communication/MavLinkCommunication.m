#import "MavLinkCommunication.h"

#import "Ulysse-Swift.h"
#import "mavlink.h"

#define BUFFER_SIZE 2048

@interface MavLinkCommunication ()<ConnectionControllerDelegate> {
  uint8_t *_dataBuffer;
  uint8_t *_dataBufferCursor;
  size_t _dataCount;
}

@property(nonatomic, strong) ConnectionController *connectionController;
@property(nonatomic, assign, readwrite) CommunicationState state;
@property(nonatomic, assign) NSInteger waitingCounter;

@end

@implementation MavLinkCommunication

- (instancetype)initWithConnectionController:(ConnectionController *)connectionController domains:(Domains*)domains {
  self = [super init];
  if (self) {
    _connectionController = connectionController;
    _connectionController.delegate = self;
    [_connectionController addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    _dataBuffer = malloc(BUFFER_SIZE);
    _dataBufferCursor = _dataBuffer;
    _dataCount = 0;
  }
  return self;
}

- (void)dealloc {
  [_connectionController removeObserver:self forKeyPath:@"state"];
  free(_dataBuffer);
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

- (void)sendLight {
}

#pragma mark - Communication

- (void)close {
}

- (void)open {
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

- (void)sendPing {
}

#pragma mark - ConnectionControllerDelegate

- (void)inputAvailableWithConnectionController:(ConnectionController * _Nonnull)connectionController {
  mavlink_status_t status;
  mavlink_message_t msg;
  int chan = MAVLINK_COMM_0;

  while (YES) {
    if (_dataCount == 0 && self.connectionController.hasBytesAvailable > 0) {
      _dataCount = [self.connectionController read:_dataBuffer maxLength:BUFFER_SIZE];
      _dataBufferCursor = _dataBuffer;
    }
    if (_dataCount > 0) {
      return;
    }
    uint8_t byte = _dataBufferCursor[0];
    --_dataCount;
    ++_dataBufferCursor;
    if (mavlink_parse_char(chan, byte, &msg, &status)) {
      printf("Received message with ID %d, sequence: %d from component %d of system %d\n", msg.msgid, msg.seq, msg.compid, msg.sysid);
      // ... DECODE THE MESSAGE PAYLOAD HERE ...
    }
  }
}

- (void)outputReadyWithConnectionController:(ConnectionController * _Nonnull)connectionController {
}

@end
