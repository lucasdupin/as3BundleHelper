//
//  DebuggerValueCell.m
//  as3Debugger
//
//  Created by Lucas Dupin on 3/2/10.
//  Copyright 2010 Lucas Dupin. All rights reserved.
//

#import "DebuggerValueCell.h"

#define BOOLEAN_TRUE_REGEX			@"^true$"
#define BOOLEAN_FALSE_REGEX			@"^false$"
#define NUMBER_REGEX				@"^(?<num>\\d+)\\s\\(0x.*\\)$"

@implementation DebuggerValueCell

@synthesize childCell;

-(id) copyWithZone:(NSZone *)zone {
	DebuggerValueCell *cell = (DebuggerValueCell *)[super copyWithZone:zone];
	cell->childCell = nil;
	[cell setChildCell: childCell];
    return cell;
}

- (void)setObjectValue:(id)object
{
	[super setObjectValue:object];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	
	NSString * value = [self objectValue];
	
	[childCell release];
	
	//Wich type of control?
	if ([value isMatchedByRegex:BOOLEAN_TRUE_REGEX] ||
		 [value isMatchedByRegex:BOOLEAN_FALSE_REGEX]) {
		
		/*
		 Boolean
		 */
		NSButtonCell *b = [[NSButtonCell alloc] init];
		[b setTitle:nil];
		[b setButtonType:NSSwitchButton];
		[b setState:[value isMatchedByRegex:BOOLEAN_TRUE_REGEX]];
		
		childCell = b;
		
	} else if ([value isMatchedByRegex:NUMBER_REGEX]) {
		/*
		 Numeric
		 */
		
		NSString * numS;
		[value getCapturesWithRegexAndReferences: NUMBER_REGEX, @"${num}", &numS, nil];
	} else {
		/*
		 Text
		 */
		childCell = [[NSTextFieldCell alloc] init];
		[childCell setEditable:YES];
		[childCell setObjectValue:[self objectValue]];
	}
	
	//Draw
	[childCell drawWithFrame:cellFrame inView:controlView];
	//Release
	[childCell release];
	
}

- (void)dealloc
{
	[super dealloc];
}
@end
