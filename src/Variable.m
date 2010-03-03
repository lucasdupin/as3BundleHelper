//
//  Variable.m
//  as3Debugger
//
//  Created by Lucas Dupin on 9/3/09.
//  Copyright 2009 Gringo. All rights reserved.
//

#import "Variable.h"


@implementation Variable

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
	//NSLog(@"%@ says: I want my children back!", fullName);
	
	if (child == nil) {
		//Let's load the values, ok?
		[delegate variableWantsItsChildren:self];
	}
	
	return child;
}

- (BOOL) leaf
{
	return [value rangeOfString:@"Object"].location == NSNotFound;
}

@synthesize name;
@synthesize fullName;
@synthesize value;
@synthesize child;
@synthesize delegate;

@end
