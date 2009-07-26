//
//  PreferencesController.h
//  as3Debugger
//
//  Created by Lucas Dupin on 26/07/09.
//  Copyright 2009 28.room. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PreferencesController : NSObject {
	IBOutlet NSTabView *views;
}

- (IBAction) setGeneralView: (id)sender;
- (IBAction) setLogView: (id)sender;
- (IBAction) setDebuggerView: (id)sender;

@end
