//
//  PreferencesController.m
//  as3Debugger
//
//  Created by Lucas Dupin on 26/07/09.
//  Copyright 2009 28.room. All rights reserved.
//

#import "PreferencesController.h"


@implementation PreferencesController

- (IBAction) setGeneralView: (id)sender
{
	NSLog(@"Selecting log view");
	NSLog([[views selectedTabViewItem] identifier]);
	[views selectTabViewItem: [views tabViewItemAtIndex:0]];
}
- (IBAction) setLogView: (id)sender
{
	NSLog(@"Selecting log view");
	NSLog([[views selectedTabViewItem] identifier]);
	[views selectTabViewItem: [views tabViewItemAtIndex:1]];
}
- (IBAction) setDebuggerView: (id)sender
{
	NSLog(@"Selecting debug view");
	NSLog([[views selectedTabViewItem] identifier]);
	[views selectTabViewItem: [views tabViewItemAtIndex:2]];
}

@end
