//
//  ApplicationController.h
//  as3Debugger
//
//  Created by Lucas Dupin on 26/07/09.
//  Copyright 2009 28.room. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ApplicationController : NSObject {
	IBOutlet NSWindow *flashLogWindow;
	IBOutlet NSWindow *flashDebugWindow;
}

- (IBAction) showLogWindow: (id)sender;
- (IBAction) showDebugWindow: (id)sender;

@end
