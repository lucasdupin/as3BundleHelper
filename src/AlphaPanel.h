//
//  AlphaPanel.h
//  as3Debugger
//
//  Created by Lucas Dupin on 04/07/09.
//  Copyright 2009 28.room. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface AlphaPanel : NSView {
	NSTrackingRectTag rectTag;
	BOOL autoAlpha;
}

- (void) setAutoAlpha: (BOOL)value;

@end
