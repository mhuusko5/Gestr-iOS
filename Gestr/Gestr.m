#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <libactivator/libactivator.h>
#import "GestrController.h"

@interface Gestr : NSObject <LAListener> {
	GestrController *gestrController;
}
@end

@implementation Gestr

- (BOOL)activatorDismiss {
	if (gestrController.activated) {
		[gestrController deactivate];

		return YES;
	}

	return NO;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	if (![self activatorDismiss]) {
		[gestrController activate];

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
	[(Gestr *)observer activatorDismiss];
}

- (id)init {
	self = [super init];

	gestrController = [[GestrController alloc] init];

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), self, deviceSleep, CFSTR("com.apple.springboard.hasBlankedScreen"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	return self;
}

+ (Gestr *)sharedInstance {
	static Gestr *gestrInstance = nil;
	@synchronized(self)
	{
		if (!gestrInstance) {
			gestrInstance = [[Gestr alloc] init];
		}
	}
	return gestrInstance;
}

+ (void)load {
	@autoreleasepool
	{
		[[LAActivator sharedInstance] registerListener:[Gestr sharedInstance] forName:@"com.mhuusko5.Gestr"];
	}
}

@end
