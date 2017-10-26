//
//  NSBezierPath+DouglasPeucker.m
//
//  Created by Tobias Conradi on 28.04.11.
//  Copyright 2011 Tobias Conradi. All rights reserved.
//  https://github.com/toco/NSBezierPath-Additions
//  
//  port from C# implentation:
//  http://www.codeproject.com/KB/cs/Douglas-Peucker_Algorithm.aspx
//  http://tobias-conradi.de/index.php/2011/05/06/nsbezierpath-additions

#import "NSBezierPath+DouglasPeucker.h"

#import <tgmath.h>


static CGFloat distancePointFromLine(NSPoint a, NSPoint b, NSPoint c) {
    
    CGFloat lA = sqrt((fabs(b.x)-fabs(c.x))*(fabs(b.x)-fabs(c.x))+(fabs(b.y)-fabs(c.y))*(fabs(b.y)-fabs(c.y)));
    CGFloat lB = sqrt((fabs(a.x)-fabs(c.x))*(fabs(a.x)-fabs(c.x))+(fabs(a.y)-fabs(c.y))*(fabs(a.y)-fabs(c.y)));
    CGFloat lC = sqrt((fabs(b.x)-fabs(a.x))*(fabs(b.x)-fabs(a.x))+(fabs(b.y)-fabs(a.y))*(fabs(b.y)-fabs(a.y)));
    
    return sqrt(2*(lA*lA*lB*lB+lB*lB*lC*lC+lC*lC*lA*lA)-(lA*lA*lA*lA+lB*lB*lB*lB+lC*lC*lC*lC)/(2*lA));
    
}

static CGFloat perpendicularDistance (NSPoint point1, NSPoint point2, NSPoint point) {
    //Area = |(1/2)(x1y2 + x2y3 + x3y1 - x2y1 - x3y2 - x1y3)|   *Area of triangle
    //Base = v((x1-x2)²+(x1-x2)²)                               *Base of Triangle*
    //Area = .5*Base*H                                          *Solve for height
    //Height = Area/.5/Base
    
    CGFloat area = fabs(.5f * (point1.x * point2.y +
                               point2.x * point.y  +
                               point.x  * point1.y -
                               point2.x * point1.y -
                               point.x  * point2.y -
                               point1.x * point.y));
    CGFloat bottom = hypotf(point1.x - point2.x, point1.y - point2.y);
    CGFloat height = area / bottom * 2.0f;
    
    return height;
    

}

@implementation NSBezierPath (NSBezierPath_DouglasPeucker)


- (NSBezierPath *)pathFromDouglasPeuckerReduction:(CGFloat)tolerance {
    if ([self elementCount] <= 2) {
        return self;
    }
    
    for (NSUInteger elementIndex = 0; elementIndex < [self elementCount]; elementIndex++) {
        if ([self elementAtIndex:elementIndex] == NSCurveToBezierPathElement) {
            return nil;   
        }
    }
    
    NSMutableIndexSet *indexesToKeep = [[NSMutableIndexSet indexSet] retain];
    [indexesToKeep addIndex:0];
    [indexesToKeep addIndex:[self elementCount] - 1];
    [self douglasPeuckerReductionTolerance:tolerance 
                                firstIndex:0 
                                 lastIndex:[self elementCount] - 1 
                             indexesToKepp:indexesToKeep];
    
    NSBezierPath *newPath = [NSBezierPath bezierPath];
    [indexesToKeep enumerateIndexesUsingBlock:^(NSUInteger elementIndex, BOOL *stop){
        NSPoint points[3];
        NSBezierPathElement elementTyp = [self elementAtIndex:elementIndex associatedPoints:points];
        switch (elementTyp) {
            case NSMoveToBezierPathElement:
                [newPath moveToPoint:points[0]];
                break;
            case NSLineToBezierPathElement:
                [newPath lineToPoint:points[0]];
                break;
            case NSClosePathBezierPathElement:
                [newPath closePath];
                break;
            default:
                NSLog(@"Wrong Elementtyp");
                break;
        }
    }];

    [newPath setWindingRule:[self windingRule]];
    [newPath setLineCapStyle:[self lineCapStyle]];
    [newPath setLineJoinStyle:[self lineJoinStyle]];
    [newPath setLineWidth:[self lineWidth]];
    [newPath setMiterLimit:[self miterLimit]];
    [newPath setFlatness:[self flatness]];
    CGFloat *lineDash, phase;
    NSInteger count;
    [self getLineDash:lineDash count:&count phase:&phase];
    [newPath setLineDash:lineDash count:count phase:phase];
    return newPath;
}

- (void)douglasPeuckerReductionTolerance:(CGFloat)tolerance 
                              firstIndex:(NSUInteger)first 
                               lastIndex:(NSUInteger)last 
                           indexesToKepp:(NSMutableIndexSet *)indexesToKeep { 
    if (first == last) {
        return;
    }
    
    NSPoint points[3];
    [self elementAtIndex:first associatedPoints:points];
    NSPoint firstPoint = points[0];
    [self elementAtIndex:last associatedPoints:points];

    NSPoint lastPoint = points[0];
    CGFloat maxDistance = 0;
    NSUInteger indexFarthest = 0;
    for (NSUInteger elementIndex = first + 1; elementIndex < last; elementIndex++) {
        NSBezierPathElement elementTyp = [self elementAtIndex:elementIndex associatedPoints:points];
        switch (elementTyp) {
            case NSMoveToBezierPathElement:
            case NSLineToBezierPathElement: {
                CGFloat distance = perpendicularDistance(firstPoint, lastPoint, points[0]);
                // if the current distance is larger then the other distances
                if (distance > maxDistance) {
                    maxDistance = distance;
                    indexFarthest = elementIndex;
                }
            } break;
            case NSClosePathBezierPathElement:
                // nothing
                break;
            default:
                NSLog(@"Wrong Elementtyp");
                break;
        }
    }
    
    
    if (maxDistance > tolerance && indexFarthest != 0) {
        //add index of Point to list of Points to keep
        [indexesToKeep addIndex:indexFarthest];

        [self douglasPeuckerReductionTolerance:tolerance 
                                    firstIndex:first 
                                     lastIndex:indexFarthest 
                                 indexesToKepp:indexesToKeep];
        [self douglasPeuckerReductionTolerance:tolerance 
                                    firstIndex:indexFarthest 
                                     lastIndex:last 
                                 indexesToKepp:indexesToKeep];
    }
    
}

@end
