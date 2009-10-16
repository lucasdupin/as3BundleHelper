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
}

- (id)init;

- (IBAction) selectGeneralTab: (id)sender;
- (IBAction) selectLogTab: (id)sender;
- (IBAction) selectDebuggerTab: (id)sender;

@end
