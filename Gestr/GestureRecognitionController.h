#import <Foundation/Foundation.h>
#import "GestrController.h"
#import "GestureRecognitionView.h"
@class GestrController;

@interface GestureRecognitionController : NSObject

- (id)initWithController:(GestrController *)controller;
- (void)loadInterface;

@end
