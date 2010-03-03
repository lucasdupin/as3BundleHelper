//
//  Variable.m
//  as3Debugger
//
//  Created by Lucas Dupin on 9/3/09.
//  Copyright 2009 Gringo. All rights reserved.
//

#import "Variable.h"


@implementation Variable

@synthesize name;
@synthesize fullName;
@synthesize value;
@synthesize child;
@synthesize delegate;

#define VARIABLE_TYPE_BOOLEAN				@"^\\s(?<name>.+)\\s=\\s(?<value>.+)$"

-(id) init
{
	return self;
}

- (id) initWithName: (NSString*) n andValue: (NSString*) v
{
	self.name = n;
	self.value = v;
	
	return self;
}

- (NSString *) printCommand
// Command wich once sent
// will return the vriable contents
{
	return [NSString stringWithFormat:@"print %@.", fullName];
}

-(void) setChild:(NSMutableArray *) newChild
{
	if (newChild != child) {
		[child release];
		
		child = newChild;
		[child retain];
		
		[delegate askedToReload: self];
	}
}
-(NSMutableArray *) child
{
	if (child == nil) {
		//Let's load the values, ok?
		[delegate variableWantsItsChildren:self];
	}
	
	return child;
}

- (BOOL) leaf
{
	return [value rangeOfString:@"[Object"].location == NSNotFound;
}

@end
