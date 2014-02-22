#import "GestureRecognitionModel.h"

@interface GestureRecognitionModel ()

@property NSMutableDictionary *gestureDictionary;

@end

@implementation GestureRecognitionModel

- (void)setup {
	[self fetchAndLoadGestures];
}

- (void)fetchAndLoadGestures {
	[self fetchGestureDictionary];

	_gestureDetector = [[GestureRecognizer alloc] init];

	@try {
		for (id plistGestureKey in _gestureDictionary) {
			Gesture *plistGesture = [self getGestureWithIdentity:plistGestureKey];
			if (plistGesture) {
				[_gestureDetector addGesture:plistGesture];
			}
			else {
				@throw [NSException exceptionWithName:@"InvalidGesture" reason:@"Corrupted gesture data." userInfo:nil];
			}
		}
	}
	@catch (NSException *exception)
	{
		_gestureDictionary = [NSMutableDictionary dictionary];
		[self saveGestureDictionary];

		_gestureDetector = [[GestureRecognizer alloc] init];
	}
}

- (BOOL)fetchGestureDictionary {
	NSMutableDictionary *gestures;
	@try {
		NSDictionary *storage = [NSDictionary dictionaryWithContentsOfFile:StoragePath];
		NSData *gestureData;
		if ((gestureData = [storage objectForKey:@"Gestures"])) {
			gestures = [((NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:gestureData])mutableCopy];
		}
		else {
			gestures = [NSMutableDictionary dictionary];
		}
	}
	@catch (NSException *exception)
	{
		gestures = [NSMutableDictionary dictionary];
	}

	_gestureDictionary = gestures;
}

- (void)saveGestureDictionary {
	NSMutableDictionary *storage = [NSMutableDictionary dictionaryWithContentsOfFile:StoragePath];
	if (!storage) {
		storage = [NSMutableDictionary dictionary];
	}
	[storage setObject:[NSKeyedArchiver archivedDataWithRootObject:_gestureDictionary] forKey:@"Gestures"];
	[storage writeToFile:StoragePath atomically:YES];
}

- (BOOL)saveGestureWithStrokes:(NSMutableArray *)gestureStrokes andIdentity:(NSString *)identity {
	int inputPointCount = 0;
	for (GestureStroke *stroke in gestureStrokes) {
		inputPointCount += stroke.pointCount;
	}
	if (inputPointCount > GUMinimumPointCount) {
		Gesture *gestureToSave = [[Gesture alloc] initWithIdentity:identity andStrokes:gestureStrokes];

		_gestureDictionary[identity] = gestureToSave;
		[self saveGestureDictionary];

		[_gestureDetector addGesture:gestureToSave];

		return YES;
	}
	else {
		return NO;
	}
}

- (Gesture *)getGestureWithIdentity:(NSString *)identity {
	Gesture *gesture = _gestureDictionary[identity];
	if (gesture && gesture.identity && gesture.strokes && gesture.strokes.count > 0) {
		return gesture;
	}
	else {
		return nil;
	}
}

- (void)deleteGestureWithIdentity:(NSString *)identity {
	[_gestureDictionary removeObjectForKey:identity];
	[self saveGestureDictionary];

	[_gestureDetector removeGestureWithIdentity:identity];
}

- (BOOL)anyLoadedGestures {
	return ([_gestureDictionary allKeys].count > 0);
}

@end
