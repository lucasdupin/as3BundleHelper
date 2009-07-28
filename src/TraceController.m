#import "TraceController.h"


@implementation TraceController

- (void)awakeFromNib
{
	//Did we receive a flashlog variable in de commandline?
	NSString * flashlog;
	NSString * logParam = [[NSUserDefaults standardUserDefaults] stringForKey: @"flashlog"];
	if(logParam == NULL) {
		flashlog = [NSString stringWithUTF8String: strcat(getenv("HOME"), "/Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt")];
	}
	NSLog([@"Flashlog is : " stringByAppendingString: flashlog]);
	
	//Telling wich file we're reading
	[field setTextColor: [NSColor blackColor]];
	[field setString: [@"Reading: " stringByAppendingString: flashlog]];
	[field setString:[[field string] stringByAppendingString: @"\n"]];
	[field setUsesFontPanel:YES];
	[field setEditable:NO];
	
	//Start reading
	tailTask = [[TaskWrapper alloc] initWithController:self arguments:[NSArray arrayWithObjects:@"/usr/bin/tail", @"-f", flashlog, nil]];
	[tailTask startProcess];
	
	//Setting auto-aulpha
	[mainView setAutoAlpha: [autoAlphaButton state] == NSOnState];
	
	//Quit app after closing this window
	[NSApp setDelegate: self];
}

//Clear the text field
- (IBAction) clear: (id)sender
{
	[field setString: @" "];
}

//Make the text black
- (IBAction) separate: (id)sender
{
	[field setString:[[field string] stringByAppendingString: @"\n\n"]];
	[field scrollPageDown:self];
}

//Set auto alpha on Mouse Events
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
	[tailTask stopProcess];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
