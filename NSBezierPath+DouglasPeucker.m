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

@interface NSBezierPath()
- (void) douglasPeuckerReductionTolerance:(double)tolerance 
                               firstIndex:(NSUInteger)first 
                                lastIndex:(NSUInteger)last 
                            indexesToKepp:(NSMutableIndexSet *)indexesToKeep;

@end

CGFloat distancePointFromLine(NSPoint a, NSPoint b, NSPoint c) {
    
    CGFloat lA = sqrt((abs(b.x)-abs(c.x))*(abs(b.x)-abs(c.x))+(abs(b.y)-abs(c.y))*(abs(b.y)-abs(c.y)));
    CGFloat lB = sqrt((abs(a.x)-abs(c.x))*(abs(a.x)-abs(c.x))+(abs(a.y)-abs(c.y))*(abs(a.y)-abs(c.y)));
    CGFloat lC = sqrt((abs(b.x)-abs(a.x))*(abs(b.x)-abs(a.x))+(abs(b.y)-abs(a.y))*(abs(b.y)-abs(a.y)));
    
    return sqrt(2*(lA*lA*lB*lB+lB*lB*lC*lC+lC*lC*lA*lA)-(lA*lA*lA*lA+lB*lB*lB*lB+lC*lC*lC*lC)/(2*lA));
    
}

static CGFloat perpendicularDistance (NSPoint Point1, NSPoint Point2, NSPoint Point)
{
    //Area = |(1/2)(x1y2 + x2y3 + x3y1 - x2y1 - x3y2 - x1y3)|   *Area of triangle
    //Base = v((x1-x2)²+(x1-x2)²)                               *Base of Triangle*
    //Area = .5*Base*H                                          *Solve for height
    //Height = Area/.5/Base
    
    CGFloat area = abs(.5f * (Point1.x * Point2.y + Point2.x * Point.y + Point.x * Point1.y - Point2.x * Point1.y - Point.x * Point2.y - Point1.x * Point.y));
    CGFloat bottom = sqrt(pow(Point1.x - Point2.x, 2) + 
                          pow(Point1.y - Point2.y, 2));
    CGFloat height = area / bottom * 2.0f;
    
    return height;
    

}

@implementation NSBezierPath (NSBezierPath_DouglasPeucker)


- (NSBezierPath *) pathFromDouglasPeuckerReduction:(double)tolerance {
    for (NSUInteger elementIndex = 0; elementIndex < [self elementCount]; elementIndex++) {
        if ([self elementAtIndex:elementIndex] == NSCurveToBezierPathElement) {
            return nil;   
        }
    }
    
    NSMutableIndexSet *indexesToKeep = [[NSMutableIndexSet indexSet] retain];
    [indexesToKeep addIndex:0];
    [indexesToKeep addIndex:[self elementCount]-1];
    [self douglasPeuckerReductionTolerance:tolerance 
                                firstIndex:0 
                                 lastIndex:[self elementCount] - 1 
                             indexesToKepp:indexesToKeep];
    
    NSBezierPath *newPath = [[NSBezierPath bezierPath] retain];
    NSPointArray pointArray = malloc(sizeof(NSPoint)*3);
    [indexesToKeep enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
        NSBezierPathElement elementTyp = [self elementAtIndex:idx associatedPoints:pointArray];
        switch (elementTyp) {
            case NSMoveToBezierPathElement:
                [newPath moveToPoint:pointArray[0]];
                break;
            case NSLineToBezierPathElement:
                [newPath lineToPoint:pointArray[0]];
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
    return [newPath autorelease];
}

- (void) douglasPeuckerReductionTolerance:(double)tolerance 
                               firstIndex:(NSUInteger)first 
                                lastIndex:(NSUInteger)last 
                            indexesToKepp:(NSMutableIndexSet *)indexesToKeep { 
    if (first==last) {
        return;
    }
    double distance = 0, maxDistance = 0;
    NSUInteger indexFarthest = 0;
    
    NSPoint points[3];
    [self elementAtIndex:first associatedPoints:points];
    NSPoint firstPoint = points[0];
    [self elementAtIndex:last associatedPoints:points];

    NSPoint lastPoint = points[0];
    
    for (NSUInteger elementIndex = first + 1; elementIndex < last; elementIndex++) {
        if(NSCurveToBezierPathElement ==[self elementAtIndex:elementIndex associatedPoints:points]) {
            NSLog(@"Wrong PathElement Type");
        }
        
        distance = perpendicularDistance(firstPoint, lastPoint, points[0]);
        // if the current distance is larger then the other distances
        if (distance > maxDistance) {
            maxDistance=distance;
            indexFarthest = elementIndex;
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
