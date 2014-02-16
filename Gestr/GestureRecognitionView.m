#import "GestureRecognitionView.h"

@interface GestureRecognitionView ()

@property GestureRecognitionController *recognitionController;
@property NSMutableDictionary *touchPaths;
@property NSMutableDictionary *gestureStrokes;
@property NSMutableArray *orderedStrokeIds;
@property NSDate *lastMultitouchRedraw;
@property NSTimer *noInputTimer;
@property NSTimer *detectInputTimer;

@end

@implementation GestureRecognitionView

- (id)initWithFrame:(CGRect)frame andController:(GestureRecognitionController *)controller {
	self = [super initWithFrame:frame];

	_recognitionController = controller;

	return self;
}

- (void)handleTouches:(NSSet *)touches type:(NSString *)type {
	if (_detectingInput) {
		[self resetInputTimers];

		if (!_detectInputTimer && [type isEqualToString:@"End"]) {
			_detectInputTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(finishDetectingGesture) userInfo:nil repeats:NO];
		}
		else {
			BOOL shouldDraw = ([_lastMultitouchRedraw timeIntervalSinceNow] * -1000.0 > 10);

			for (UITouch *touch in[touches allObjects]) {
				CGPoint drawPoint = [touch locationInView:self];

				NSString *identity = [touch uniqueId];

				if (!_gestureStrokes[identity]) {
					if (_orderedStrokeIds.count < 3) {
						[_orderedStrokeIds addObject:identity];
						_gestureStrokes[identity] = [[GestureStroke alloc] init];
					} else {
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
					[tempPath setLineWidth:self.frame.size.width / 36];
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

- (void)startDetectingGesture {
    [self resetAll];

	_noInputTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(finishDetectingGestureIgnore) userInfo:nil repeats:NO];

    self.multipleTouchEnabled = YES;

	_detectingInput = YES;
}

- (void)finishDetectingGesture {
	[self finishDetectingGesture:YES];
}

- (void)finishDetectingGestureIgnore {
	[self finishDetectingGesture:NO];
}

- (void)finishDetectingGesture:(BOOL)ignore {
	_detectingInput = NO;

    self.multipleTouchEnabled = NO;

	[self resetAll];

	[_recognitionController recognizeGestureWithStrokes:nil];
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
