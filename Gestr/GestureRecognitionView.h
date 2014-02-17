#import "GestureRecognizer.h"
#import "UITouch+UniqueID.h"

@interface GestureRecognitionView : UIView

@property BOOL detectingInput;
@property UILabel *alertLabel;

- (void)handleTouches:(NSSet *)touches type:(NSString *)type;
- (void)startDetectingGestureWithTarget:(id)target andCallback:(SEL)callback;
- (void)finishDetectingGesture;
- (void)finishDetectingGestureIgnore;
- (void)finishDetectingGesture:(BOOL)ignore;
- (void)resetInputTimers;
- (void)resetAll;

@end
