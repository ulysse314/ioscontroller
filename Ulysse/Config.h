#import <Foundation/Foundation.h>

@interface Config : NSObject

@property(nonatomic) NSString *boatName;
@property(nonatomic, readonly) NSArray<NSString*>* boatNameList;

+ (instancetype)sharedInstance;

- (NSDictionary *)allValues;
- (id)valueForKey:(NSString *)key;

@end
