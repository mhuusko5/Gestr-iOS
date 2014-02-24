#import "GestureSetupController.h"

@interface GestureSetupController ()

@property GestrController *gestrController;
@property UIView *setupView;
@property UIButton *clearButton, *assignButton;

@end

@implementation GestureSetupController

- (id)initWithController:(GestrController *)controller {
	self = [super init];

	_gestrController = controller;

	return self;
}

- (void)loadInterface {
	CGRect setupRect = _gestrController.mainView.frame;
	setupRect.size.height *= 0.08;
	setupRect.origin = CGPointMake(0, 0);

	_setupView = [[UIView alloc] initWithFrame:setupRect];
	_setupView.backgroundColor = [UIColor clearColor];

	int dividerSize = (int)(2.0 / [UIScreen mainScreen].scale);

	UIView *horizontalDivider = [[UIView alloc] initWithFrame:CGRectMake(0, setupRect.size.height - dividerSize, setupRect.size.width, dividerSize)];
	horizontalDivider.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
	[_setupView addSubview:horizontalDivider];

	UIView *verticalDivider = [[UIView alloc] initWithFrame:CGRectMake((setupRect.size.width - dividerSize) / 2, 0, dividerSize, setupRect.size.height)];
	verticalDivider.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
	[_setupView addSubview:verticalDivider];

	_clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_clearButton.frame = CGRectMake(0, 0, setupRect.size.width / 2, setupRect.size.height);
	_clearButton.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:_setupView.frame.size.width / 16];
	_clearButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[_setupView addSubview:_clearButton];

	_assignButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_assignButton.frame = CGRectMake(setupRect.size.width / 2, 0, setupRect.size.width / 2, setupRect.size.height);
	_assignButton.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:_setupView.frame.size.width / 16];
	_assignButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[_setupView addSubview:_assignButton];

	[self configureSetup];

	[_gestrController.mainView addSubview:_setupView];
}

static NSString *lastValidAppBundleId;

+ (NSString *)LastValidAppBundleId {
    return lastValidAppBundleId;
}

+ (NSString *)CurrentAppBundleId {
    NSString *bundleId = [[[UIApplication sharedApplication] performSelector:NSSelectorFromString(@"_accessibilityFrontMostApplication")] performSelector:NSSelectorFromString(@"displayIdentifier")];

    if (bundleId) {
        lastValidAppBundleId = bundleId;
    }

	return bundleId;
}

- (void)assignGesture:(id)sender {
	[_assignButton removeTarget:self action:@selector(assignGesture:) forControlEvents:UIControlEventTouchUpInside];

	[_assignButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateNormal];

	[_gestrController.gestureRecognitionController switchToAssignment];
}

- (void)clearGesture:(id)sender {
	[_clearButton removeTarget:self action:@selector(clearGesture:) forControlEvents:UIControlEventTouchUpInside];

	[_clearButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateNormal];

	NSString *currentBundleId = [GestureSetupController LastValidAppBundleId];

	[_gestrController.gestureRecognitionController.recognitionModel deleteGestureWithIdentity:currentBundleId];

	[_gestrController deactivate];

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gestr" message:@"Cleared gesture of current app!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

- (void)configureSetup {
	[_clearButton setTitle:@"Clear" forState:UIControlStateNormal];
	[_clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

	[_assignButton setTitle:@"Assign" forState:UIControlStateNormal];
	[_assignButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

	NSString *currentBundleId = [GestureSetupController CurrentAppBundleId];

	BOOL gestureExists = [_gestrController.gestureRecognitionController.recognitionModel getGestureWithIdentity:currentBundleId];

	if (currentBundleId && gestureExists) {
		[_clearButton addTarget:self action:@selector(clearGesture:) forControlEvents:UIControlEventTouchUpInside];
	}
	else {
		[_clearButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateNormal];
	}

	if (currentBundleId) {
		if (gestureExists) {
			[_assignButton setTitle:@"Reassign" forState:UIControlStateNormal];
		}

		[_assignButton addTarget:self action:@selector(assignGesture:) forControlEvents:UIControlEventTouchUpInside];
	}
	else {
		[_assignButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateNormal];
	}
}

@end