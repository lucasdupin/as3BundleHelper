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
#include "FDBConstants.h"

@interface DebuggingViewController : NSObject <TaskWrapperController> {
	IBOutlet NSWindow *window;
	
	//Toolbar buttons
	IBOutlet NSToolbarItem *connectButton;
	IBOutlet NSToolbarItem *dettachButton;
	IBOutlet NSToolbarItem *continueTilNextBreakPointButton;
	IBOutlet NSToolbarItem *stepButton;
	IBOutlet NSToolbarItem *stepIntoButton;
	IBOutlet NSToolbarItem *stepOutButton;
	
	NSString *projectPath;
	NSString *fdbCommandPath;
	NSString *flexPath;
	TaskWrapper *fdbTask;
	
	NSMutableArray *breakpoints;
	
	
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

@end
