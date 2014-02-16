#import "GesturePoint.h"

@implementation GesturePoint

- (id)initWithX:(float)x andY:(float)y {
	self = [super init];

	_x = x;
	_y = y;

	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeFloat:_x forKey:@"x"];
	[coder encodeFloat:_y forKey:@"y"];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];

	_x = [coder decodeFloatForKey:@"x"];
	_y = [coder decodeFloatForKey:@"y"];

	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	GesturePoint *copy = [[GesturePoint allocWithZone:zone] initWithX:_x andY:_y];

	return copy;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"X: %f Y: %f", _x, _y];
}

@end
