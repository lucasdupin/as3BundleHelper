//
//  DebuggingViewController.m
//  as3Debugger
//
//  Created by Lucas Dupin on 26/07/09.
//  Copyright 2009 28.room. All rights reserved.
//

#import "DebuggingViewController.h"


@implementation DebuggingViewController

- (void)awakeFromNib
{
	//Did we receive a project path?
	char * flashlog;
	NSString * logParam = [[NSUserDefaults standardUserDefaults] stringForKey: @"flashlog"];
	if(logParam == NULL) {
		flashlog = strcat(getenv("HOME"), "/Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt");
	} else {
		flashlog = [logParam UTF8String];
	}
	printf("Flashlog is : %s", flashlog);
}

@end
