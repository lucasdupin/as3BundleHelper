//
//  FDBCommunicator.h
//  as3Debugger
//
//  Created by Lucas Dupin on 10/6/09.
//  Copyright 2009 Lucas Dupin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TaskWrapper.h"

//Protocol for receiving messages
@protocol FDBCommunicatorClient

- (void) gotMessage: (NSString *) message forCommand: (NSString *) command;

@end


@interface FDBCommunicator : NSObject <TaskWrapperController> {

	TaskWrapper *		fdbTask;				//Task wich we talk to
	NSMutableArray *	commandQueue;			//Commands waiting in line
	
	FDBCommunicator *	delegate;				//Delegate
	NSArray *			breakpoints;			//Breakpoints of the project
}

- (void) start;									//Starts the process
- (void) stop;									//Kills the process
- (void) sendCommand: (NSString *) command;		//Sends a command to fdb

/****
 TaskWrapperController
 ****/
- (void)appendOutput:(NSString *)output;		//Receives the output of the fdb
- (void)processStarted;							//Called when the process has started
- (void)processFinished;						//Called when the process finished

@property (assign) FDBCommunicator * delegate;
@property (copy) NSArray * breakpoints;

@end
