//
//  FDBCommunicator.m
//  as3Debugger
//
//  Created by Lucas Dupin on 10/6/09.
//  Copyright 2009 Lucas Dupin. All rights reserved.
//

#import "FDBCommunicator.h"


@implementation FDBCommunicator

@synthesize delegate;
@synthesize breakpoints;

- (void) start
{
	//Stops the fdb if it's already running
	if(fdbTask != nil){
		[fdbTask stopProcess];
		[fdbTask release];
	}
	
	//Commands and paths
	NSString * flexPath =			[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey: @"flexSDKPath"];
	NSString * fdbCommandPath =		[flexPath stringByAppendingPathComponent: @"bin/fdb"];
	
	//Launch the fdb process
	NSLog(@"FDB Command: %@", fdbCommandPath);
	NSArray * command = [NSArray arrayWithObjects: fdbCommandPath, nil];
	fdbTask = [[TaskWrapper alloc] initWithController:self arguments:command];
	[fdbTask setLaunchPath: flexPath];
	[fdbTask startProcess];
}
-(void) stop
{
	
}


@end
