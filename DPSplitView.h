//
//  DPSplitView.h
//  as3Debugger
//
//  Created by Lucas Dupin on 3/4/10.
//  Copyright 2010 Lucas Dupin. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DPSplitView : NSSplitView {
	float lastSize;
}

-(void) toggleCollapse: (id) sender;

@end
