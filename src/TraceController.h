//
//  TraceController.h
//  as3Debugger
//
//  Created by Lucas Dupin on 01/06/09.
//  Copyright 2009 28.room. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TaskWrapper.h"

@interface TraceController : NSObject <TaskWrapperController> {
	IBOutlet NSTextView *field;
	IBOutlet NSView *mainWindow;
	
	TaskWrapper *tailTask;
}

- (IBAction) clear: (id)sender;
- (IBAction) separate: (id)sender;

- (void)processStarted;
- (void)processFinished;
- (void)appendOutput:(NSString *)output;

@end