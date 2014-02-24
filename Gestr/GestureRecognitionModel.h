#import "GestureRecognizer.h"

@interface GestureRecognitionModel : NSObject

@property GestureRecognizer *gestureDetector;

- (void)setup;
- (void)fetchAndLoadGestures;
- (BOOL)fetchGestureDictionary;
- (void)saveGestureDictionary;
- (BOOL)saveGestureWithStrokes:(NSMutableArray *)gestureStrokes andIdentity:(NSString *)identity;
- (Gesture *)getGestureWithIdentity:(NSString *)identity;
- (void)deleteGestureWithIdentity:(NSString *)identity;
- (BOOL)anyLoadedGestures;

@end