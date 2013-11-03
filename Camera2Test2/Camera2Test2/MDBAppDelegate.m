//
//  MDBAppDelegate.m
//  Camera2Test2
//
//  Created by Bach on 28.07.12.
//  Copyright (c) 2012 Bach. All rights reserved.
//

#import "MDBAppDelegate.h"

@implementation MDBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	[NSApp setDelegate: self];	// necessary for "applicationShouldTerminate"
	camera = [[Camera2 alloc] initWithView: mCaptureView];
	[stillImageFileName setStringValue: [camera stillImageFilePathName]];
}


- (void) windowWillClose:(NSNotification *)notification {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
#pragma unused (notification)
	[camera stopAndClose];
	//[camera dealloc];
}


- (IBAction) takeStillImageButton_action: (id) sender {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	[camera setStillImageFilePathName: [stillImageFileName stringValue]];
	[camera takeStillImage];
}


- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)app {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
#pragma unused (app)
	[camera stopAndClose];
	//	NSLog(@"applicationShouldTerminate end");
	return NSTerminateNow;
}


- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

@end
