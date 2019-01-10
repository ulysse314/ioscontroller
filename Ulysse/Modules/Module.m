//
//  Module.m
//  Ulysse
//

#import "Module.h"

NSMutableDictionary<NSString*, Module*> *modules = nil;

@implementation Module

+ (instancetype)moduleWithName:(NSString *)name {
  if (!modules) {
    modules = [NSMutableDictionary dictionary];
  }
  Module *module = [modules objectForKey:name];
  if (!module) {
    module = [[[self class] alloc] initWithName:name];
    [modules setObject:module forKey:name];
  }
  return module;
}

- (instancetype)initWithName:(NSString *)name {
  self = [super init];
  if (self) {
    _name = name;
  }
  return self;
}

@end
