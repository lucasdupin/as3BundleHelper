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
	}
	
	flexPath = [[NSUserDefaults standardUserDefaults] stringForKey: @"flex"];
	if(flexPath == nil)
		flexPath = @"/Users/lucasdupin/src/Flex/";

	fdbCommandPath = [[NSString alloc] initWithString:[[flexPath stringByAppendingString: @"bin/fdb"] autorelease]];
	[fdbCommandPath retain];
	
	//NSLog(@"FDB command is: %@", fdbCommandPath);
	
	//Enabling ONLY connect button
	[connectButton setEnabled:YES];
	[dettachButton setEnabled:NO];
	[stepButton setEnabled:NO];
	[stepOutButton setEnabled:NO];
	[continueTilNextBreakPointButton setEnabled:NO];
	
}
- (IBAction) connect: (id)sender
{
	if(fdbTask != NULL)
		[fdbTask stopProcess];
	
	//Reading breakpoints
	[self setBreakpointsForPath: projectPath];
	
	NSLog(@"FDB Command: %@", fdbCommandPath);
	NSArray * command = [NSArray arrayWithObjects: fdbCommandPath, nil];
	fdbTask = [[TaskWrapper alloc] initWithController:self arguments:command];
	[fdbTask setLaunchPath: flexPath];
	[fdbTask startProcess];
	
	[fdbTask sendData:@"run"];
	
	
}

- (void) setBreakpointsForPath: (NSString *)path
{
	NSFileHandle * file;
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
	while (file = [enumerator nextObject])
	{
		//No hidden files, please
		NSPredicate *regexHidden = [NSPredicate predicateWithFormat: @"SELF MATCHES %@",@"^[\\.].*"]; //Begins with .
		NSPredicate *regexHiddenPath = [NSPredicate predicateWithFormat: @"SELF MATCHES %@",@"/[\\.].*"]; //Contains a hidden path
		if([regexHidden evaluateWithObject:file] == YES || [regexHiddenPath evaluateWithObject:file] == YES)
			continue;
		
		NSString *thisPath = [NSString stringWithFormat:@"%@/%@",path,file];
		BOOL isDirectory=NO;
		[[NSFileManager defaultManager] fileExistsAtPath:thisPath isDirectory:&isDirectory];
		
		//This file is a directory
		if (isDirectory) {
			NSLog(@"searching in: %@",file);
			//Is it hidden? Don't wat to add breakpoints from .svn folders
			
		}
	}
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
