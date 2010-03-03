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
#define NUMBER_REGEX				@"^(?<num>-*\\d+)\\s\\(0x.+\\)$"
#define OBJECT_REGEX				@"^\\[Object\\s\\d+,\\sclass='(?<name>.*)'\\]$"

@implementation DebuggerValueCell

@synthesize childCell;

- copyWithZone:(NSZone *)zone {
	DebuggerValueCell *cell = [super copyWithZone:zone];
	cell->childCell = [childCell copyWithZone:zone];
	return cell;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	
	//Draw
	[childCell drawWithFrame:cellFrame inView:controlView];
	
}

- (void) setObjectValue:(id)object
{
	NSString * value = object;
	
	[childCell release];

	//Wich type of control?
	if ([value isMatchedByRegex:BOOLEAN_TRUE_REGEX] ||
		[value isMatchedByRegex:BOOLEAN_FALSE_REGEX]) {
		
		/*
		 Boolean
		 */
		NSButtonCell *c = [[NSButtonCell alloc] init];
		[c setTitle:nil];
		[c setButtonType:NSSwitchButton];
		[c setState:[value isMatchedByRegex:BOOLEAN_TRUE_REGEX]];
		
		childCell = c;
		
	} else if ([value isMatchedByRegex:NUMBER_REGEX]) {
		/*
		 Numeric
		 */
		
		NSString * numS;
		[value getCapturesWithRegexAndReferences: NUMBER_REGEX, @"${num}", &numS, nil];
		
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[numberFormatter setNumberStyle: NSNumberFormatterNoStyle];
		
		/*
		 Text
		 */
		NSTextFieldCell *c = [[NSTextFieldCell alloc] init];
		[c setStringValue: numS];
		[c setEditable:YES];
		[c setFormatter: numberFormatter];
		childCell = c;
		
		[numberFormatter release];
		
	} else if ([value isMatchedByRegex:OBJECT_REGEX]) {
		
		NSString * objS;
		[value getCapturesWithRegexAndReferences: OBJECT_REGEX, @"${name}", &objS, nil];
		
		NSTextFieldCell *c = [[NSTextFieldCell alloc] init];
		[c setStringValue: objS];
		[c setEditable:YES];
		childCell = c;
		
	} else {
		/*
		 Text
		 */
		childCell = [[NSTextFieldCell alloc] init];
		[childCell setEditable:YES];
		[childCell setObjectValue:value];
	}
	
	[super setObjectValue:object];
}

/*
- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView {
    return [childCell hitTestForEvent:event inRect:cellFrame ofView:controlView];    
}
-(BOOL)trackMouse:(NSEvent*)theEvent inRect:(NSRect)cellFrame ofView:(NSView*)controlView untilMouseUp:(BOOL)untilMouseUp {
	return [childCell trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:untilMouseUp];
}
*/

- (void)dealloc
{
	[childCell release];
	[super dealloc];
}
@end
