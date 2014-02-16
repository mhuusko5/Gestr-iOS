#import "GestureSetupController.h"

@interface GestureSetupController ()

@property GestrController *gestrController;
@property GestureSetupView *setupView;
@property UIButton *clearButton, *assignButton;

@end

@implementation GestureSetupController

- (id)initWithController:(GestrController *)controller {
	self = [super init];

	_gestrController = controller;

	return self;
}

- (void)setup {
    
}

- (void)loadInterface {
	CGRect setupRect = _gestrController.mainView.frame;
	setupRect.size.height *= 0.08;
	setupRect.origin = CGPointMake(0, 0);

	_setupView = [[GestureSetupView alloc] initWithFrame:setupRect andController:self];
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
	[_setupView addSubview:_clearButton];

	_assignButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_assignButton.frame = CGRectMake(setupRect.size.width / 2, 0, setupRect.size.width / 2, setupRect.size.height);
	[_setupView addSubview:_assignButton];

	[self configureSetup];

	[_gestrController.mainView addSubview:_setupView];
}

NSString* CurrentAppBundleId() {
    NSString *bundleId = [[[UIApplication sharedApplication] performSelector:NSSelectorFromString(@"_accessibilityFrontMostApplication")] performSelector:NSSelectorFromString(@"displayIdentifier")];
    if (!bundleId) {
        bundleId = @"com.apple.springboard";
    }

    return bundleId;
}

- (void)configureSetup {
	[_clearButton setTitle:@"Clear" forState:UIControlStateNormal];
	[_clearButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateNormal];
	_clearButton.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:_setupView.frame.size.width / 16];
	_clearButton.titleLabel.textAlignment = UITextAlignmentCenter;

	[_assignButton setTitle:@"Assign" forState:UIControlStateNormal];
	[_assignButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateNormal];
	_assignButton.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:_setupView.frame.size.width / 16];
	_assignButton.titleLabel.textAlignment = UITextAlignmentCenter;

	NSString *currentBundleId = CurrentAppBundleId();
}

@end
