//
//  PreferencesController.m
//  as3Debugger
//
//  Created by Lucas Dupin on 8/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PreferencesController.h"


@implementation PreferencesController

- (id)init {
    return [super initWithWindowNibName:@"Preferences"];
}
- (void)windowDidLoad {
    
}

-(NSWindow *) getWindow
{
	return window;
}

- (IBAction) selectGeneralTab: (id)sender
{
	[tabView selectTabViewItemAtIndex:0];
}
- (IBAction) selectLogTab: (id)sender
{
	[tabView selectTabViewItemAtIndex:1];
}
- (IBAction) selectDebuggerTab: (id)sender
{
	[tabView selectTabViewItemAtIndex:2];
}

@end
