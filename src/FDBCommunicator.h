//
//  FDBCommunicator.h
//  as3Debugger
//
//  Created by Lucas Dupin on 10/6/09.
//  Copyright 2009 Lucas Dupin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RegexKit/RegexKit.h>
#import "TaskWrapper.h"
#import "FDBCommand.h"

//Protocol for receiving messages
@protocol FDBCommunicatorClient

- (void) gotMessage: (NSString *) message forCommand: (NSString *) command;

@end


@interface FDBCommunicator : NSObject <TaskWrapperController> {

	TaskWrapper *			fdbTask;					//Task wich we talk to
	NSMutableArray *		commandQueue;				//Commands waiting in line
	id	<FDBCommunicatorClient>delegate;				//Delegate
	
	NSString *				truncatedOutput;			//Output so far received from fdb
	FDBCommand *			currentCommand;				//Command we're waiting to get the response
}

- (void) start;											//Starts the process
- (void) stop;											//Kills the process
- (void) sendCommand: (NSString *) command;				//Sends a command to fdb
- (void) sendCommand:(NSString *)command 
	   withDelimiter: (NSString *) delimiter;			//Same, but not using the default delimiter, useful for commands like run, wich doesn't end with an "(fdb) "

/****
 TaskWrapperController
 ****/
- (void)appendOutput:(NSString *)output;				//Receives the output of the fdb
- (void)processStarted;									//Called when the process has started
- (void)processFinished;								//Called when the process finished

@property (assign) id <FDBCommunicatorClient>delegate;

@end
