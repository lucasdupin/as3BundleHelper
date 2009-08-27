//
//  ApplicationController.m
//  as3Debugger
//
//  Created by Lucas Dupin on 8/12/09.
//  Copyright 2009 Gringo. All rights reserved.
//

#import "ApplicationController.h"


@implementation ApplicationController

- (void)awakeFromNib
{
}

- (void)applicationWillTerminate: (NSNotification *)note
{
	[traceController stopTask];
	[debuggingViewController stopTask];
}

- (IBAction) showLogViewer: (id)sender
{
	[[traceController getWindow] orderFront: self]; 
}
- (IBAction) showDebuggingView: (id)sender
{
	NSLog(@"%@ window", debugWindow);
	[[debuggingViewController getWindow] makeKeyAndOrderFront:self];
	
//	NSWindow* win = ;
//	[win makeKeyAndOrderFront:self];
}

@end
