#import "GestrController.h"
#import "GestureSetupView.h"
@class GestrController;

@interface GestureSetupController : NSObject

- (id)initWithController:(GestrController *)controller;
- (void)setup;
- (void)loadInterface;

@end
