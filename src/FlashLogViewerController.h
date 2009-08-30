//
//  TraceController.h
//  as3Debugger
//
//  Created by Lucas Dupin on 01/06/09.
//  Copyright 2009 28.room. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlphaPanel.h"
#import "TaskWrapper.h"

@interface FlashLogViewerController : NSWindowController <TaskWrapperController> {
	IBOutlet NSTextView *field;
	IBOutlet NSButton *autoAlphaButton;
	IBOutlet AlphaPanel * alphaPanel;
	IBOutlet NSPanel * window;
	
	TaskWrapper *tailTask;
}

@property (readonly) NSTextView * field;

- (IBAction) clear: (id)sender;
- (IBAction) separate: (id)sender;
- (IBAction) setAutoAlpha: (id)sender;


- (void)processStarted;
- (void)processFinished;
- (void)appendOutput:(NSString *)output;

- (void) startTask;
- (void)stopTask;

- (NSPanel*)getWindow;

@end