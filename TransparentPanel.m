//
//  TransparentPanel.m
//  as3Debugger
//
//  Created by Lucas Dupin on 7/3/09.
//  Copyright 2009 Gringo. All rights reserved.
//

#import "TransparentPanel.h"


@implementation TransparentPanel

- (void)mouseEntered:(NSEvent *)theEvent {
	NSLog(@"mouseEntered");
	self.alphaValue = 1.0;
}

- (void)mouseExited:(NSEvent *)theEvent {
	NSLog(@"mouseExited");
	self.alphaValue = .3;
}

@end
