/*  Camera2.h
  

  Created by bach on 10.06.09.
  Copyright 2009 Prof. Michael Bach. All rights reserved.

	History
	=======

	2012-07-28 Xcode 4.4

*/

#import <Cocoa/Cocoa.h>
#import "Camera2.h"


@interface MDBAppDelegate: NSObject <NSApplicationDelegate> {

//@property (assign) IBOutlet NSWindow *window;
	IBOutlet NSWindow *window;
	IBOutlet QTCaptureView	*mCaptureView;
	IBOutlet NSTextField* stillImageFileName;
	Camera2* camera;
	BOOL _isMenuBarVisible, _isAutoHideOtherApplications;
}

@end
