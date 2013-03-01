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
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTkit.h>


@interface Camera2: NSObject {
	BOOL	isRunning;
}


- (id)		initWithView: (QTCaptureView*) mCaptureView;

- (void)	stopAndClose;
	
@property (readonly) BOOL	isRunning;


@end
