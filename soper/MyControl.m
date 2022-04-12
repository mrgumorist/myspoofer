#import "MyControl.h"
#import "MGSpoofHelperPrefs.h"

CFPropertyListRef MGCopyAnswer(CFStringRef);
#define mgValue(key) (__bridge NSString *)MGCopyAnswer((__bridge CFStringRef)key)

@implementation MyControl

+(void)resetAllSettings:{
    NSUserDefaults *userDeafaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.smurf.MGSpoofHelperPrefsSuite"];
    // [userDeafaults removePersistentDomainForName:[NSBundle mainBundle].bundleIdentifier];
    NSDictionary *defaultsDictionary = [userDeafaults dictionaryRepresentation];
    for (NSString *key in defaultsDictionary.allKeys) {
        [userDeafaults removeObjectForKey:key];
    }
}

+(void)addToKey:(NSString *)key withValue:(id)value inDictKey:(NSString *)dictKey {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.smurf.MGSpoofHelperPrefsSuite"];
    NSMutableDictionary *newDict = ((NSDictionary *)[userDefaults objectForKey:dictKey]).mutableCopy;
    if (!newDict) {
        [userDefaults setValue:@{} forKey:dictKey];
        newDict = @{}.mutableCopy;
    }
    newDict[key] = value;
    [userDefaults setValue:newDict forKey:dictKey];
    notify_post("com.smurf.mgspoof/modifiedKeyUpdated");
}

+(NSString *)getOriginalValue: (NSString *)key{
    return [NSString stringWithFormat:@"%@", mgValue(key)]
}

@end
