#import "Config.h"

@interface Config () {
  NSDictionary *_values;
}
@end

@implementation Config

@synthesize boatName = _boatName;

+ (instancetype)sharedInstance {
  static dispatch_once_t p = 0;
  __strong static id _sharedObject = nil;
  dispatch_once(&p, ^{
    _sharedObject = [[self alloc] init];
  });
  return _sharedObject;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ulysse314" ofType:@"json"];
    NSData *JSONData = [NSData dataWithContentsOfFile:path];
    NSError *error = nil;
    _values = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
    _boatName = [_values[@"boats"] allKeys][0];
  }
  return self;
}

- (NSDictionary *)allValues {
  return _values;
}

- (id)valueForKey:(NSString *)key {
  id value = _values[@"boats"][_boatName][key];
  if (!value) {
    value = _values[@"shared"][key];
  }
  return value;
}

- (NSArray<NSString *>*)boatNameList {
  return [_values[@"boats"] allKeys];
}

@end
