//
//  Camera2.h
//  ERG2007
//
//  Created by bach on 10.06.09.
//  Copyright 2009 Prof. Michael Bach. All rights reserved.
//
//	History
//	=======
//
//	2013-11-03	added readout of image size, doesn't really work.
//				added saving of still images
//


#import <Cocoa/Cocoa.h>
#import <QTKit/QTkit.h>


@interface Camera2: NSObject {
	BOOL	isRunning;
	BOOL	autoNumberStillImages;
	NSString* stillImageFilePathName;
}


- (id)		initWithView: (QTCaptureView*) mCaptureView;
- (void)	takeStillImage;
- (void)	stopAndClose;	
@property (readonly) BOOL	isRunning;
@property BOOL	autoNumberStillImages;
@property (assign) NSString* stillImageFilePathName;


@end
