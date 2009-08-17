//
//  DebuggingViewController.m
//  as3Debugger
//
//  Created by Lucas Dupin on 26/07/09.
//  Copyright 2009 28.room. All rights reserved.
//

#import "DebuggingViewController.h"

/*
 FDB Responses
 */
//Connecting
NSString * const FDB_WAITING_CONNECT =  @"Waiting for Player to connect";
NSString * const FDB_CONNECTION_FAILED = @"Failed to connect; session timed out.";
NSString * const FDB_INSERT_BREAKPOINTS =  @"Set breakpoints and then type 'continue' to resume the session.";
NSString * const FDB_ALREADY_RUNNING =  @"Another Flash debugger is probably running";
//Breakpointing
NSString * const FDB_REACH_BREAKPOINT =  @"Set breakpoints and then type 'continue' to resume the session.";

//Debugger states
NSString * const ST_NO_PROJECT_PATH = @"no_project_path";
NSString * const ST_DISCONNECTED = @"disconnected";
NSString * const ST_WAITING_FOR_PLAYER = @"waiting_for_player_to_connect";
NSString * const ST_REACH_BREAKPOINT = @"reach_breakpoint";


@implementation DebuggingViewController

/*
 Initialization:
 Gets the Default project Path and if there is no path, disable the window
 Gets the Flex SDK path
 Sets the delegate for validating menuItems (enabled or not)
 Set current state: ST_DISCONNECTED
 */
- (void)awakeFromNib
{
	//Did we receive a project path?
	projectPath = [[NSUserDefaults standardUserDefaults] stringForKey: @"flashlog"];
	if(projectPath == nil)
		projectPath = @"/Users/lucas/src/coca-cola/oohsms/FlashClient/trunk/source/classes";
	//projectPath = @"/Users/lucasdupin/Desktop/oohsms/FlashClient/trunk/source/classes";
	
	if([projectPath length] <= 0) {
		NSLog(@"No project, disabling window");
		[self setState:ST_NO_PROJECT_PATH];
	}
	
	
	flexPath = [[NSUserDefaults standardUserDefaults] stringForKey: @"flex"];
	if(flexPath == nil)
		flexPath = @"/Users/lucas/src/libs/flex_sdk_4/";

	fdbCommandPath = [[NSString alloc] initWithString:[[flexPath stringByAppendingString: @"bin/fdb"] autorelease]];
	[fdbCommandPath retain]; 
	
	[self setState:ST_DISCONNECTED];
	[[window toolbar] setDelegate:self];
	
}

//Starts FDB, find breakpoints in project path
- (IBAction) connect: (id)sender
{
	if(fdbTask != nil)
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
				NSLog(thisPath);
				NSArray * res = [self getBookmarksForFile: thisPath];
				
				//Adding breakpoints to the list
				for(int i=0; i < [res count]; i++){
					[breakpoints addObject:[[NSString alloc] initWithFormat:@"%@:%@", file, [res objectAtIndex:i]]];
					NSLog(@"Breakpoints in project: %@", [breakpoints objectAtIndex:[breakpoints count]-1]);
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
	[fdbTask stopProcess];
	[self setState: ST_DISCONNECTED];
}

//Application state
- (void) setState:(NSString *)state
{
	currentState = state;
	[[window toolbar] validateVisibleItems];
}

- (void)appendOutput:(NSString *)output
{
	NSLog([@"FDB says: " stringByAppendingString:output]);
	
	
	/*******
	 What did fdb mean?
	 *******/
	
	//After 'run' command, fdb waits for player to connect
	if([output rangeOfString:FDB_WAITING_CONNECT].location != NSNotFound) {
		[self setState:ST_WAITING_FOR_PLAYER];
		
	//Failed to connect to player
	} else if([output rangeOfString:FDB_CONNECTION_FAILED].location != NSNotFound) {
		[self alert: [NSString stringWithFormat: @"Failed to connect to player:\n\n%@", output]];
		[self dettach: self];
		
	//Connected and waiting for breakpoints
	} else if([output rangeOfString:FDB_INSERT_BREAKPOINTS].location != NSNotFound)
	{
		//Time to set Breakpoints
		NSLog(@"Setting %d breakpoints", [breakpoints count]);
		//Adding breakpoints to the list
		for(int i=0; i < [breakpoints count]; i++){
			NSLog(@"%@", [breakpoints objectAtIndex:i]);
			[fdbTask sendData:[@"b " stringByAppendingString:[[breakpoints objectAtIndex:i] lastPathComponent]]];//Set breakpoint
			[fdbTask sendData:@"\n"]; //Done!
		}
		
		//Telling fdb we're done setting everything
		[fdbTask sendData:@"continue\n"];
		
	} else  if([output rangeOfString:FDB_ALREADY_RUNNING].location != NSNotFound){
		[self alert: @"fdb already running, please, close it."];
		NSLog(@"FDB Already running");
		[fdbTask stopProcess];
		fdbTask = nil;
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

-(void) alert: (NSString *)message
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:message];
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

//Menu item validation
- (BOOL)validateToolbarItem:(NSToolbarItem *)item {
//	NSLog(@"validation done with state: %@", currentState);
	if([currentState isEqual: ST_NO_PROJECT_PATH])
	{
		return NO;
	} else if([currentState isEqual: ST_WAITING_FOR_PLAYER]) {
		if([item action] == @selector(dettach:)) {
			return YES;
		}
	} else if([currentState isEqual: ST_DISCONNECTED]) {
		if([item action] == @selector(connect:)) {
			return YES;
		}
	}
	
	//No response? Disable it
	return NO;
}

@end
