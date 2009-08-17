//
//  DebuggingViewController.h
//  as3Debugger
//
//  Created by Lucas Dupin on 26/07/09.
//  Copyright 2009 28.room. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TaskWrapper.h"

//C
#include <sys/xattr.h>
#include <zlib.h>
#include <vector>

@interface DebuggingViewController : NSObject <TaskWrapperController> {
	IBOutlet NSWindow *window;
	
	NSString *projectPath;
	NSString *fdbCommandPath;
	NSString *flexPath;
	TaskWrapper *fdbTask;
	
	NSMutableArray *breakpoints;
	
	//Debugger state
	NSString *currentState;
}

- (IBAction) connect: (id)sender;
- (IBAction) step: (id)sender;
- (IBAction) stepOut: (id)sender;
- (IBAction) continueTilNextBreakPoint: (id)sender;
- (IBAction) dettach: (id)sender;

- (void) parseBreakpointsForPath: (NSString *)path;
- (NSArray *) getBookmarksForFile: (NSString*)path;

- (NSWindow *)getWindow;

//TaskWrapperController
- (void)appendOutput:(NSString *)output;
- (void)processStarted;
- (void)processFinished;
- (void)stopTask;

//Controlling the menu
- (void)setState: (NSString *)state;

//Default alert
- (void)alert: (NSString *)message;

@end
