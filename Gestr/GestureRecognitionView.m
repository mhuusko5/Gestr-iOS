#import "GestureRecognitionView.h"

@interface GestureRecognitionView ()

@property GestureRecognitionController *recognitionController;

@end

@implementation GestureRecognitionView

- (id)initWithFrame:(CGRect)frame andController:(GestureRecognitionController *)controller {
	self = [super initWithFrame:frame];

	_recognitionController = controller;

	return self;
}

- (void)startMultitouchInput {
}

- (void)drawRect:(CGRect)rect {
}

@end
