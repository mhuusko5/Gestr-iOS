#import "GestureRecognitionController.h"

@interface SBApplication : NSObject @end

@interface UIApplication (Gestr)
- (void)launchApplicationWithIdentifier:(NSString *)identifier suspended:(BOOL)suspended;
@end

@interface GestureRecognitionController ()

@property GestrController *gestrController;
@property UILabel *drawAlert;
@property UILabel *partialRecognition;

@end

@implementation GestureRecognitionController

- (id)initWithController:(GestrController *)controller {
	self = [super init];

	_gestrController = controller;

	return self;
}

- (void)recognizeGestureWithStrokes:(NSMutableArray *)strokes {
	GestureResult *result = [_recognitionModel.gestureDetector recognizeGestureWithStrokes:strokes];
	int rating;
	if (result && (rating = result.score) >= 80) {
		NSString *bundleIdToLaunch = result.gestureIdentity;

		SBApplication *appToLaunch = [[NSClassFromString(@"SBApplicationController") performSelector:NSSelectorFromString(@"sharedInstance")] performSelector:NSSelectorFromString(@"applicationWithDisplayIdentifier:") withObject:bundleIdToLaunch];

		if (appToLaunch) {
			[[UIApplication sharedApplication] launchApplicationWithIdentifier:bundleIdToLaunch suspended:NO];
		}
		else {
			[_recognitionModel deleteGestureWithIdentity:bundleIdToLaunch];

			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gestr" message:@"App for gesture no longer installed... gesture cleared!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
		}
	}

	[_gestrController deactivate];
}

- (void)recognizePartialGestureWithStrokes:(NSMutableArray *)strokes {
	_partialRecognition.text = @"";

	GestureResult *result = [_recognitionModel.gestureDetector recognizeGestureWithStrokes:strokes];
	int rating;
	if (result && (rating = result.score) >= 80) {
		NSString *bundleIdToLaunch = result.gestureIdentity;

		SBApplication *appToLaunch = [[NSClassFromString(@"SBApplicationController") performSelector:NSSelectorFromString(@"sharedInstance")] performSelector:NSSelectorFromString(@"applicationWithDisplayIdentifier:") withObject:bundleIdToLaunch];

		if (appToLaunch) {
			NSString *appName = [appToLaunch performSelector:NSSelectorFromString(@"displayName")];

			_partialRecognition.text = [NSString stringWithFormat:@"%@ – %i%%", appName, rating];
		}
		else {
			[_recognitionModel deleteGestureWithIdentity:bundleIdToLaunch];
		}
	}
}

- (void)saveGestureWithStrokes:(NSMutableArray *)strokes {
	NSString *currentBundleId = [GestureSetupController CurrentAppBundleId];

	NSString *alertString;
	if ([_recognitionModel saveGestureWithStrokes:strokes andIdentity:currentBundleId]) {
		alertString = @"Saved gesture for current app!";
	}
	else {
		alertString = @"Not enough input to create a gesture...";
	}

	[_gestrController deactivate];

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gestr" message:alertString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

- (void)setup {
	_recognitionModel = [[GestureRecognitionModel alloc] init];
	[_recognitionModel setup];
}

- (void)loadInterface {
	CGRect recognitionRect = _gestrController.mainView.frame;
	recognitionRect.size.height *= 0.92;
	recognitionRect.origin = CGPointMake(0, _gestrController.mainView.frame.size.height - recognitionRect.size.height);

	_recognitionView = [[GestureRecognitionView alloc] initWithFrame:recognitionRect];
	_recognitionView.backgroundColor = [UIColor clearColor];

	_drawAlert = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, recognitionRect.size.width, recognitionRect.size.height)];
	_drawAlert.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:_recognitionView.frame.size.width / 12];
	_drawAlert.textAlignment = UITextAlignmentCenter;
	_drawAlert.textColor = [UIColor whiteColor];
	_drawAlert.lineBreakMode = UILineBreakModeWordWrap;
	_drawAlert.numberOfLines = 0;
	[_recognitionView addSubview:_drawAlert];

	_recognitionView.alertLabel = _drawAlert;

	float partialRecognitionFontSize = _recognitionView.frame.size.width / 16;
	float partialRecognitionHeight = partialRecognitionFontSize * 1.4;
	_partialRecognition = [[UILabel alloc] initWithFrame:CGRectMake(partialRecognitionHeight / 2, recognitionRect.size.height - partialRecognitionHeight - (partialRecognitionHeight / 4.0), recognitionRect.size.width - (partialRecognitionHeight / 2), partialRecognitionHeight)];
	_partialRecognition.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:partialRecognitionFontSize];
	_partialRecognition.textAlignment = UITextAlignmentLeft;
	_partialRecognition.textColor = [UIColor whiteColor];
	[_recognitionView addSubview:_partialRecognition];

	[self configureRecognition];

	[_gestrController.mainView addSubview:_recognitionView];

	[_recognitionView startDetectingGestureWithTarget:self callback:@selector(recognizeGestureWithStrokes:) andMidCallback:@selector(recognizePartialGestureWithStrokes:)];
}

- (void)configureRecognition {
	_drawAlert.text = @"Draw to launch\nan app...";
}

- (void)switchToAssignment {
	_drawAlert.text = @"Draw to assign\nto current app...";

	[_recognitionView resetAll];

	[_recognitionView startDetectingGestureWithTarget:self callback:@selector(saveGestureWithStrokes:) andMidCallback:nil];
}

@end
