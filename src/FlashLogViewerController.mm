#import "FlashLogViewerController.h"


@implementation FlashLogViewerController

#define WARNING_MESSAGE		@"warning"
#define ERROR_MESSAGE		@"error"

@synthesize field;

- (id)init {
	NSLog(@"flashlog init");
    return [super initWithWindowNibName:@"FlashLogViewer" owner: self];
	
}

- (void)windowDidLoad
{
	//Did we receive a flashlog variable in de commandline?
	NSString * flashlog = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey: @"flashLogPath"];
	if(![[NSFileManager defaultManager] fileExistsAtPath: [NSString stringWithFormat:@"%@", flashlog]]) {
		NSLog(@"nil log path value");
		flashlog = [NSString stringWithUTF8String: strcat(getenv("HOME"), "/Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt")];
		[[[NSUserDefaultsController sharedUserDefaultsController] values] setValue:flashlog forKey: @"flashLogPath"];
		
		//Checking if the file does not exist because mm.cfg was not set up
		if (![[NSFileManager defaultManager] fileExistsAtPath: @"/Library/Application Support/Macromedia/mm.cfg"]) {
			NSLog(@"No mm.cfg indeed...");
			//Ok, let's create it...
			NSString *mmCfg = @"ErrorReportingEnable=1 \nTraceOutputFileEnable=1";
			[mmCfg writeToFile:@"/Library/Application Support/Macromedia/mm.cfg" atomically:YES encoding: NSUTF8StringEncoding error:nil];
		}
	}
	NSLog(@"%@", [@"Flashlog is : " stringByAppendingString: flashlog]);
	
	//Telling wich file we're reading
	[field setTextColor: [NSColor blackColor]];
	[field setString: [NSString stringWithFormat: @"Reading: %@\n", flashlog]];
	[field setUsesFontPanel:YES];
	[field setEditable:NO];
	
	//Workaroud for bug in scrollview, where the scroll does no update when app starts
	//Forcing redraw
	NSRect frame = [[self window] frame];
	frame.size.height += 1;
	[[self window] setFrame:frame display:YES animate: YES];
	
	//Start to read file
	[self startTask];
	
	//Setting the font of the TextView
	if([[NSUserDefaults standardUserDefaults] stringForKey: @"flashlogFontName"] != nil){
		field.font = [NSFont	fontWithName:	[[NSUserDefaults standardUserDefaults] stringForKey:@"flashlogFontName"]
								size:			[[NSUserDefaults standardUserDefaults] floatForKey:@"flashlogFontSize"]];
	}
}

//Clear the text field
- (IBAction) clear: (id)sender
{
	[field setString: @" "];
}

//Tint the text
- (IBAction) separate: (id)sender
{
	if([field string] != nil){
		
		//Getting the color
		NSData * colorData = [[NSUserDefaults standardUserDefaults] dataForKey:@"flashlogTintColor"];
		NSColor * theColor = [NSUnarchiver unarchiveObjectWithData:colorData];
		
		//Getting the string
		NSMutableAttributedString * text = [[[NSMutableAttributedString alloc]
											  initWithString: [field string]] autorelease];
		//Setting attributes
		[text addAttribute:NSFontAttributeName value:[field font] range:NSMakeRange(0, [text length])];
		[text addAttribute:NSForegroundColorAttributeName value:theColor range:NSMakeRange(0, [text length])];
		
		//Setting string
		[[field textStorage] setAttributedString: text];
		
	}
}

- (void) startTask
{
	NSString * flashlog = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey: @"flashLogPath"];
	
	//Start reading
	tailTask = [[TaskWrapper alloc] initWithController:self arguments:[NSArray arrayWithObjects:@"/usr/bin/tail", @"-f", flashlog, nil]];
	[tailTask startProcess];
	
	[flashlog autorelease];
}


- (void)processStarted{}
- (void)processFinished{}
- (void)appendOutput:(NSString *)output
{
	if (output == nil) {
		return;
		//Nothing to do here
	}
	
	//Will we scroll the field?
	BOOL shouldScroll = [[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey: @"flashlogAlwaysScroll"] boolValue]; //Preference
	//NSLog(@"should scroll: %d", shouldScroll);
	if(!shouldScroll){
		//The preference says we must check if we're going to auto-scroll
		shouldScroll = ((int)NSMaxY([field bounds]) == (int)NSMaxY([field visibleRect]));
	}
	
	//Retrieving from userDefaults
	
	NSColor * theColor;
	NSData * colorData = [[NSUserDefaults standardUserDefaults] dataForKey:@"flashlogTextColor"];
	
	//Do we get an empty value?
	//Let's fill our user defaults
	if(colorData == nil){
		[[NSUserDefaults standardUserDefaults] 
		 setObject:
			[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]]
		forKey:@"flashlogTextColor"];
		
		[[NSUserDefaults standardUserDefaults] 
		 setObject:
		 [NSArchiver archivedDataWithRootObject:[NSColor redColor]]
		 forKey:@"flashlogExceptionColor"];
		
		[[NSUserDefaults standardUserDefaults] 
		 setObject:
		 [NSArchiver archivedDataWithRootObject:[NSColor yellowColor]]
		 forKey:@"flashlogWarningColor"];
		
		[[NSUserDefaults standardUserDefaults] 
		 setObject:
		 [NSArchiver archivedDataWithRootObject:[NSColor yellowColor]]
		 forKey:@"flashlogTintColor"];
	}
	
	NSArray * lines = [output componentsSeparatedByString:@"\n"];
	NSString * line;
	for (int i=0; i<[lines count]; ++i) {
		//Getting the line
		if(i < [lines count] -1){
			line = [NSString stringWithFormat:@"%@\n",[lines objectAtIndex:i]];
		} else {
			line = [lines objectAtIndex:i];
		}
		
		if ([line rangeOfString:ERROR_MESSAGE options: NSCaseInsensitiveSearch].location != NSNotFound) {
			colorData= [[NSUserDefaults standardUserDefaults] dataForKey:@"flashlogExceptionColor"];
		} else if ([line rangeOfString:WARNING_MESSAGE options: NSCaseInsensitiveSearch].location != NSNotFound) {
			colorData= [[NSUserDefaults standardUserDefaults] dataForKey:@"flashlogWarningColor"];
		} else {
			colorData= [[NSUserDefaults standardUserDefaults] dataForKey:@"flashlogTextColor"];
		}

		if (colorData != nil) {
			theColor = (NSColor *)[NSUnarchiver unarchiveObjectWithData:colorData];
		}
		
		NSMutableAttributedString * toAdd = [[[NSMutableAttributedString alloc]
											  initWithString: line] autorelease];
		[toAdd addAttribute:NSFontAttributeName value:[field font] range:NSMakeRange(0, [toAdd length])];
		[toAdd addAttribute:NSForegroundColorAttributeName value:theColor range:NSMakeRange(0, [toAdd length])];
		[[field textStorage] appendAttributedString: toAdd];

	}
	
	if(shouldScroll)
		[field scrollRangeToVisible:NSMakeRange([[field string] length], 0)];

}

- (void) stopTask
{
	[tailTask stopProcess];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
