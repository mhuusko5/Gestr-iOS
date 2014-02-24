#import "GestureRecognizer.h"
#import "UITouch+UniqueID.h"

@interface GestureRecognitionView : UIView

@property BOOL detectingInput;
@property UILabel *alertLabel;

- (void)handleTouches:(NSSet *)touches type:(NSString *)type;
- (void)startDetectingGestureWithTarget:(id)target callback:(SEL)callback andMidCallback:(SEL)midCallback;
- (void)finishDetectingGesture;
- (void)finishDetectingGestureIgnore;
- (void)finishDetectingGesture:(BOOL)ignore;
- (void)checkPartial;
- (void)checkPartialOnNewThread;
- (void)resetAll;

@end