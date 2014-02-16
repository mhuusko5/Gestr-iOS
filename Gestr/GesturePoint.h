#import <Foundation/Foundation.h>

@interface GesturePoint : NSObject <NSCopying, NSCoding>

@property float x, y;

- (id)initWithX:(float)x andY:(float)y;
- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;
- (id)copyWithZone:(NSZone *)zone;
- (NSString *)description;

@end
