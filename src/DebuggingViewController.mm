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
#define FDB_WAITING_CONNECT					@"Waiting for Player to connect"
#define FDB_CONNECTION_FAILED				@"Failed to connect; session timed out."
#define FDB_INSERT_BREAKPOINTS				@"Set breakpoints and then type 'continue' to resume the session."
#define FDB_INSERT_ADDITIONAL_BREAKPOINTS	@"Set additional breakpoints as desired, and then type 'continue'."
#define FDB_ALREADY_RUNNING					@"Another Flash debugger is probably running"
//Breakpointing
#define FDB_REACH_BREAKPOINT				@"^Breakpoint \\d+,.* (?<file>.*):(?<line>\\d+)\\n"
#define FDB_NEXT_BREAKPOINT					@"^(.*\\n)* (?<line>\\d+)[\\t+| +]"
//Reading vars
#define FDB_VARIABLE_LIST					@"^\\$\\d+ = this = \\[(.+) \\d+, class=\\'(?<class>.+)\\'\\]"
#define FDB_GET_VARIABLE_VALUE				@"^\\s(?<name>.+)\\s=\\s(?<value>.+)$"


#pragma mark Application states
//Debugger states
#define ST_NO_PROJECT_PATH					@"no_project_path"
#define ST_DISCONNECTED						@"disconnected"
#define ST_WAITING_FOR_PLAYER_OR_FDB		@"waiting_for_player_to_connect"
#define ST_REACH_BREAKPOINT					@"reach_breakpoint"
#define ST_REACH_BREAKPOINT__READING_VARS	@"reading_vars"


@implementation DebuggingViewController

@synthesize connected;

- (id)init {
    return [super initWithWindowNibName:@"DebuggingView"];
}

/*
 Initialization:
 Gets the Default project Path and if there is no path, disable the window
 Gets the Flex SDK path
 Sets the delegate for validating menuItems (enabled or not)
 Set current state: ST_DISCONNECTED
 */
- (void)windowDidLoad
{
	//Enablig the toolbar based on the states
	[[window toolbar] setDelegate:self];

	connected = false;
	[self setState:ST_DISCONNECTED];
	
	fdbCommunicator = [[FDBCommunicator alloc] init];
	[fdbCommunicator setDelegate:self];
}


#pragma mark Breakpoints an Files search methods
- (NSArray *) lookAfterBreakpointsInFiles: (NSArray *) actionScriptFiles
{
	//Return var
	NSMutableArray * theBreakpoints = [[NSMutableArray alloc] init];
	
	//Project path
	NSString * projectPath = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey: @"flashProjectPath"];
	
	//Loop
	for (int i=0; i<[actionScriptFiles count]; ++i) {
		
		NSString* file = [[actionScriptFiles objectAtIndex:i] copy];
		//NSLog(@"paths: %@", file);
		[[actionScriptFiles objectAtIndex:i] getCapturesWithRegexAndReferences: @".*\\/(?<file>.*.as)", @"${file}", &file, nil];
		//NSLog(@"regex");
		
		NSArray * res = [self getBookmarksForFile: [projectPath stringByAppendingPathComponent: [actionScriptFiles objectAtIndex:i]]];
		
		//Adding breakpoints to the list
		for(int j=0; j < [res count]; j++){
			[theBreakpoints addObject:[[NSString alloc] initWithFormat:@"%@:%d", file, [[res objectAtIndex:j] intValue]+1]];
			NSLog(@"Breakpoints in project: %@", [theBreakpoints objectAtIndex:[theBreakpoints count]-1]);
		}
	}
	
	return theBreakpoints;
}


- (NSArray *) findASFiles
{
	//Return var
	NSMutableArray * actionScriptFiles = [[NSMutableArray alloc] init];
	
	NSString *	path = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey: @"flashProjectPath"];
	
	//Regexes
	NSPredicate * regexHidden =		[NSPredicate predicateWithFormat: @"SELF MATCHES %@",@"^[\\.].*"];		//Begins with .
	NSPredicate * regexHiddenPath =	[NSPredicate predicateWithFormat: @"SELF MATCHES %@",@".*/[\\.].*"];	//Contains a hidden path
	NSPredicate * regexASFile =		[NSPredicate predicateWithFormat: @"SELF MATCHES %@",@".*\\.as$"];		//.as file
	
	//Loop through files
	NSFileHandle * file;
	NSDirectoryEnumerator * enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
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
	
	return actionScriptFiles;
}

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
- (IBAction) connect: (id)sender
{
	//Clear the code panel
	[self showFile:nil at:0];
	
	//Did we receive a project path?
	NSString * flexPath = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey: @"flexSDKPath"];
	NSString * projectPath = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey: @"flashProjectPath"];	
	if([projectPath length] <= 0) {
		[self setState:ST_NO_PROJECT_PATH];
		[self alert:@"No project path was set"];
		
		return;
	}
	if([flexPath length] <= 0) {
		[self setState:ST_NO_PROJECT_PATH];
		[self alert:@"No SDK path was set"];
		
		return;
	}
	//Checking if the flex path exists
	if(![[NSFileManager defaultManager] fileExistsAtPath:flexPath]){
		[self setState:ST_NO_PROJECT_PATH];
		[self alert:@"SDK does not exist in the path given"];
		
		return;
	}
	
	//Finding source files in project path
	NSArray *actionScriptFiles = [self findASFiles];
	
	//finding breakpoints
	breakpoints = [self lookAfterBreakpointsInFiles: actionScriptFiles];
	
	//Start fdb
	[fdbCommunicator start];
	
	//Tell it to run
	[fdbCommunicator sendCommand: @"run" withDelimiter: nil];
}
- (IBAction) step: (id)sender
{
	//Clear the code panel
	[self showFile:nil at:0];
	
	//Send command
	[fdbCommunicator sendCommand: @"next"];
}
- (IBAction) stepOut: (id)sender
{
	//Clear the code panel
	[self showFile:nil at:0];
	
	//Send command
	[fdbCommunicator sendCommand: @"finish"];
}
- (IBAction) continueTilNextBreakPoint: (id)sender
{
	//Clear the code panel
	[self showFile:nil at:0];
	
	//Send command
	[fdbCommunicator sendCommand: @"continue"];
}
- (IBAction) dettach: (id)sender
{
	//Clear the code panel
	[self showFile:nil at:0];
	
	//Send command
	[fdbCommunicator stop];
	[self setState: ST_DISCONNECTED];
}

#pragma mark Code presentation
- (void) showFile: (NSString*)file at: (int)line
{
	NSString * htmlPath =			[[NSBundle mainBundle] pathForResource: @"code" ofType: @"html" inDirectory: @"codeView"];
	NSString * htmlFileContents =	[NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
	NSString * projectPath =		[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey: @"flashProjectPath"];
	NSArray * actionScriptFiles =	[self findASFiles];
	
	NSLog(@"showing file %@ at line %d", file, line);
	
	//Finding the file in the list
	if(file != nil)
		for (int i=0; i<[actionScriptFiles count]; ++i) {
			
			NSString* fileFound = [actionScriptFiles objectAtIndex:i];
			[[actionScriptFiles objectAtIndex:i] getCapturesWithRegexAndReferences: @".*\\/(?<file>.*.as)", @"${file}", &fileFound, nil];
			
			if([file isEqual: fileFound]){
				//Opening code file
				NSString* code = [NSString stringWithContentsOfFile: [projectPath stringByAppendingPathComponent: [actionScriptFiles objectAtIndex:i]] encoding: NSUTF8StringEncoding error:nil];
				//Replacing code
				htmlFileContents = [htmlFileContents stringByReplacingOccurrencesOfString:@"%(code)s" withString: code];
				//Replace highlight line number
				htmlFileContents = [htmlFileContents stringByReplacingOccurrencesOfString:@"%(line)s" withString: [NSString stringWithFormat: @"%d", line]];
				
				//NSLog(@"%@", htmlFileContents);
				break;
			}
			
		}
	else {
		htmlFileContents = [htmlFileContents stringByReplacingOccurrencesOfString:@"%(code)s" withString: @""];
	}

	
	[[codeView mainFrame] loadHTMLString:htmlFileContents baseURL: [NSURL URLWithString: htmlPath]];
}

- (void) parseVarsForString: (NSString *)inputString atNode: (Variable *) fromVar
{
	NSMutableArray * result = [[[NSMutableArray alloc] init] autorelease];
	NSArray * lines = [inputString componentsSeparatedByString:@"\n"];
	NSString * line;
	
	NSLog(@"PARSING VARS FROM FDB");

	//Not first line, it's not a var
	for (int i=0; i < [lines count]; ++i) {
		//Getting the line
		line = [lines objectAtIndex:i];
		
		if([line isMatchedByRegex: FDB_GET_VARIABLE_VALUE]){
			Variable * v = [[Variable alloc] init];

			NSString *name;
			NSString *value;
			
			[line getCapturesWithRegexAndReferences: FDB_GET_VARIABLE_VALUE, @"${name}", &name, @"${value}", &value, nil];
			
			v.name = name;
			v.value = value;
			
			//NSLog(@"Found var: %@ -> %@", v.name, v.value);
			[result addObject:v];
		}
	}
	
	[variablesTree setContent:result];
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
	
	NSLog(@"state changed to: %@", state);
}
//Menu item validation
- (BOOL)validateToolbarItem:(NSToolbarItem *)item {
	//	NSLog(@"validation done with state: %@", currentState);
	if([currentState isEqual: ST_WAITING_FOR_PLAYER_OR_FDB]) {
		if([item action] == @selector(dettach:)) {
			return YES;
		}
	} else if([currentState isEqual: ST_DISCONNECTED] || [currentState isEqual: ST_NO_PROJECT_PATH ]) {
		if([item action] == @selector(connect:)) {
			return YES;
		}
	} else if([currentState isEqual:ST_REACH_BREAKPOINT] || [currentState isEqual:ST_REACH_BREAKPOINT__READING_VARS]){
		if([item action] == @selector(dettach:) || [item action] == @selector(step:) || [item action] == @selector(stepOut:) || [item action] == @selector(continueTilNextBreakPoint:)) {
			return YES;
		}
	}
	
	//No response? Disable it
	return NO;
}

#pragma mark Task management
-(void) gotMessage:(NSString *)message forCommand:(NSString *)command
{
	/*******
	 What did fdb mean?
	 *******/
	
	//After 'run' command, fdb waits for player to connect
	if([message rangeOfString:FDB_WAITING_CONNECT].location != NSNotFound) {
		NSLog(@"WAITING::: %@=%@", command, message);
		[self setState:ST_WAITING_FOR_PLAYER_OR_FDB];
		
		//Failed to connect to player
	} else if([message rangeOfString:FDB_CONNECTION_FAILED].location != NSNotFound) {
		[self alert: [NSString stringWithFormat: @"Failed to connect to player:\n\n%@", message]];
		[self dettach: self];
		
		//Connected and waiting for breakpoints
	} else if([message rangeOfString:FDB_INSERT_BREAKPOINTS].location != NSNotFound)
	{
		//Time to set Breakpoints
		NSLog(@"Setting %d breakpoints", [breakpoints count]);
		//Adding breakpoints to the list
		for(int i=0; i < [breakpoints count]; i++){
			NSLog(@"%@", [breakpoints objectAtIndex:i]);
			NSString * b = [NSString stringWithFormat: @"b %@", [[breakpoints objectAtIndex:i] lastPathComponent]];//Set breakpoint
			[fdbCommunicator sendCommand: b];
		}
		
		//Telling fdb we're done setting everything
		[fdbCommunicator sendCommand:@"continue" withDelimiter: nil];
		
		//Another instance of FDB is already running
	} else  if([message rangeOfString:FDB_ALREADY_RUNNING].location != NSNotFound){
		[self alert: @"fdb already running, please, close it."];
		NSLog(@"FDB Already running");
		[fdbCommunicator stop];
		
		//Maybe he is saying something about breakpoints
	} else if([message isMatchedByRegex:FDB_REACH_BREAKPOINT]){
		//NSLog(@"REACH BREAKPOINT");
		
		//Found a breakpoint. Now we are going to set the toolbar state,
		//Capture the line and the name of the file and show it in
		//the code view
		
		//Toolbar
		[self setState:ST_REACH_BREAKPOINT];
		
		//Getting filename and line
		NSString *line;
		[message getCapturesWithRegexAndReferences: FDB_REACH_BREAKPOINT, @"${file}", &currentFile, @"${line}", &line, nil];
		
		//Showing file
		[self showFile: currentFile at: [line intValue]];
		
		//Asking for vars
		currentInspectedVar = @"this";
		[fdbCommunicator sendCommand:@"print this."];
		
		//Continuing in breakpoint (updating line number)
	} else if([currentState isEqual:ST_REACH_BREAKPOINT] && [message isMatchedByRegex:FDB_NEXT_BREAKPOINT]) {
		
		//Getting filename and line
		NSString *line;
		[message getCapturesWithRegexAndReferences: FDB_NEXT_BREAKPOINT, @"${line}", &line, nil];
		
		//Showing file
		[self showFile: currentFile at: [line intValue]];
		
		[self setState: ST_REACH_BREAKPOINT];
		
		//Asking for vars
		currentInspectedVar = @"this";
		[fdbCommunicator sendCommand:@"print this."];
		
	} else if ([message isMatchedByRegex: [NSString stringWithFormat: FDB_VARIABLE_LIST, currentInspectedVar]]) {
		
		[self parseVarsForString: message atNode: nil];
		[self setState:ST_REACH_BREAKPOINT];

	} else {
		
		//Dont; know what you're saying
		NSLog(@"fdb: %@", message);
		//[self alert:output];
	}
}

- (void)stopTask {
	[fdbCommunicator stop];
	[fdbCommunicator release];
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
