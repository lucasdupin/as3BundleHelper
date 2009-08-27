//
//  ApplicationController.h
//  as3Debugger
//
//  Created by Lucas Dupin on 8/12/09.
//  Copyright 2009 Gringo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TraceController.h"
#import "DebuggingViewController.h"


@interface ApplicationController : NSObject {
	IBOutlet TraceController *traceController;
	IBOutlet DebuggingViewController *debuggingViewController;
	
	IBOutlet NSWindow *debugWindow;
}

- (IBAction) showLogViewer: (id) sender;
- (IBAction) showDebuggingView: (id) sender;

- (void) connectDebugger:(NSScriptCommand*)command;
- (NSString *)string;

@end

