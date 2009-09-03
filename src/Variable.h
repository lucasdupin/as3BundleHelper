//
//  Variable.h
//  as3Debugger
//
//  Created by Lucas Dupin on 9/3/09.
//  Copyright 2009 Gringo. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Variable : NSObject {
	NSString * name;
	id value;
	
	NSMutableArray * child;
}

@property (assign) NSMutableArray * child;

@property (readonly) NSString * name;
@property (assign) id value;

@end
