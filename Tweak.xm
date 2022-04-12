#import <substrate.h>
#import <stdint.h>
#import <Foundation/Foundation.h>


extern "C" CFPropertyListRef MGCopyAnswer(CFStringRef);
static NSDictionary *modifiedKeys;
static NSArray *appsChosen;

typedef unsigned long long addr_t;

static addr_t step64(const uint8_t *buf, addr_t start, size_t length, uint32_t what, uint32_t mask) {
	addr_t end = start + length;
	while (start < end) {
		uint32_t x = *(uint32_t *)(buf + start);
		if ((x & mask) == what) {
			return start;
		}
		start += 4;
	}
	return 0;
}

// Modified version of find_call64(), replaced what/mask arguments in the function to the ones for branch instruction (0x14000000, 0xFC000000)
static addr_t find_branch64(const uint8_t *buf, addr_t start, size_t length) {
	return step64(buf, start, length, 0x14000000, 0xFC000000);
}

static addr_t follow_branch64(const uint8_t *buf, addr_t branch) {
	long long w;
	w = *(uint32_t *)(buf + branch) & 0x3FFFFFF;
	w <<= 64 - 26;
	w >>= 64 - 26 - 2;
	return branch + w;
}

// Our replaced version of MGCopyAnswer_internal
static CFPropertyListRef (*orig_MGCopyAnswer_internal)(CFStringRef property, uint32_t *outTypeCode);
CFPropertyListRef new_MGCopyAnswer_internal(CFStringRef property, uint32_t *outTypeCode) {
	if (modifiedKeys[(__bridge NSString *)property]) {
		return (__bridge CFStringRef)modifiedKeys[(__bridge NSString *)property];
	}
	return orig_MGCopyAnswer_internal(property, outTypeCode);
}


static void appsChosenUpdated() {
	NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.smurf.MGSpoofHelperPrefsSuite"];
	appsChosen = [prefs objectForKey:@"spoofApps"];
}

static void modifiedKeyUpdated() {
	NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.smurf.MGSpoofHelperPrefsSuite"];
	modifiedKeys = [prefs objectForKey:@"modifiedKeys"];
}

%ctor
{
	@autoreleasepool
    {
		appsChosenUpdated();
		if (![appsChosen containsObject:[NSBundle mainBundle].bundleIdentifier])
			return;

		MSImageRef libGestalt = MSGetImageByName("/usr/lib/libMobileGestalt.dylib");
		if (libGestalt) {
			void *MGCopyAnswerFn = MSFindSymbol(libGestalt, "_MGCopyAnswer");
			const uint8_t *MGCopyAnswer_ptr = (const uint8_t *)MGCopyAnswer;
			addr_t branch = find_branch64(MGCopyAnswer_ptr, 0, 8);
			addr_t branch_offset = follow_branch64(MGCopyAnswer_ptr, branch);
			MSHookFunction(((void *)((const uint8_t *)MGCopyAnswerFn + branch_offset)), (void *)new_MGCopyAnswer_internal, (void **)&orig_MGCopyAnswer_internal);
		}
		
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)appsChosenUpdated, CFSTR("com.smurf.mgspoof/appsChosenUpdated"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)modifiedKeyUpdated, CFSTR("com.smurf.mgspoof/modifiedKeyUpdated"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		modifiedKeyUpdated();
	}
}
