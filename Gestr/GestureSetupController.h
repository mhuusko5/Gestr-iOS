#import "GestrController.h"
@class GestrController;

@interface GestureSetupController : NSObject

- (id)initWithController:(GestrController *)controller;
- (void)setup;
- (void)loadInterface;
+ (NSString *)CurrentAppBundleId;
- (void)assignGesture:(id)sender;
- (void)clearGesture:(id)sender;
- (void)configureSetup;

@end
