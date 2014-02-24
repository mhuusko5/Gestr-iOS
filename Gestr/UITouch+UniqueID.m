#import "UITouch+UniqueID.h"
#import <objc/runtime.h>

static const void *kTCUniqueIdKey = &kTCUniqueIdKey;

@implementation UITouch (UniqueID)

- (NSString *)uniqueId {
	id uniq = objc_getAssociatedObject(self, kTCUniqueIdKey);
	if (!uniq) {
		CFUUIDRef uuid = CFUUIDCreate(NULL);
		uniq = (id)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
		CFRelease(uuid);
		objc_setAssociatedObject(self, kTCUniqueIdKey, uniq, OBJC_ASSOCIATION_RETAIN);
	}
	return uniq;
}

@end