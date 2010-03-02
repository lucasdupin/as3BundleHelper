//
//  FDBCommunicator.m
//  as3Debugger
//
//  Created by Lucas Dupin on 10/6/09.
//  Copyright 2009 Lucas Dupin. All rights reserved.
//

#import "FDBCommunicator.h"

/*
 default message received after a command is parsed by fdb
 */
#define DEFAULT_DELIMITER					@"\\(fdb\\) "
/*
 This is a format for matching the delimiter
*/
#define MESSAGE_ENDING_REGEX				@"(.*|\\n)+.*%@$"

/*
 There is some stuff I don't want know when
 parsing the output (traces for example)
 */
#define IGNORE_REGEX						@"^\\[trace\\].*"


@implementation FDBCommunicator

@synthesize delegate;

-(id) init
{
	commandQueue = [[NSMutableArray alloc] init];
	truncatedOutput = @"";
	
	return self;
}

-(void) start
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

-(void) sendCommand:(NSString *)command withDelimiter: (NSString *) delimiter
{
	NSLog(@"Adding to queue: %@", command);
	//Adding the message to the line
	FDBCommand * cmd = [[FDBCommand alloc] init];
	cmd.command =			command;
	cmd.endingDelimiter =	delimiter;
	
	[commandQueue addObject:cmd];
	
	//Check if we're gonna need to wait
	if([commandQueue count] <= 1) { //No need to wait
		currentCommand = cmd;
		[fdbTask sendData: [NSString stringWithFormat:@"%@\n", cmd.command]];
	} else {
		//Ops, waiting for an answer...
	}
}

-(void) sendCommand:(NSString *)command
{
	[self sendCommand: command withDelimiter: DEFAULT_DELIMITER];
}

- (void)appendOutput:(NSString *)output
{
	//Checking if this line is going to be ignored (trace)
	if ([output isMatchedByRegex:IGNORE_REGEX])
		return;
	
	truncatedOutput = [truncatedOutput stringByAppendingString:output];
	
	//Check if we hit the end of the output
	if(currentCommand.endingDelimiter == nil || [truncatedOutput isMatchedByRegex: [NSString stringWithFormat:MESSAGE_ENDING_REGEX, currentCommand.endingDelimiter]]){
		
		//Remove from queue
		[commandQueue removeObject:currentCommand];
		
		//Send the message to the delegate
		if (delegate!=nil) [delegate gotMessage: truncatedOutput forCommand: currentCommand.command];
		
		//Clearing message
		truncatedOutput = @"";
		
		//Any other command in the list?
		if([commandQueue count] > 0){

			currentCommand = [commandQueue objectAtIndex:0];
			[fdbTask sendData: [NSString stringWithFormat:@"%@\n", currentCommand.command]];
		}
		
	} else {
		NSLog(@"[COMMUNICATOR] truncated output received: %@\n", output);
	}

		
	
	
	
	
}
- (void)processStarted{};
- (void)processFinished{};


-(void) stop
{
	[fdbTask stopProcess];
	[fdbTask release];
	fdbTask = nil;
}

-(void) dealloc
{
	[commandQueue release];
	[super dealloc];
}

@end
