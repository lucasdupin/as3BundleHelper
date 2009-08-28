//
//  DebuggingViewController.m
//  as3Debugger
//
//  Created by Lucas Dupin on 26/07/09.
//  Copyright 2009 28.room. All rights reserved.
//

#import "DebuggingViewController.h"

#pragma mark FDB Responses

//Connecting
#define FDB_WAITING_CONNECT				@"Waiting for Player to connect"
#define FDB_CONNECTION_FAILED			@"Failed to connect; session timed out."
#define FDB_INSERT_BREAKPOINTS			@"Set breakpoints and then type 'continue' to resume the session."
#define FDB_ALREADY_RUNNING				@"Another Flash debugger is probably running"
//Breakpointing
#define FDB_REACH_BREAKPOINT			@"^Breakpoint \\d+,.* (?<file>.*):(?<line>\\d+)\\n"
#define FDB_NEXT_BREAKPOINT				@"^ (?<line>\\d+)"


#pragma mark Application states
//Debugger states
#define ST_NO_PROJECT_PATH				@"no_project_path"
#define ST_DISCONNECTED					@"disconnected"
#define ST_WAITING_FOR_PLAYER_OR_FDB	@"waiting_for_player_to_connect"
#define ST_REACH_BREAKPOINT				@"reach_breakpoint"


@implementation DebuggingViewController

@synthesize connected;

/*
 Initialization:
 Gets the Default project Path and if there is no path, disable the window
 Gets the Flex SDK path
 Sets the delegate for validating menuItems (enabled or not)
 Set current state: ST_DISCONNECTED
 */
- (void)awakeFromNib
{
	//Enablig the toolbar based on the states
	[[window toolbar] setDelegate:self];
	
	//Did we receive a project path?
	projectPath = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey: @"flashProjectPath"];
	flexPath = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey: @"flexSDKPath"];
	
	if([projectPath length] <= 0 || [flexPath length] <= 0) {
		NSLog(@"No project, disabling window");
		[self setState:ST_NO_PROJECT_PATH];
	}
	
	
	//Checking if the flex path exists
	if(![[NSFileManager defaultManager] fileExistsAtPath:flexPath]){
		[self setState:ST_NO_PROJECT_PATH];
	} else {
		
		//setting our state
		[self setState:ST_DISCONNECTED];
		
	}
	connected = false;
	
}

#pragma mark Breakpoints an Files search methods
//Searches fo breakpoints in files
- (void) lookAfterBreakpoints
{
	if(breakpoints != nil) [breakpoints release];
		breakpoints = [[NSMutableArray alloc] init];
	
	NSLog(@"file loop?");
	for (int i=0; i<[actionScriptFiles count]; ++i) {
		
		NSString* file = [[actionScriptFiles objectAtIndex:i] copy];
		[[actionScriptFiles objectAtIndex:i] getCapturesWithRegexAndReferences: @".*\\/(?<file>.*.as)", @"${file}", &file, nil];
		NSLog(@"filename for %@",[actionScriptFiles objectAtIndex:i]);
		
		NSArray * res = [self getBookmarksForFile: [projectPath stringByAppendingPathComponent: [actionScriptFiles objectAtIndex:i]]];
		
		//Adding breakpoints to the list
		for(int j=0; j < [res count]; j++){
//			[breakpoints addObject:[[NSString alloc] initWithFormat:@"%@:%d", file, [[res objectAtIndex:j] intValue]+1]];
//			NSLog(@"Breakpoints in project: %@", [breakpoints objectAtIndex:[breakpoints count]-1]);
		}
	}
}

//Loops through the path and search for .as files in folders wich are not hidden
//get the metadata of the files looking for a plist of breakpoints
//(Textmate bookmarks)
- (void) findASFilesInPath: (NSString*)path
{
	actionScriptFiles = [[NSMutableArray alloc] init];
	
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
				[actionScriptFiles addObject:file];
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

#pragma mark Toolbar methods
//Starts FDB, find breakpoints in project path
- (IBAction) connect: (id)sender
{
	if(fdbTask != nil)
		[fdbTask stopProcess];
	
	//Set commands
	flexPath = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey: @"flexSDKPath"];
	fdbCommandPath = [[NSString alloc] initWithString:[[flexPath stringByAppendingPathComponent: @"bin/fdb"] autorelease]];
	
	//Reading breakpoints
	[self findASFilesInPath:projectPath];
	[self lookAfterBreakpoints];
	
	NSLog(@"FDB Command: %@", fdbCommandPath);
	NSArray * command = [NSArray arrayWithObjects: fdbCommandPath, nil];
	fdbTask = [[TaskWrapper alloc] initWithController:self arguments:command];
	[fdbTask setLaunchPath: flexPath];
	[fdbTask startProcess];
	
	[fdbTask sendData:@"run\n"];
}
- (IBAction) step: (id)sender
{
	[fdbTask sendData: @"next \n"];
}
- (IBAction) stepOut: (id)sender
{
	[fdbTask sendData: @"finish \n"];
}
- (IBAction) continueTilNextBreakPoint: (id)sender
{
	[fdbTask sendData: @"continue \n"];
}
- (IBAction) dettach: (id)sender
{
	[breakpoints release];
	[fdbTask stopProcess];
	[self setState: ST_DISCONNECTED];
}

#pragma mark Code navigation
//Show file with highlighted number in codeView
- (void) showFile: (NSString*)file at: (int)line
{
	NSString* htmlPath = [[NSBundle mainBundle] pathForResource: @"code" ofType: @"html" inDirectory: @"codeView"];
	NSString* htmlFileContents = [NSString stringWithContentsOfFile:htmlPath];
	
	//Finding the file in the list
	for (int i=0; i<[actionScriptFiles count]; ++i) {
		
		NSString* fileFound;
		[[actionScriptFiles objectAtIndex:i] getCapturesWithRegexAndReferences: @".*\\/(?<file>.*.as)", @"${file}", &fileFound, nil];
		
		if([file isEqual: fileFound]){
			//Opening code file
			NSString* code = [NSString stringWithContentsOfFile: [projectPath stringByAppendingPathComponent: [actionScriptFiles objectAtIndex:i]]];
			//Replacing code
			htmlFileContents = [htmlFileContents stringByReplacingOccurrencesOfString:@"%(code)s" withString: code];
			//Replace highlight line number
			htmlFileContents = [htmlFileContents stringByReplacingOccurrencesOfString:@"%(line)s" withString: [NSString stringWithFormat: @"%d", line]];
			
			NSLog(htmlFileContents);
			break;
		}
		
	}
	
	[[codeView mainFrame] loadHTMLString:htmlFileContents baseURL: [NSURL URLWithString: htmlPath]];
}

#pragma mark State changing
//Application state
- (void) setState:(NSString *)state
{
	if([state isEqual:ST_DISCONNECTED] || [state isEqual:ST_NO_PROJECT_PATH]){
		connected = NO;
	} else {
		connected = YES;
	}
	
	currentState = state;
	[[window toolbar] validateVisibleItems];
}
//Menu item validation
- (BOOL)validateToolbarItem:(NSToolbarItem *)item {
	//	NSLog(@"validation done with state: %@", currentState);
	if([currentState isEqual: ST_NO_PROJECT_PATH])
	{
		return NO;
	} else if([currentState isEqual: ST_WAITING_FOR_PLAYER_OR_FDB]) {
		if([item action] == @selector(dettach:)) {
			return YES;
		}
	} else if([currentState isEqual: ST_DISCONNECTED]) {
		if([item action] == @selector(connect:)) {
			return YES;
		}
	} else if([currentState isEqual:ST_REACH_BREAKPOINT]){
		if([item action] == @selector(dettach:) || [item action] == @selector(step:) || [item action] == @selector(stepOut:) || [item action] == @selector(continueTilNextBreakPoint:)) {
			return YES;
		}
	}
	
	//No response? Disable it
	return NO;
}

#pragma mark Task management
- (void)appendOutput:(NSString *)output
{
	NSLog([@"fdb:" stringByAppendingString:output]);
	
	
	/*******
	 What did fdb mean?
	 *******/
	
	//After 'run' command, fdb waits for player to connect
	if([output rangeOfString:FDB_WAITING_CONNECT].location != NSNotFound) {
		[self setState:ST_WAITING_FOR_PLAYER_OR_FDB];
		
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
	
	//Another instance of FDB is already running
	} else  if([output rangeOfString:FDB_ALREADY_RUNNING].location != NSNotFound){
		[self alert: @"fdb already running, please, close it."];
		NSLog(@"FDB Already running");
		[fdbTask stopProcess];
		fdbTask = nil;
		
	//Maybe he is saying something about breakpoints
	} else if([output isMatchedByRegex:FDB_REACH_BREAKPOINT]){
		//NSLog(@"REACH BREAKPOINT");
		
		//Found a breakpoint. Now we are going to set the toolbar state,
		//Capture the line and the name of the file and show it in
		//the code view
		
		//Toolbar
		[self setState:ST_REACH_BREAKPOINT];
		
		//Getting filename and line
		NSString *line;
		[output getCapturesWithRegexAndReferences: FDB_REACH_BREAKPOINT, @"${file}", &currentFile, @"${line}", &line, nil];
		
		//Showing file
		[self showFile: currentFile at: [line intValue]];

	//Continuing in breakpoint (updating line number)
	} else if([currentState isEqual:ST_REACH_BREAKPOINT] && [output isMatchedByRegex:FDB_NEXT_BREAKPOINT]) {
		
		//Getting filename and line
		NSString *line;
		[output getCapturesWithRegexAndReferences: FDB_NEXT_BREAKPOINT, @"${line}", &line, nil];
		
		//Showing file
		[self showFile: currentFile at: [line intValue]];
		
		[self setState: ST_REACH_BREAKPOINT];
		
	} else {
		
		//Dont; know what you're saying
		//[self alert:output];
	}


}
- (void)processStarted{};
- (void)processFinished{};

//Stops task. Useful for quitting the program and not leaving
//Something open
- (void)stopTask {
	[projectPath release];
	[fdbCommandPath release];
	[flexPath release];
	[fdbTask release];
	
	[breakpoints release];
}

#pragma mark Helpers
- (NSWindow *)getWindow
{
	return window;
}


-(void) alert: (NSString *)message
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:message];
	[alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

@end
