//
//  ApplicationController.h
//  as3Debugger
//
//  Created by Lucas Dupin on 8/12/09.
//  Copyright 2009 Gringo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FlashLogViewerController.h"
#import "DebuggingViewController.h"
#import "PreferencesController.h"

@interface ApplicationController : NSObject {
	IBOutlet FlashLogViewerController *flashLogViewerController;
	IBOutlet DebuggingViewController *debuggingViewController;
	IBOutlet PreferencesController *preferencesController;
}

- (IBAction) showPreferences: (id) sender;
- (IBAction) showLogViewer: (id) sender;
- (IBAction) showDebuggingView: (id) sender;

- (NSString *)string;

@end

