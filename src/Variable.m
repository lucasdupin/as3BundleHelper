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
	return child;
}

@synthesize name;
@synthesize value;

@end
