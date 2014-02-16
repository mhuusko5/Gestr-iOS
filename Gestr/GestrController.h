#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GestureSetupController.h"
#import "GestureRecognitionController.h"
@class GestureSetupController, GestureRecognitionController;

@interface GestrController : NSObject

@property GestureSetupController *gestureSetupController;
@property GestureRecognitionController *gestureRecognitionController;
@property UIWindow *mainWindow;
@property UIView *mainView;
@property BOOL activated;

- (void)deactivate;
- (void)activate;

@end
