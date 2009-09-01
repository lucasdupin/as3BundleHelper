//
//  LogView.m
//  as3Debugger
//
//  Created by Lucas Dupin on 9/1/09.
//  Copyright 2009 Gringo. All rights reserved.
//

#import "LogView.h"


@implementation LogView

- (void)changeFont:(id)sender
{
	//Changing the font for the whole field
	NSFont *oldFont = [self font];
    NSFont *newFont = [sender convertFont:oldFont];
    [self setFont:newFont];
	
	//Memorizing the font for next launch
	[[NSUserDefaults standardUserDefaults] setObject:[newFont fontName] forKey:@"flashlogFontName"];
	[[NSUserDefaults standardUserDefaults] setFloat:[newFont pointSize] forKey:@"flashlogFontSize"];
}


@end
