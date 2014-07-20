//
//  AppDelegate.h
//  FitCurveDemo
//
//  Created by Stephan Michels on 06.11.11.
//  Copyright (c) 2011 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class Canvas;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) IBOutlet Canvas *canvas;

@end
