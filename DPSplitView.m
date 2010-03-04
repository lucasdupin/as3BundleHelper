//
//  DPSplitView.m
//  as3Debugger
//
//  Created by Lucas Dupin on 3/4/10.
//  Copyright 2010 Lucas Dupin. All rights reserved.
//

#import "DPSplitView.h"


@implementation DPSplitView
-(void) toggleCollapse: (id) sender
{
	NSView *dest = [[self subviews] objectAtIndex:1];
	if ([dest frame].size.height < 20) {
		
		[self
         setPosition: lastSize
         ofDividerAtIndex:0
         ];
		
	}else {
		
		lastSize = [self frame].size.height - [dest frame].size.height;
		if (lastSize < 50) {
			lastSize = 50;
		}
		
		[self
         setPosition:[self maxPossiblePositionOfDividerAtIndex:0]
         ofDividerAtIndex:0
         ];
		
	}
}
@end
