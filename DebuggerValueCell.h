//
//  DebuggerValueCell.h
//  as3Debugger
//
//  Created by Lucas Dupin on 3/2/10.
//  Copyright 2010 Lucas Dupin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Variable.h"
#import <RegexKit/RegexKit.h>


@interface DebuggerValueCell : NSCell {
	NSCell *childCell;
}

- (void)setObjectValue:(id)object;
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- copyWithZone:(NSZone *)zone;

@property (nonatomic, copy) NSCell *childCell;

@end
