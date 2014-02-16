#import "GestureRecognitionController.h"
#import "UITouch+UniqueID.h"
@class GestureRecognitionController;

@interface GestureRecognitionView : UIView

@property BOOL detectingInput;

- (id)initWithFrame:(CGRect)frame andController:(GestureRecognitionController *)controller;
- (void)startDetectingGesture;
- (void)finishDetectingGesture;
- (void)finishDetectingGestureIgnore;
- (void)finishDetectingGesture:(BOOL)ignore;

@end
