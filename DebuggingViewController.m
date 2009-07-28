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
	projectPath = @"/Users/lucasdupin/Desktop/jun";
	if(projectPath == NULL || [projectPath length] <= 0) {
		NSLog(@"No project, disabling window");
		
		
		NSArray * items = [[debugWindow toolbar] items];
		NSEnumerator *it = [items objectEnumerator];
		id element;
		while ((element = [it nextObject])) {
			[((NSToolbarItem *) element) setEnabled:NO];
		}

		return;
	} else {
		flexPath = [[NSUserDefaults standardUserDefaults] stringForKey: @"flex"];
		fdbPath = [flexPath stringByAppendingString: @"/fdb"];
		
		NSLog([@"FDB command is: " stringByAppendingString:fdbPath]);
		
		//Enabling ONLY connect button
		[connectButton setEnabled:YES];
		[dettachButton setEnabled:NO];
		[stepButton setEnabled:NO];
		[stepOutButton setEnabled:NO];
		[continueTilNextBreakPointButton setEnabled:NO];
	}
	
}
- (IBAction) connect: (id)sender
{
	NSLog(@"Starting FDB");
	if(fdbTask != NULL)
		[fdbTask stopProcess];
	
	//[[TaskWrapper alloc] initWithController:self arguments:[NSArray arrayWithObjects:@"/usr/bin/tail", @"-f", flashlog, nil]];
	fdbTask = [[TaskWrapper alloc] initWithController:self arguments:[NSArray arrayWithObjects: fdbPath, nil]];
	[fdbTask setLaunchPath: flexPath];
	[fdbTask startProcess];
	
	[fdbTask sendData:@"run"];
	
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

- (void)appendOutput:(NSString *)output
{
	NSLog(@"FDB says:");
	NSLog(output);
	
	
	/*******
	 What did fdb mean?
	 *******/
	
	//Did it find an SWF?
	
}
- (void)processStarted{};
- (void)processFinished{};

@end
