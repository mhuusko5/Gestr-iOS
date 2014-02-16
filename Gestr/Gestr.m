#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <libactivator/libactivator.h>

@interface Gestr : NSObject <LAListener> {
@private
    UIWindow *mainWindow;
	UIView *mainView;
}
@end

@implementation Gestr

- (BOOL)dismiss {
	if (mainWindow) {
		mainWindow.hidden = YES;
        mainWindow = nil;

		return YES;
	}
	return NO;
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
	if (![self dismiss]) {
        mainWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        mainWindow.windowLevel = [[UIApplication sharedApplication] keyWindow].windowLevel + 1;
        [mainWindow makeKeyAndVisible];

        mainView = [[UIView alloc] initWithFrame: mainWindow.frame];
        mainView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        mainView.alpha = 0;
        [mainWindow addSubview:mainView];
        [UIView animateWithDuration:0.1 animations:^(void) {
            mainView.alpha = 1;
        }];

		[event setHandled:YES];
	}
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event {
	// Called when event is escalated to higher event
	[self dismiss];
}

- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event {
	// Called when other listener receives an event
	[self dismiss];
}

- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event {
	// Called when the home button is pressed.
	// If showing UI, then dismiss it and call setHandled:.
	if ([self dismiss]) {
		[event setHandled:YES];
	}
}

+ (void)load {
	@autoreleasepool
	{
		[[LAActivator sharedInstance] registerListener:[self new] forName:@"com.mhuusko5.Gestr"];
	}
}

@end
