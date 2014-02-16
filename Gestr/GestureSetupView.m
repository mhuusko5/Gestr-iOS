#import "GestureSetupView.h"

@interface GestureSetupView ()

@property GestureSetupController *setupController;

@end

@implementation GestureSetupView

- (id)initWithFrame:(CGRect)frame andController:(GestureSetupController *)controller {
	self = [super initWithFrame:frame];

	_setupController = controller;

	return self;
}

- (void)drawRect:(CGRect)rect {
}

@end
