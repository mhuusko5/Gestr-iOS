#import "GestureRecognitionView.h"

@interface GestureRecognitionView ()

@property NSMutableDictionary *touchPaths;
@property NSMutableDictionary *gestureStrokes;
@property NSMutableArray *orderedStrokeIds;
@property NSDate *lastMultitouchRedraw;
@property NSTimer *noInputTimer;
@property NSTimer *detectInputTimer;
@property NSTimer *checkPartialTimer;
@property id callbackTarget;
@property SEL callbackSelector;
@property SEL midCallbackSelector;

@end

@implementation GestureRecognitionView

- (void)handleTouches:(NSSet *)touches type:(NSString *)type {
	if (_detectingInput) {
		if (_alertLabel) {
			[_alertLabel removeFromSuperview];
			_alertLabel = nil;
		}

		[self resetInputTimers];

		if (!_detectInputTimer && [type isEqualToString:@"End"]) {
			_detectInputTimer = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(finishDetectingGesture) userInfo:nil repeats:NO];
		}
		else {
			BOOL shouldDraw = ([_lastMultitouchRedraw timeIntervalSinceNow] * -1000.0 > 15);

			for (UITouch *touch in[touches allObjects]) {
				CGPoint drawPoint = [touch locationInView:self];

				NSString *identity = [touch uniqueId];

				if (!_gestureStrokes[identity]) {
					if (_orderedStrokeIds.count < 3) {
						[_orderedStrokeIds addObject:identity];
						_gestureStrokes[identity] = [[GestureStroke alloc] init];
					}
					else {
						continue;
					}
				}

				GesturePoint *detectorPoint = [[GesturePoint alloc] initWithX:(drawPoint.x / self.frame.size.width) * GUBoundingBoxSize andY:(drawPoint.y / self.frame.size.height) * GUBoundingBoxSize];

				[_gestureStrokes[identity] addPoint:detectorPoint];

				UIBezierPath *tempPath;
				if ((tempPath = _touchPaths[identity])) {
					[tempPath addLineToPoint:drawPoint];
				}
				else {
					tempPath = [UIBezierPath bezierPath];
					[tempPath setLineWidth:self.frame.size.width / 32];
					[tempPath setLineCapStyle:kCGLineCapRound];
					[tempPath setLineJoinStyle:kCGLineJoinRound];
					[tempPath moveToPoint:drawPoint];

					_touchPaths[identity] = tempPath;
				}
			}

			if (shouldDraw) {
				[self setNeedsDisplay];
				_lastMultitouchRedraw = [NSDate date];
			}
		}
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self handleTouches:touches type:@"Begin"];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[self handleTouches:touches type:@"Move"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self handleTouches:touches type:@"End"];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self handleTouches:touches type:@"End"];
}

- (void)startDetectingGestureWithTarget:(id)target callback:(SEL)callback andMidCallback:(SEL)midCallback {
	[self resetAll];

	_noInputTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(finishDetectingGestureIgnore) userInfo:nil repeats:NO];

	self.multipleTouchEnabled = YES;

	_callbackTarget = target;
	_callbackSelector = callback;

	if (midCallback) {
		_midCallbackSelector = midCallback;
		_checkPartialTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(checkPartial) userInfo:nil repeats:YES];
	}

	_detectingInput = YES;
}

- (void)finishDetectingGesture {
	[self finishDetectingGesture:NO];
}

- (void)finishDetectingGestureIgnore {
	[self finishDetectingGesture:YES];
}

- (void)finishDetectingGesture:(BOOL)ignore {
	_detectingInput = NO;

	self.multipleTouchEnabled = NO;

	NSMutableArray *orderedStrokes = [NSMutableArray array];
	if (!ignore) {
		for (int i = 0; i < _orderedStrokeIds.count; i++) {
			[orderedStrokes addObject:_gestureStrokes[_orderedStrokeIds[i]]];
		}
	}

	[self resetAll];

	[_callbackTarget performSelector:_callbackSelector withObject:orderedStrokes];
}

- (void)checkPartial {
	if (_orderedStrokeIds.count > 0) {
		[self performSelectorInBackground:@selector(checkPartialOnNewThread) withObject:nil];
	}
}

- (void)checkPartialOnNewThread {
	NSMutableArray *partialOrderedStrokeIds = [_orderedStrokeIds copy];
	NSMutableDictionary *partialGestureStrokes = [_gestureStrokes copy];

	NSMutableArray *partialOrderedStrokes = [NSMutableArray array];
	for (int i = 0; i < partialOrderedStrokeIds.count; i++) {
		[partialOrderedStrokes addObject:partialGestureStrokes[partialOrderedStrokeIds[i]]];
	}

	[_callbackTarget performSelector:_midCallbackSelector withObject:partialOrderedStrokes];
}

- (void)resetInputTimers {
	if (_noInputTimer) {
		[_noInputTimer invalidate];
		_noInputTimer = nil;
	}

	if (_detectInputTimer) {
		[_detectInputTimer invalidate];
		_detectInputTimer = nil;
	}
}

- (void)resetAll {
	[self resetInputTimers];

	if (_checkPartialTimer) {
		[_checkPartialTimer invalidate];
		_checkPartialTimer = nil;
	}

	_detectingInput = NO;

	self.multipleTouchEnabled = NO;

	_gestureStrokes = [NSMutableDictionary dictionary];
	_orderedStrokeIds = [NSMutableArray array];
	_touchPaths = [NSMutableDictionary dictionary];

	_lastMultitouchRedraw = [NSDate date];

	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	if (_detectingInput) {
		for (UIBezierPath *path in[_touchPaths allValues]) {
			[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.36] setStroke];
			path.lineWidth *= 1.5;
			[path stroke];

			[myGreenColor setStroke];
			path.lineWidth /= 1.5;
			[path stroke];
		}
	}
}

@end
