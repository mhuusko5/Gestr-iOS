#import "GestureSetupController.h"

@interface GestureSetupController ()

@property GestrController *gestrController;
@property GestureSetupView *setupView;

@end

@implementation GestureSetupController

- (id)initWithController:(GestrController *)controller {
	self = [super init];

	_gestrController = controller;

	return self;
}

- (void)loadInterface {
	CGRect setupRect = _gestrController.mainView.frame;
	setupRect.size.height *= 0.15;
	setupRect.origin = CGPointMake(0, 0);

	_setupView = [[GestureSetupView alloc] initWithFrame:setupRect andController:self];
    _setupView.backgroundColor = [UIColor clearColor];

    int dividerHeight = (int)(2.0 / [UIScreen mainScreen].scale);
    UIView *whiteDivider = [[UIView alloc] initWithFrame:CGRectMake(0, setupRect.size.height - dividerHeight, setupRect.size.width, dividerHeight)];
    whiteDivider.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    [_setupView addSubview:whiteDivider];

	[_gestrController.mainView addSubview:_setupView];
}

@end
