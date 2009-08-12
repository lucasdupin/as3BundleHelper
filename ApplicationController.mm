//
//  ApplicationController.m
//  as3Debugger
//
//  Created by Lucas Dupin on 8/12/09.
//  Copyright 2009 Gringo. All rights reserved.
//

#import "ApplicationController.h"


@implementation ApplicationController

- (void)awakeFromNib
{
	[NSApp setDelegate:self];
}

- (void)applicationWillTerminate: (NSNotification *)note
{
	[traceController stopTask];
	[debuggingViewController stopTask];
}
@end
