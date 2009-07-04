#import "TraceController.h"


@implementation TraceController

- (void)awakeFromNib
{
	//Searching for the flashlog.txt in the envirinment
	char * flashlog = getenv("FLASHLOG");
	if(flashlog==NULL){
		flashlog = strcat(getenv("HOME"), "/Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt");
	}
	
	//Telling wich file we're reading
	[field setTextColor: [NSColor blackColor]];
	[field setString: [@"Reading: " stringByAppendingString: [NSString stringWithUTF8String:flashlog]]];
	[field setString:[[field string] stringByAppendingString: @"\n"]];
	[field setEditable:NO];
	
	//Start reading
	NSString *filePath = [NSString stringWithUTF8String:flashlog];
	tailTask = [[TaskWrapper alloc] initWithController:self arguments:[NSArray arrayWithObjects:@"/usr/bin/tail", @"-f", filePath, nil]];
	[tailTask startProcess];
	
	//Setting auto-aulpha
	[mainView setAutoAlpha: [autoAlphaButton state] == NSOnState];
	
	//Quit app after closing this window
	[NSApp setDelegate: self];
}

- (IBAction) clear: (id)sender
{
	[field setString: @" "];
}
- (IBAction) separate: (id)sender
{
	[field setString:[[field string] stringByAppendingString: @"\n\n"]];
	[field scrollPageDown:self];
}

- (IBAction) setAutoAlpha: (id)sender
{
	[mainView setAutoAlpha: [autoAlphaButton state] == NSOnState];
}


- (void)processStarted{}
- (void)processFinished{}
- (void)appendOutput:(NSString *)output
{
	
	NSMutableAttributedString * toAdd = [[[NSMutableAttributedString alloc]
								 initWithString: output] autorelease];
	[toAdd addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, [toAdd length])];
    [[field textStorage] appendAttributedString: toAdd];
	[field scrollPageDown:self];
}

-(void)dealloc
{
	[super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

@end
