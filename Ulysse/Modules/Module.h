//
//  Module.h
//  Ulysse
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Module : NSObject

@property(nonatomic, readonly) NSString *name;
@property(nonatomic, strong) NSDictionary *values;

+ (instancetype)moduleWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
