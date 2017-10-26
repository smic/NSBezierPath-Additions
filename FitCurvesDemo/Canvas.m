//
//  Canvas.m
//  FitCurveDemo
//
//  Created by Stephan Michels on 06.11.11.
//  Copyright (c) 2011 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "Canvas.h"
#import "NSBezierPath+Schneider_FitCurves.h"
#import "NSBezierPath+DouglasPeucker.h"


static char CanvasObservationContext;

@interface Canvas ()

@property (nonatomic, retain) NSMutableArray *points;
@property (nonatomic, retain) NSBezierPath *path;

- (void)drawHandleAtPoint:(NSPoint)point;
- (void)updatePath;

@end

@implementation Canvas

@synthesize enableDouglasPeucker = _enableDouglasPeucker;
@synthesize tolerance = _tolerance;
@synthesize enableSchneider = _enableSchneider;
@synthesize error = _error;

@synthesize points = _points;
@synthesize path = _path;

#pragma mark - Initialization / Deallocation

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.enableDouglasPeucker = YES;
        self.enableSchneider = YES;
        
        // add observer for properties
        [self addObserver:self 
               forKeyPath:@"enableDouglasPeucker" 
                  options:(NSKeyValueObservingOptionNew) 
                  context:&CanvasObservationContext];
        [self addObserver:self 
               forKeyPath:@"tolerance" 
                  options:(NSKeyValueObservingOptionNew) 
                  context:&CanvasObservationContext];
        [self addObserver:self 
               forKeyPath:@"enableSchneider" 
                  options:(NSKeyValueObservingOptionNew) 
                  context:&CanvasObservationContext];
        [self addObserver:self 
               forKeyPath:@"error" 
                  options:(NSKeyValueObservingOptionNew) 
                  context:&CanvasObservationContext];
    }
    return self;
}

- (void)dealloc {
    // remove observer for properties
    [self removeObserver:self 
              forKeyPath:@"tolerance" 
                 context:&CanvasObservationContext];
    [self removeObserver:self 
              forKeyPath:@"error" 
                 context:&CanvasObservationContext];
    
    self.points = nil;
    self.path = nil;
    
    [super dealloc];
}

#pragma mark - Drawing

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    NSRect bounds = self.bounds;
    
    // draw background
    [[NSColor whiteColor] setFill];
    NSRectFill(rect);
    [[NSColor darkGrayColor] set];
    NSFrameRect(bounds);
    
//    [[NSColor colorWithDeviceRed:22.0f/255.0f green:32.0f/55.0f blue:27.0f/255.0f alpha:1.0f] set];
//	self.path.lineWidth = 20.0f;
//	[self.path stroke];
//	
//	[[NSColor colorWithDeviceRed:30.0f/255.0f green:60.0f/55.0f blue:75.0f/255.0f alpha:0.8f] set];
//	self.path.lineWidth = 0.0f;
//	[self.path stroke];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    if ([self.points count] > 0) {
        NSPoint point = [[self.points objectAtIndex:0] pointValue];
        [path moveToPoint:point];
    }
    for (NSUInteger pointIndex = 1; pointIndex < [self.points count]; pointIndex++) {
        NSPoint point = [[self.points objectAtIndex:pointIndex] pointValue];
        [path lineToPoint:point];
    }
    [[NSColor cyanColor] set];
    [path stroke];
    
//    [[NSColor redColor] set];
//    [self.path stroke];
    
    [[NSColor colorWithDeviceRed:22.0f/255.0f green:32.0f/55.0f blue:27.0f/255.0f alpha:1.0f] set];
    self.path.lineWidth = 0.0f;
	[self.path stroke];
    
//    [self.vectorizer draw];
    
    CGFloat dashPattern[2];
	dashPattern[0] = 5.0f;
	dashPattern[1] = 2.0f;
    
    // draw tangents to the control points
    NSPoint points[3];
    NSPoint previousPoint = NSZeroPoint; // TODO: Check, if this is a good initial value.
    NSUInteger numberOfElements = [self.path elementCount];
    for (NSUInteger elementIndex = 0; elementIndex < numberOfElements; elementIndex++) {
        NSBezierPathElement element = [self.path elementAtIndex:(NSInteger)elementIndex associatedPoints:points];
        switch (element) {
            case NSMoveToBezierPathElement: {
                previousPoint = points[0];
            } break;
                
            case NSLineToBezierPathElement: {
                previousPoint = points[0];
            } break;
                
            case NSCurveToBezierPathElement: {
                [[NSColor redColor] set];
                NSBezierPath *path2 = [NSBezierPath bezierPath];
                [path2 setLineDash:dashPattern count: 2 phase: 0.0];
                [path2 moveToPoint:previousPoint];
                [path2 lineToPoint:points[0]];
                [path2 moveToPoint:points[1]];
                [path2 lineToPoint:points[2]];
                [path2 stroke];
                
                previousPoint = points[2];
            } break;
                
            case NSClosePathBezierPathElement: {
            } break;
                
            default:
                break;
        }
    }
    
    // draw handle for all points
    for (NSUInteger elementIndex = 0; elementIndex < numberOfElements; elementIndex++) {
        NSBezierPathElement element = [self.path elementAtIndex:(NSInteger)elementIndex associatedPoints:points];
        switch (element) {
            case NSMoveToBezierPathElement: {
                [[NSColor whiteColor] set];
                [self drawHandleAtPoint:points[0]];
                
                previousPoint = points[0];
            } break;
                
            case NSLineToBezierPathElement: {
                [[NSColor whiteColor] set];
                [self drawHandleAtPoint:points[0]];
                
                previousPoint = points[0];
            } break;
                
            case NSCurveToBezierPathElement: {
                [[NSColor redColor] set];
                [self drawHandleAtPoint:points[0]];
                [[NSColor redColor] set];
                [self drawHandleAtPoint:points[1]];
                [[NSColor whiteColor] set];
                [self drawHandleAtPoint:points[2]];
                
                previousPoint = points[2];
            } break;
                
            case NSClosePathBezierPathElement: {
            } break;
                
            default:
                break;
        }
    }
}

- (void)drawHandleAtPoint:(NSPoint)point {
    NSRect rect = NSInsetRect(NSMakeRect(point.x, point.y, 0, 0), -3, -3);
	NSRectFill(rect);
    [[NSColor blackColor] set];
    NSFrameRect(rect);
}

#pragma mark - User interaction

- (void)mouseDown:(NSEvent *)event {
//    DLog(@"Mouse down: %@", event);
    
    self.points = [NSMutableArray arrayWithCapacity:100];
    self.path = nil;
    
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    [self.points addObject:[NSValue valueWithPoint:point]];
    
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event {
//    DLog(@"Mouse up: %@", event);
    
    [self updatePath];
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)event {
//    DLog(@"Mouse dragged: %@", event);
    
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    [self.points addObject:[NSValue valueWithPoint:point]];
    
    [self setNeedsDisplay:YES];
}

#pragma mark - KVO

- (void)updatePath {
    NSBezierPath *path = [NSBezierPath bezierPath];
    BOOL firstPoint = YES;
    for (NSUInteger pointIndex = 0; pointIndex < [self.points count]; pointIndex++) {
        NSPoint point = [[self.points objectAtIndex:pointIndex] pointValue];
        if (firstPoint) {
            [path moveToPoint:point];
            firstPoint = NO;
        } else {
            [path lineToPoint:point];
        }
    }
    if (self.enableDouglasPeucker) {
        path = [path pathFromDouglasPeuckerReduction:self.tolerance];
    }
    if (self.enableSchneider) {
        [path schneiderFitCurves:self.error];
    }
    self.path = path;

}

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context {
    if (context != &CanvasObservationContext) {
        [super observeValueForKeyPath:keyPath 
                             ofObject:object 
                               change:change 
                              context:context];
        return;
    }
    
    if ([keyPath isEqualToString:@"enableDouglasPeucker"] || 
        [keyPath isEqualToString:@"tolerance"] || 
        [keyPath isEqualToString:@"enableSchneider"] || 
        [keyPath isEqualToString:@"error"]) {
        
        [self updatePath];
        [self setNeedsDisplay:YES];
    }
}


@end
