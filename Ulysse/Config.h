#import <Foundation/Foundation.h>

@interface Config : NSObject

@property(nonatomic) NSString *boatName;
@property(nonatomic, readonly) NSArray<NSString*> *boatNameList;
@property(nonatomic, readonly) NSDictionary *allValues;

+ (instancetype)sharedInstance;

- (id)valueForKey:(NSString *)key;

@end
