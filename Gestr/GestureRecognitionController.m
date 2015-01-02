#import "GestureRecognitionController.h"

@interface SBApplication : NSObject

- (NSString *)displayName;

@end

@interface SBApplicationController : NSObject

+ (SBApplicationController *)sharedInstance;
- (SBApplication *)applicationWithDisplayIdentifier:(NSString *)identifier;
- (SBApplication *)applicationWithBundleIdentifier:(NSString *)identifier;

@end

@interface SBUIController : NSObject

+ (SBUIController *)sharedInstance;
- (void)activateApplicationFromSwitcher:(id)application;
- (void)activateApplicationAnimated:(id)application;

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
	if ([_recognitionModel anyLoadedGestures]) {
		GestureResult *result = [_recognitionModel.gestureDetector recognizeGestureWithStrokes:strokes];
		int rating;
		if (result && (rating = result.score) >= minimumMatch) {
			NSString *bundleIdToLaunch = result.gestureIdentity;

            SBApplicationController *appController = (SBApplicationController *)[NSClassFromString(@"SBApplicationController") sharedInstance];
            
            SBApplication *appToLaunch;
            if ([appController respondsToSelector:@selector(applicationWithBundleIdentifier:)]) {
                appToLaunch = [appController applicationWithBundleIdentifier:bundleIdToLaunch];
            } else if ([appController respondsToSelector:@selector(applicationWithDisplayIdentifier:)]) {
                appToLaunch = [appController applicationWithDisplayIdentifier:bundleIdToLaunch];
            }
            
			if (appToLaunch) {
				SBUIController *uiController = (SBUIController *)[NSClassFromString(@"SBUIController") sharedInstance];
				if ([uiController respondsToSelector:@selector(activateApplicationFromSwitcher:)]) {
					[uiController activateApplicationFromSwitcher:appToLaunch];
				}
				else {
					[uiController activateApplicationAnimated:appToLaunch];
				}
			}
			else {
				[_recognitionModel deleteGestureWithIdentity:bundleIdToLaunch];

				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gestr" message:@"App for gesture no longer installed... gesture cleared!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
			}
		}
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gestr" message:@"You need to assign some gestures first. Open an app, activate Gestr, tap \"Assign,\" and then draw." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}

	[_gestrController deactivate];
}

- (void)recognizePartialGestureWithStrokes:(NSMutableArray *)strokes {
	if ([_recognitionModel anyLoadedGestures]) {
		_partialRecognition.text = @"";

		GestureResult *result = [_recognitionModel.gestureDetector recognizeGestureWithStrokes:strokes];
		int rating;
		if (result && (rating = result.score) >= minimumMatch) {
			NSString *partialBundleId = result.gestureIdentity;

            SBApplicationController *appController = (SBApplicationController *)[NSClassFromString(@"SBApplicationController") sharedInstance];
            
            SBApplication *appToLaunch;
            if ([appController respondsToSelector:@selector(applicationWithBundleIdentifier:)]) {
                appToLaunch = [appController applicationWithBundleIdentifier:partialBundleId];
            } else if ([appController respondsToSelector:@selector(applicationWithDisplayIdentifier:)]) {
                appToLaunch = [appController applicationWithDisplayIdentifier:partialBundleId];
            }

			if (appToLaunch) {
				_partialRecognition.text = [NSString stringWithFormat:@"%@ – %i%%", [appToLaunch displayName], rating];
			}
			else {
				[_recognitionModel deleteGestureWithIdentity:partialBundleId];
			}
		}
	}
}

- (void)saveGestureWithStrokes:(NSMutableArray *)strokes {
	NSString *currentBundleId = [GestureSetupController LastValidAppBundleId];

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

static int minimumMatch = 80;
static void preferencesChanged() {
	NSDictionary *prefs;
	if (!(prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.mhuusko5.Gestr.plist"])) {
		[prefs writeToFile:@"/var/mobile/Library/Preferences/com.mhuusko5.Gestr.plist" atomically:YES];
		prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.mhuusko5.Gestr.plist"];
	}

	if (prefs[@"MinimumMatch"]) {
		minimumMatch = [prefs[@"MinimumMatch"] intValue];
	}
}

- (void)setup {
	_recognitionModel = [[GestureRecognitionModel alloc] init];
	[_recognitionModel setup];

    preferencesChanged();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)preferencesChanged, CFSTR("com.mhuusko5.Gestr-preferencesChanged"), NULL, 0);
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