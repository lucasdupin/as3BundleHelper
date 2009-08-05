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
	IBOutlet NSWindow *debugWindow;
	
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

- (void) setBreakpointsForPath: (NSString *)path;
- (NSPropertyListSerialization *) getBookmarksForFile: (NSString*)path;

//TaskWrapperController
- (void)appendOutput:(NSString *)output;
- (void)processStarted;
- (void)processFinished;

@end
