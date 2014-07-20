//
//  Canvas.h
//  FitCurveDemo
//
//  Created by Stephan Michels on 06.11.11.
//  Copyright (c) 2011 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Canvas : NSView

@property (nonatomic, assign) BOOL enableDouglasPeucker;
@property (nonatomic, assign) CGFloat tolerance;
@property (nonatomic, assign) BOOL enableSchneider;
@property (nonatomic, assign) double error;

@end
