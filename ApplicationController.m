//
//  ApplicationController.m
//  as3Debugger
//
//  Created by Lucas Dupin on 26/07/09.
//  Copyright 2009 28.room. All rights reserved.
//

#import "ApplicationController.h"


@implementation ApplicationController


//Show window from menu
- (IBAction) showLogWindow: (id)sender
{
	[flashLogWindow makeKeyAndOrderFront:self];
}
- (IBAction) showDebugWindow: (id)sender
{
	[flashDebugWindow makeKeyAndOrderFront:self];
}

//Close after last window left
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

@end
