#import "Config.h"

@interface Config ()
@property(nonatomic) NSArray<NSString*> *boatNameList;
@property(nonatomic) NSDictionary *allValues;
@end

@implementation Config

@synthesize allValues = _allValues;
@synthesize boatName = _boatName;
@synthesize boatNameList = _boatNameList;

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
    _allValues = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
    _boatNameList = [[_allValues[@"boats"] allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    _boatName = [_allValues[@"boats"] allKeys][0];
  }
  return self;
}

- (id)valueForKey:(NSString *)key {
  id value = self.allValues[@"boats"][_boatName][key];
  if (!value) {
    value = self.allValues[@"shared"][key];
  }
  return value;
}

@end
