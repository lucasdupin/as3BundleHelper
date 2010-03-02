//
//  Variable.h
//  as3Debugger
//
//  Created by Lucas Dupin on 9/3/09.
//  Copyright 2009 Gringo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Variable : NSObject {
	
	//For output
	NSString * name;
	id value;
	
	//The real path in the FDB
	NSString * fullName;
	
	//Delegate to update children
	id delegate;
	
	NSMutableArray * child;

}

- (id) init;
- (BOOL) leaf;

@property (assign) id delegate;
@property (assign) NSMutableArray * child;
@property (copy) NSString * name;
@property (copy) NSString * fullName;
@property (copy) id value;

@end
