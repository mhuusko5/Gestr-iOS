#import "GestrController.h"
#import "GestureRecognitionView.h"
#import "GestureRecognizer.h"
@class GestrController;

@interface GestureRecognitionController : NSObject

- (id)initWithController:(GestrController *)controller;
- (void)recognizeGestureWithStrokes:(NSMutableArray *)strokes;
- (void)loadInterface;

@end
