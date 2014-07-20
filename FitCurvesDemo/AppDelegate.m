//
//  AppDelegate.m
//  FitCurveDemo
//
//  Created by Stephan Michels on 06.11.11.
//  Copyright (c) 2011 Stephan Michels Softwareentwicklung und Beratung. All rights reserved.
//

#import "AppDelegate.h"
#import "Canvas.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize canvas = _canvas;

- (void)dealloc {
    self.window = nil;
    self.canvas = nil;
    
    [super dealloc];
}

#pragma mark - Application delegate

-(void)applicationDidFinishLaunching:(NSNotification *)notification {
    // Insert code here to initialize your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

#pragma mark - Actions

- (IBAction)selectDouglasPeucker:(id)sender {
    self.canvas.enableDouglasPeucker = [sender state] == NSOnState;
}

- (IBAction)changedTolerance:(id)sender {
    self.canvas.tolerance = [sender floatValue];
}

- (IBAction)selectSchneider:(id)sender {
    self.canvas.enableSchneider = [sender state] == NSOnState;
}

- (IBAction)changedError:(id)sender {
    self.canvas.error = [sender floatValue];
}


@end
