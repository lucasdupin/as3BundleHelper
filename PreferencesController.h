//
//  PreferencesController.h
//  as3Debugger
//
//  Created by Lucas Dupin on 8/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PreferencesController : NSWindowController {
	IBOutlet NSTabView * tabView;
	IBOutlet NSWindow * window;
}

- (id)init;
- (NSWindow *)getWindow;

- (IBAction) selectGeneralTab: (id)sender;
- (IBAction) selectLogTab: (id)sender;
- (IBAction) selectDebuggerTab: (id)sender;

@end
