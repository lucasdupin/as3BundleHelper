//
//  FDBCommand.h
//  as3Debugger
//
//  Created by Lucas Dupin on 10/16/09.
//  Copyright 2009 Gringo. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FDBCommand : NSObject {
	NSString *				command;
	NSString *				endingDelimiter;
}

@property (copy) NSString * command;
@property (copy) NSString * endingDelimiter;

@end
