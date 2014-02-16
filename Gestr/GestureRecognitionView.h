#import <UIKit/UIKit.h>
#import "GestureRecognitionController.h"
@class GestureRecognitionController;

@interface GestureRecognitionView : UIView

- (id)initWithFrame:(CGRect)frame andController:(GestureRecognitionController *)controller;
- (void)startMultitouchInput;

@end
