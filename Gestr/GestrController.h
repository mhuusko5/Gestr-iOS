#import "GestureSetupController.h"
#import "GestureRecognitionController.h"
#import "FXBlurView.h"
@class GestureSetupController, GestureRecognitionController;

@interface GestrController : UIViewController

@property GestureSetupController *gestureSetupController;
@property GestureRecognitionController *gestureRecognitionController;
@property UIWindow *mainWindow;
@property UIView *mainView;
@property BOOL activated;

- (void)deactivate;
- (void)activate;

@end
