#import "GestrController.h"
#import "GestureRecognitionView.h"
#import "GestureRecognizer.h"
#import "GestureRecognitionModel.h"
#import "GestureSetupController.h"
@class GestrController;

@interface GestureRecognitionController : NSObject

@property GestureRecognitionModel *recognitionModel;
@property GestureRecognitionView *recognitionView;

- (id)initWithController:(GestrController *)controller;
- (void)recognizeGestureWithStrokes:(NSMutableArray *)strokes;
- (void)recognizePartialGestureWithStrokes:(NSMutableArray *)strokes;
- (void)saveGestureWithStrokes:(NSMutableArray *)strokes;
- (void)setup;
- (void)loadInterface;
- (void)configureRecognition;
- (void)switchToAssignment;

@end
