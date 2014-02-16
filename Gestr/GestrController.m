#import "GestrController.h"

@implementation GestrController

- (id)init {
	self = [super init];

	_gestureSetupController = [[GestureSetupController alloc] initWithController:self];
	_gestureRecognitionController = [[GestureRecognitionController alloc] initWithController:self];

	return self;
}

- (void)deactivate {
    [UIView animateWithDuration:0.1 animations:^() {
        _mainView.alpha = 0;
    } completion:^(BOOL finished) {
        _mainWindow.hidden = YES;
        _mainWindow = nil;
    }];

    _activated = NO;
}

- (void)activate {
	_activated = YES;

	_mainWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_mainWindow.windowLevel = UIWindowLevelAlert;
	[_mainWindow makeKeyAndVisible];

	_mainView = [[UIView alloc] initWithFrame:_mainWindow.frame];
	_mainView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.92];
    _mainView.alpha = 0;
	[_mainWindow addSubview:_mainView];

	[_gestureSetupController loadInterface];
	[_gestureRecognitionController loadInterface];

    [UIView animateWithDuration:0.2 animations:^() {
        _mainView.alpha = 1;
    }];
}

@end
