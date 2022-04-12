#import <objc/runtime.h>


@interface MGSpoofHelperPrefs : NSObject
NSMutableArray *mgKeysToModify;
+(void)resetAllSettings;
+(void)addToKey:(NSString *)key withValue:(id)value inDictKey:(NSString *)dictKey;
+(NSString *)getOriginalValue: (NSString *)key;
@end
