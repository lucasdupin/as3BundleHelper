#import "FlashLogViewerController.h"


@implementation FlashLogViewerController

#define WARNING_MESSAGE		@"warning"
#define ERROR_MESSAGE		@"error"

@synthesize field;

- (id)init {
	NSLog(@"flashlog init");
    return [super initWithWindowNibName:@"FlashLogViewer" owner: self];
	
}

- (void)awakeFromNib
{
	NSLog(@"Tracer awaken %@", window);
	
	//Did we receive a flashlog variable in de commandline?
	NSString * flashlog = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey: @"flashLogPath"];
	if(![[NSFileManager defaultManager] fileExistsAtPath: flashlog]) {
		flashlog = [NSString stringWithUTF8String: strcat(getenv("HOME"), "/Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt")];
		[[[NSUserDefaultsController sharedUserDefaultsController] values] setValue:flashlog forKey: @"flashLogPath"];
	}
	NSLog(@"%@", [@"Flashlog is : " stringByAppendingString: flashlog]);
	
	//Telling wich file we're reading
	[field setTextColor: [NSColor blackColor]];
	[field setString: [@"Reading: " stringByAppendingString: flashlog]];
	[field setString:[[field string] stringByAppendingString: @"\n"]];
	[field setUsesFontPanel:YES];
	[field setEditable:NO];
	
	[self startTask];
	
	//Setting auto-aulpha
	[alphaPanel setAutoAlpha: [autoAlphaButton state] == NSOnState];
	
	NSLog(@"done starting");
}

//Clear the text field
- (IBAction) clear: (id)sender
{
	[field setString: @" "];
}

//Make the text black
- (IBAction) separate: (id)sender
{
	if([field string] != nil){
		[field setString:[[field string] stringByAppendingString: @"\n\n"]];
		[field scrollPageDown:self];
	}
}

//Set auto alpha on Mouse Events
- (IBAction) setAutoAlpha: (id)sender
{
	[alphaPanel setAutoAlpha: [autoAlphaButton state] == NSOnState];
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

}

- (NSPanel *)getWindow
{
	return window;
}

- (void) stopTask
{
	[tailTask stopProcess];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
