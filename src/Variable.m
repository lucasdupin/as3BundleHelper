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

-(void) setChild:(NSMutableArray *) newChild
{
	child = newChild;
}
-(NSMutableArray *) child
{
	NSLog(@"child of %@", fullName);
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

@end
