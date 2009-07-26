//
//  DebuggingViewController.h
//  as3Debugger
//
//  Created by Lucas Dupin on 26/07/09.
//  Copyright 2009 28.room. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "TaskWrapper.h"


@interface DebuggingViewController : NSObject {
	IBOutlet NSWindow *debugWindow;
	
	NSString * projectPath;
}

- (IBAction) connect: (id)sender;

- (IBAction) step: (id)sender;
- (IBAction) stepOut: (id)sender;
- (IBAction) continueTilNextBreakPoint: (id)sender;
- (IBAction) dettach: (id)sender;

@end
