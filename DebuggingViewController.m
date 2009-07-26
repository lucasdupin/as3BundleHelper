//
//  DebuggingViewController.m
//  as3Debugger
//
//  Created by Lucas Dupin on 26/07/09.
//  Copyright 2009 28.room. All rights reserved.
//

#import "DebuggingViewController.h"


@implementation DebuggingViewController

- (void)awakeFromNib
{
	//Did we receive a project path?
	projectPath = [[NSUserDefaults standardUserDefaults] stringForKey: @"flashlog"];
	if(projectPath == NULL) {
		NSLog(@"No project, disabling window");
		
		
		NSArray * items = [[debugWindow toolbar] items];
		NSEnumerator *it = [items objectEnumerator];
		id element;
		while ((element = [it nextObject])) {
			[((NSToolbarItem *) element) setEnabled:NO];
			NSLog(@"found something");
		}
	}
	
}
- (IBAction) connect: (id)sender
{
	
}

- (IBAction) step: (id)sender
{
	
}
- (IBAction) stepOut: (id)sender
{
	
}
- (IBAction) continueTilNextBreakPoint: (id)sender
{
	
}
- (IBAction) dettach: (id)sender
{
	
}

@end
