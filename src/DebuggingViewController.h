//
//  DebuggingViewController.h
//  as3Debugger
//
//  Created by Lucas Dupin on 26/07/09.
//  Copyright 2009 28.room. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TaskWrapper.h"
#import <RegexKit/RegexKit.h>
#import <WebKit/WebKit.h>
#import "FDBCommunicator.h"

//C
#include <sys/xattr.h>
#include <zlib.h>
#include <vector>

@interface DebuggingViewController : NSWindowController <FDBCommunicatorClient> {
	IBOutlet NSWindow *window;
	IBOutlet WebView *codeView;
	
	//File we're seeing
	NSString *currentFile;
	
	//Debugger state
	NSString *currentState;
	
	//Are we connected?
	BOOL connected;
	
	//The FDB we're talking to
	FDBCommunicator * fdbCommunicator;
	
	NSArray * breakpoints;
}

@property (readonly) BOOL connected;

- (id)init;

//Starts FDB, find breakpoints in project path
- (IBAction) connect: (id)sender;
- (IBAction) step: (id)sender;
- (IBAction) stepOut: (id)sender;
- (IBAction) continueTilNextBreakPoint: (id)sender;
- (IBAction) dettach: (id)sender;

//Searches for breakpoints in all project files and populates the
//breakpoints Array
- (NSArray *) lookAfterBreakpointsInFiles: (NSArray *) actionScriptFiles;

//Loops through the path and search for .as files in folders wich are not hidden
//get the metadata of the files looking for a plist of breakpoints (Textmate bookmarks)
- (NSArray *) findASFiles;

//Gets the bookmark list for the file given
- (NSArray *) getBookmarksForFile: (NSString*)path;


//Stops task. Useful when quitting the program and not
//leaving something open
- (void)stopTask;

//Sets the current state of the application
//This method is very important, because here we
//Control all the behaviour of the application,
//wheter it's waiting for connections or in the middle
//of a breakpoint
- (void)setState: (NSString *)state;

//Show file with highlighted number in the codeView
- (void) showFile: (NSString*)file at: (int)line;

//Default alert
- (void)alert: (NSString *)message;

@end
