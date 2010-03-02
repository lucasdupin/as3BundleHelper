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

- copyWithZone:(NSZone *)zone {
	NSLog(@"copy");
	
	DebuggerValueCell *cell = (DebuggerValueCell *)[super copyWithZone:zone];
	cell->childCell = nil;
	
    return cell;
}

- (void)setObjectValue:(id)object
{
	[super setObjectValue:object];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSLog(@"draw vaaaaalue %@", [self objectValue]);
	
	NSString * value = [self objectValue];
	
	//Check if we're need to create the control
	if (childCell == nil) {
		
		//Wich type of control?
		if ([value isMatchedByRegex:BOOLEAN_TRUE_REGEX] ||
			 [value isMatchedByRegex:BOOLEAN_FALSE_REGEX]) {
			
			NSButtonCell *b = [[[NSButtonCell alloc] init] autorelease];
			[b setTitle:nil];
			[b setButtonType:NSSwitchButton];
			[b setState:[value isMatchedByRegex:BOOLEAN_TRUE_REGEX]];
			
			childCell = b;
			
		} else if ([value isMatchedByRegex:NUMBER_REGEX]) {
			
			//NSStp 
			
			NSString * numS;
			[value getCapturesWithRegexAndReferences: NUMBER_REGEX, @"${num}", &numS, nil];
		} else {
			childCell = [[[NSTextFieldCell alloc] init] autorelease];
			[childCell setEditable:YES];
			[childCell setObjectValue:[self objectValue]];
		}
	}
	[childCell drawWithFrame:cellFrame inView:controlView];
}

- (void)dealloc
{
	[childCell release];
	[super dealloc];
}
@end
