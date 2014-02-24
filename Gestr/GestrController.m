#import "GestrController.h"
OBJC_EXTERN UIImage *_UICreateScreenUIImage(void) NS_RETURNS_RETAINED;

@implementation GestrController

- (id)init {
	self = [super init];

	_gestureRecognitionController = [[GestureRecognitionController alloc] initWithController:self];
	_gestureSetupController = [[GestureSetupController alloc] initWithController:self];

	[_gestureRecognitionController setup];

	return self;
}

- (void)deactivate {
	[_gestureRecognitionController.recognitionView resetAll];

	_mainWindow.hidden = YES;
	_mainWindow = nil;

	_activated = NO;
}

- (void)activate {
	_activated = YES;

	_mainWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_mainWindow.rootViewController = self;
	_mainWindow.windowLevel = UIWindowLevelAlert;
	_mainWindow.exclusiveTouch = YES;
	[_mainWindow makeKeyAndVisible];

	UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:_UICreateScreenUIImage()];
	backgroundImage.frame = _mainWindow.frame;
	[_mainWindow addSubview:backgroundImage];

	FXBlurView *blurView = [[FXBlurView alloc] initWithFrame:_mainWindow.frame];
	blurView.backgroundColor = [UIColor clearColor];
	blurView.tintColor = [UIColor clearColor];
	blurView.dynamic = NO;
	blurView.blurRadius = 40.0f;
	blurView.underlyingView = backgroundImage;
	[_mainWindow addSubview:blurView];

	_mainView = [[UIView alloc] initWithFrame:_mainWindow.frame];
	_mainView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];

	[_gestureSetupController loadInterface];
	[_gestureRecognitionController loadInterface];

	[_mainWindow addSubview:_mainView];
}

@end