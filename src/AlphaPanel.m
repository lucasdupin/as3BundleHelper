//
//  AlphaPanel.m
//  as3Debugger
//
//  Created by Lucas Dupin on 04/07/09.
//  Copyright 2009 28.room. All rights reserved.
//

#import "AlphaPanel.h"


@implementation AlphaPanel


- (void)viewDidMoveToWindow {
	
//	//Prepare for animations
//	CAAnimation *anim = [CABasicAnimation animation];
//    [anim setDelegate:self];
//	[self.window setAnimations:[NSDictionary dictionaryWithObject:anim forKey:@"alphaValue"]];
	
}

- (void)setFrame:(NSRect)frame {
	NSLog(@"Frame set");
    [super setFrame:frame];
    [self removeTrackingRect:rectTag];
	rectTag = [self addTrackingRect:[self visibleRect] owner:self userData:NULL assumeInside:NO];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	NSLog(@"Mouse Entered");
	[[[self window] animator] setAlphaValue:1];
}
- (void)mouseExited:(NSEvent *)theEvent
{
	NSLog(@"Mouse Exit");
	if(autoAlpha)
		[[[self window] animator] setAlphaValue:0.3];
}

- (void) setAutoAlpha: (BOOL)value{
	autoAlpha = value;
}

@end
