#import "GestureRecognitionController.h"

@interface GestureRecognitionController ()

@property GestrController *gestrController;
@property GestureRecognitionView *recognitionView;

@end

@implementation GestureRecognitionController

- (id)initWithController:(GestrController *)controller {
	self = [super init];

	_gestrController = controller;

	return self;
}

- (void)recognizeGestureWithStrokes:(NSMutableArray *)strokes {
	[_gestrController deactivate];
}

- (void)loadInterface {
	CGRect recognitionRect = _gestrController.mainView.frame;
	recognitionRect.size.height *= 0.85;
	recognitionRect.origin = CGPointMake(0, _gestrController.mainView.frame.size.height - recognitionRect.size.height);

	_recognitionView = [[GestureRecognitionView alloc] initWithFrame:recognitionRect andController:self];
	_recognitionView.backgroundColor = [UIColor clearColor];

	//CUSTOM

	[_gestrController.mainView addSubview:_recognitionView];

	[_recognitionView startDetectingGesture];
}

@end
