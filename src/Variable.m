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
	name = @"Minha var";
	value = @"77";
	
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

-(void) setName:(NSString *) newName
{
	name = newName;
}
-(NSString *) name
{
	NSLog(@"Reading name %@", name);
	return name;
}

@synthesize value;

@end
