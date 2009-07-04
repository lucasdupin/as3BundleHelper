//
//  AlphaPanel.m
//  as3Debugger
//
//  Created by Lucas Dupin on 04/07/09.
//  Copyright 2009 28.room. All rights reserved.
//

#import "AlphaPanel.h"


@implementation AlphaPanel

- (id) init
{
	NSLog(@"INITTTTTT");
	self = [super init];
	if (self != nil) {
		NSLog(@"init");
	}
	return self;
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	NSLog(@"Mouse Entered");
}
- (void)mouseExited:(NSEvent *)theEvent
{
	NSLog(@"Mouse Entered");
}

@end
