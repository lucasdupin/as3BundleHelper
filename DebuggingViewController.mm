//
//  DebuggingViewController.m
//  as3Debugger
//
//  Created by Lucas Dupin on 26/07/09.
//  Copyright 2009 28.room. All rights reserved.
//

#import "DebuggingViewController.h"

//FDB Responses
NSString * const FDB_INSERT_BREAKPOINTS =  @"Set breakpoints and then type 'continue' to resume the session.";
NSString * const FDB_REACH_BREAKPOINT =  @"Set breakpoints and then type 'continue' to resume the session.";
NSString * const FDB_ALREADY_RUNNING =  @"Another Flash debugger is probably running";


@implementation DebuggingViewController

- (void)awakeFromNib
{
	//Did we receive a project path?
	projectPath = [[NSUserDefaults standardUserDefaults] stringForKey: @"flashlog"];
	projectPath = @"/Users/lucas/src/coca-cola/oohsms/FlashClient/trunk/source/classes";
	projectPath = @"/Users/lucasdupin/Desktop/oohsms/FlashClient/trunk/source/classes";
	
	if(projectPath == NULL || [projectPath length] <= 0) {
		NSLog(@"No project, disabling window");
		
		
		NSArray * items = [[window toolbar] items];
		NSEnumerator *it = [items objectEnumerator];
		id element;
		while ((element = [it nextObject])) {
			[((NSToolbarItem *) element) setEnabled:NO];
		}

		return;
	}
	
	flexPath = [[NSUserDefaults standardUserDefaults] stringForKey: @"flex"];
	if(flexPath == nil)
		flexPath = @"/Users/lucas/src/libs/flex_sdk_4/";

	fdbCommandPath = [[NSString alloc] initWithString:[[flexPath stringByAppendingString: @"bin/fdb"] autorelease]];
	[fdbCommandPath retain];
	
	//NSLog(@"FDB command is: %@", fdbCommandPath);
	
	//Enabling ONLY connect button
	[connectButton setEnabled:YES];
	[dettachButton setEnabled:NO];
	[stepButton setEnabled:NO];
	[stepOutButton setEnabled:NO];
	[continueTilNextBreakPointButton setEnabled:NO];
	
}

//Starts FDB, find breakpoints in project
- (IBAction) connect: (id)sender
{
	if(fdbTask != NULL)
		[fdbTask stopProcess];
	
	//Reading breakpoints
	[self parseBreakpointsForPath: projectPath];
	
	NSLog(@"FDB Command: %@", fdbCommandPath);
	NSArray * command = [NSArray arrayWithObjects: fdbCommandPath, nil];
	fdbTask = [[TaskWrapper alloc] initWithController:self arguments:command];
	[fdbTask setLaunchPath: flexPath];
	[fdbTask startProcess];
	
	[fdbTask sendData:@"run\n"];
	
	
}

//Loops through the path and search for .as files in folders wich are not hidden
//get the metadata of the files looking for a plist of breakpoints
//(Textmate bookmarks)
- (void) parseBreakpointsForPath: (NSString *)path
{
	if(breakpoints != nil) [breakpoints release];
	breakpoints = [[NSMutableArray alloc] init];
	
	//Regexes
	NSPredicate *regexHidden = [NSPredicate predicateWithFormat: @"SELF MATCHES %@",@"^[\\.].*"]; //Begins with .
	NSPredicate *regexHiddenPath = [NSPredicate predicateWithFormat: @"SELF MATCHES %@",@".*/[\\.].*"]; //Contains a hidden path
	NSPredicate *regexASFile = [NSPredicate predicateWithFormat: @"SELF MATCHES %@",@".*\\.as$"]; //.as file
	
	NSFileHandle * file;
	NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
	while (file = [enumerator nextObject])
	{
		//No hidden files, please
		
		if([regexHidden evaluateWithObject:file] == YES || [regexHiddenPath evaluateWithObject:file] == YES)
			continue;
		
		NSString *thisPath = [[NSString alloc] initWithFormat:@"%@/%@",path,file];
		BOOL isDirectory=NO;
		[[NSFileManager defaultManager] fileExistsAtPath:thisPath isDirectory:&isDirectory];
		
		//This is a file
		if (!isDirectory) {
			//Is it an .as file?
			if([regexASFile evaluateWithObject:file]) {
				//NSLog(thisPath);
				NSArray * res = [self getBookmarksForFile: thisPath];
				
				//Adding breakpoints to the list
				for(int i=0; i < [res count]; i++){
					[breakpoints addObject:[[NSString alloc] initWithFormat:@"%@:%@", file, [res objectAtIndex:i]]];
					NSLog(@"Set breakpoint: %@", [breakpoints objectAtIndex:[breakpoints count]-1]);
				}
			}
		}
		[thisPath release];
	}
}

//Gets the bookmark list for the file given
- (NSArray*) getBookmarksForFile: (NSString*)path
{
	const char * key = "com.macromates.bookmarked_lines";
	ssize_t len = getxattr([path UTF8String], key, NULL, 0, 0, 0);
	if(len <= 0)
		return nil;
	
	NSLog(@"%@ has bookmarks", path);
	
	std::vector<char> v(len);
	if(getxattr([path UTF8String], key, &v[0], v.size(), 0, 0) != -1)
	{
		uLongf destLen = 5 * v.size();
		std::vector<char> dest;
		int zlib_res = Z_BUF_ERROR;
		while(zlib_res == Z_BUF_ERROR && destLen < 1024*1024)
		{
			destLen <<= 2;
			dest = std::vector<char>(destLen);
			zlib_res = uncompress((Bytef*)&dest[0], &destLen, (Bytef*)&v[0], v.size());
		}
		
		if(zlib_res == Z_OK)
		{
			dest.resize(destLen);
			dest.swap(v);
		}
	}
	NSArray* res = [NSPropertyListSerialization propertyListFromData: 
		   [NSData dataWithBytes:&v[0] length:v.size()]  
										   mutabilityOption:NSPropertyListImmutable format:nil  
										   errorDescription:NULL];
	
	return res;
}

- (IBAction) step: (id)sender
{
	
}
- (IBAction) stepOut: (id)sender
{
	
}
- (IBAction) continueTilNextBreakPoint: (id)sender
{
	
}
- (IBAction) dettach: (id)sender
{
	[breakpoints release];
}

- (void)appendOutput:(NSString *)output
{
	NSLog([@"FDB says: " stringByAppendingString:output]);
	
	
	/*******
	 What did fdb mean?
	 *******/
	
	//Asking to set breakpoints?	
	if([output rangeOfString:FDB_INSERT_BREAKPOINTS].location != NSNotFound)
	{
		//Time to set Breakpoints
		NSLog(@"Setting breakpoints");
		//Adding breakpoints to the list
		for(int i=0; i < [breakpoints count]; i++){
			NSLog(@"%@", [breakpoints objectAtIndex:i]);
			//[fdbTask sendData:[breakpoints objectAtIndex:i]];
		}
		//Telling fdb we're done
		[fdbTask sendData:@"continue"];
		
	} else  if([output rangeOfString:FDB_ALREADY_RUNNING].location != NSNotFound){
		NSLog(@"FDB Already running");
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"fdb already running, please, close it."];
		[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
		
		
	} else {
		NSLog(@"Don't know what you are saying");
	}
}
- (void)processStarted{};
- (void)processFinished{};

- (NSWindow *)getWindow
{
	return window;
}

//Stops task. Useful for quitting the program and not leaving
//Something open
- (void)stopTask {
	[projectPath release];
	[fdbCommandPath release];
	[flexPath release];
	[fdbTask release];
	
	[breakpoints release];
}

@end
