#import "GestureRecognizer.h"

@implementation GestureRecognizer

- (id)init {
	self = [super init];

	_loadedGestures = [NSMutableArray array];

	return self;
}

- (GestureResult *)recognizeGestureWithStrokes:(NSMutableArray *)strokes {
	@try {
		GestureStroke *currentPoints = [[GestureStroke alloc] init];
		for (GestureStroke *stroke in strokes) {
			for (GesturePoint *point in stroke.points) {
				[currentPoints addPoint:point];
			}
		}

		GestureResult *result = [[GestureResult alloc] init];

		if (currentPoints.pointCount > GUMinimumPointCount) {
			GestureTemplate *inputTemplate = [[GestureTemplate alloc] initWithPoints:currentPoints];

			float lowestDistance = FLT_MAX;
			for (int i = 0; i < _loadedGestures.count; i++) {
				Gesture *gestureToMatch = _loadedGestures[i];

				if (gestureToMatch.strokes.count == strokes.count) {
					NSMutableArray *loadedGestureTemplates = [gestureToMatch templates];

					for (GestureTemplate *templateToMatch in loadedGestureTemplates) {
						if (GUAngleBetweenUnitVectors(inputTemplate.startUnitVector, templateToMatch.startUnitVector) <= GUDegreesToRadians(GUStartAngleLeniency)) {
							float distance = GUDistanceAtBestAngle(inputTemplate.stroke, templateToMatch.stroke);
							if (distance < lowestDistance) {
								lowestDistance = distance;

								result.gestureIdentity = gestureToMatch.identity;
								result.score = (int)ceilf(100.0 * (1.0 - (lowestDistance / (0.5 * sqrt(2 * pow(GUBoundingBoxSize, 2))))));
							}
						}
					}
				}
			}
		}

		if (result.gestureIdentity.length > 0 && result.score > 0) {
			return result;
		}
	}
	@catch (NSException *exception)
	{
		return nil;
	}

	return nil;
}

- (void)removeGestureWithIdentity:(NSString *)identity {
	for (int i = 0; i < _loadedGestures.count; i++) {
		if ([((Gesture *)_loadedGestures[i]).identity isEqualToString:identity]) {
			[_loadedGestures removeObjectAtIndex:i];
			return;
		}
	}
}

- (void)addGesture:(Gesture *)gesture {
	[self removeGestureWithIdentity:gesture.identity];

	[gesture generateTemplates];

	[_loadedGestures addObject:gesture];
}

@end
