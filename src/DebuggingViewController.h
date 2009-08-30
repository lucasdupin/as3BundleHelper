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

//C
#include <sys/xattr.h>
#include <zlib.h>
#include <vector>

@interface DebuggingViewController : NSWindowController <TaskWrapperController> {
	IBOutlet NSWindow *window;
	IBOutlet WebView *codeView;
	
	//Path of the .as files
	NSString *projectPath;
	//Path of the fdbCommand
	NSString *fdbCommandPath;
	//SDK path
	NSString *flexPath;
	//Task wich we talk to
	TaskWrapper *fdbTask;
	
	//.as files in project path
	NSMutableArray *actionScriptFiles;
	//Breakpoints in projet
	NSMutableArray *breakpoints;
	
	//File we're seeing
	NSString *currentFile;
	
	//Debugger state
	NSString *currentState;
	
	//Are we connected?
	BOOL connected;
}

@property (readonly) BOOL connected;

- (id)init;

- (IBAction) connect: (id)sender;
- (IBAction) step: (id)sender;
- (IBAction) stepOut: (id)sender;
- (IBAction) continueTilNextBreakPoint: (id)sender;
- (IBAction) dettach: (id)sender;

- (void) lookAfterBreakpoints;
- (void) findASFilesInPath: (NSString*)path;
- (NSArray *) getBookmarksForFile: (NSString*)path;

//TaskWrapperController
- (void)appendOutput:(NSString *)output;
- (void)processStarted;
- (void)processFinished;
- (void)stopTask;

//Controlling the menu
- (void)setState: (NSString *)state;

//Controlling the codeView
- (void) showFile: (NSString*)file at: (int)line;

//Default alert
- (void)alert: (NSString *)message;

@end
