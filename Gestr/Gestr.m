#import <libactivator/libactivator.h>
#import "GestrController.h"

@interface Gestr : NSObject <LAListener>

@property GestrController *gestrController;
@property BOOL listeningToSleep;

- (BOOL)activatorDismiss;
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event;
- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event;
+ (id)sharedInstance;
+ (void)load;

@end

@implementation Gestr

- (BOOL)activatorDismiss {
	if (_gestrController.activated) {
		[_gestrController deactivate];

		return YES;
	}

	return NO;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	if (![self activatorDismiss]) {
		if (!_listeningToSleep) {
			_listeningToSleep = YES;

			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), deviceSleep, CFSTR("com.apple.springboard.hasBlankedScreen"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		}

		[_gestrController activate];

		[event setHandled:YES];
	}
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
	[self activatorDismiss];
}

- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event {
	[self activatorDismiss];
}

- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event {
	if ([self activatorDismiss]) {
		[event setHandled:YES];
	}
}

static void deviceSleep(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[(__bridge Gestr *)observer activatorDismiss];
}

- (id)init {
	self = [super init];

	_gestrController = [[GestrController alloc] init];

	return self;
}

+ (id)sharedInstance {
	static id gestrInstance = nil;
	if (!gestrInstance) {
		gestrInstance = [[Gestr alloc] init];
	}
	return gestrInstance;
}

+ (void)load {
	@autoreleasepool {
		[[LAActivator sharedInstance] registerListener:[self sharedInstance] forName:@"com.mhuusko5.Gestr"];
	}
}

@end