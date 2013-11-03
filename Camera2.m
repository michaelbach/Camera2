//
//  Camera2.m
//  ERG2007
//
//  Created by bach on 10.06.09.
//  Copyright 2009 Prof. Michael Bach. All rights reserved.
//
/* if more than one video source, need to add something like below (2011-11-10 from Thomas Meigen)
videoDevices = [[[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo] arrayByAddingObjectsFromArray:[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeMuxed]] retain];
...

QTCaptureDevice *videoDevice;
if ([videoDevices count] > 1) {
	videoDevice = [QTCaptureDevice deviceWithUniqueID:[[videoDevices objectAtIndex:1] uniqueID]]; 
}
*/
#import "Camera2.h"


@implementation Camera2


static bool takeStillImage;
static QTCaptureSession		*mCaptureSession;
static QTCaptureDeviceInput	*mCaptureVideoDeviceInput;
//static NSArray			*videoDevices;


@synthesize stillImageFilePathName;

@synthesize autoNumberStillImages;


- (CIImage *)view:(QTCaptureView *)view willDisplayImage :(CIImage *)image {	//		NSLog(@"%s", __PRETTY_FUNCTION__);
	static NSUInteger stillImageCount = 0;
	if (takeStillImage) {
		NSNumber* compress = [NSNumber numberWithFloat: 1.0];
		NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCIImage:image];
		NSData* iData = [rep representationUsingType: NSJPEGFileType properties:[NSDictionary dictionaryWithObject: compress forKey: NSImageCompressionFactor]];
		NSString* fileString;
		if (autoNumberStillImages) {
			fileString = [NSString stringWithFormat:@"%@-%lu.jpg", stillImageFilePathName, stillImageCount];  stillImageCount++;
		} else {
			fileString = [NSString stringWithFormat:@"%@.jpg", stillImageFilePathName];
		}
		if (![iData writeToFile: fileString atomically: NO]) NSLog(@"Camera2>writeToFile<%@: error", fileString);
		takeStillImage = NO;
	}
	return image;
}


- (void) takeStillImage {
	takeStillImage = YES;
}


- (id) initWithView: (QTCaptureView*) mCaptureView {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	if ((self = [super init])) {
		takeStillImage = NO;  [self setAutoNumberStillImages: NO];  [self setStillImageFilePathName: @"cameraFrame"];
		mCaptureSession = [[QTCaptureSession alloc] init];	// Create the capture session
		QTCaptureDevice *videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo]; // Find a video device
		NSError *error;
		BOOL success = (videoDevice != nil) && [videoDevice open: &error];
		if (!success) {	// If a QTMediaTypeVideo input device can't be found or opened, try to find and open a muxed input device
			//NSLog(@"Camera2>initWithView: No “QTMediaTypeVideo” device was found");
			videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeMuxed];  
			success = [videoDevice open: &error];
		}
		if (!success) {  NSLog(@"Camera2>initWithView: no QTMediaType device found");
			videoDevice = nil;// Handle error
		}
		
		/*[videoDevice.formatDescriptions enumerateObjectsUsingBlock:^(QTFormatDescription* formatDescription, NSUInteger idx, BOOL* stop) {
			NSDictionary* attributes = [formatDescription formatDescriptionAttributes];
			NSValue* videoEncodedPixelsSize = [attributes objectForKey:@"videoEncodedPixelsSize"];
			NSSize videoSize = [videoEncodedPixelsSize sizeValue];
			NSLog(@"%@", NSStringFromSize(videoSize));
		}];*/
       // NSArray *fs = [NSArray arrayWithArray:videoDevice.formatDescriptions];
		NSUInteger nOfFormatDescriptions = [videoDevice.formatDescriptions count];
		for (NSUInteger idx = 0; idx<nOfFormatDescriptions; ++idx) {
			NSLog(@"\r\rIndex %lu of %lu: ", idx, nOfFormatDescriptions);
			QTFormatDescription* formatDescription = [videoDevice.formatDescriptions objectAtIndex: idx];
			NSDictionary* formatAttribs = [formatDescription formatDescriptionAttributes];
			NSValue* value = [formatAttribs objectForKey: QTFormatDescriptionVideoEncodedPixelsSizeAttribute];
			NSSize size = [value sizeValue];
			NSLog(@"QTFormatDescriptionVideoEncodedPixelsSizeAttribute: %@", NSStringFromSize(size));

			value = [formatAttribs objectForKey: QTFormatDescriptionVideoProductionApertureDisplaySizeAttribute];
			size = [value sizeValue];
			NSLog(@"QTFormatDescriptionVideoProductionApertureDisplaySizeAttribute: %@", NSStringFromSize(size));

			value = [formatAttribs objectForKey: QTFormatDescriptionVideoCleanApertureDisplaySizeAttribute];
			size = [value sizeValue];
			NSLog(@"QTFormatDescriptionVideoCleanApertureDisplaySizeAttribute: %@", NSStringFromSize(size));

		}
		//videoDevice = nil;	// here one can easily deactivate video for testing
		if (videoDevice) {	//		NSLog(@"Camera2: Ø error");
			mCaptureVideoDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice: videoDevice]; //Add the video device to the session as a device input
			success = [mCaptureSession addInput: mCaptureVideoDeviceInput error: &error];
			if (!success) {			// Handle error
				NSLog(@"Camera2>initWithView: Couldn't add input to capture session");
			} else { //	NSLog(@"Camera2>success");
				[mCaptureView setCaptureSession: mCaptureSession];  // Associate the capture view in the UI with the session
				[mCaptureSession startRunning];
				isRunning = YES;
			}
		}
		[mCaptureView setDelegate: self];
	}
	//NSLog(@"%s exit.", __PRETTY_FUNCTION__);
	return self;
}


- (void) stopAndClose {	//	NSLog(@"%s", __PRETTY_FUNCTION__);
	if (!isRunning) return;
	@try {
		[mCaptureSession stopRunning];	// here the crash: 2009-06-10 11:17:30.699 Camera2Test[193:10b] *** -[NSLock lock]: deadlock (<NSLock: 0x84bd20> '(null)')
		//	2009-06-10 11:17:30.700 Camera2Test[193:10b] *** Break on _NSLockError() to debug.
		//	2009-06-10 11:17:30.798 Camera2Test[193:7c07] *** -[NSLock unlock]: lock (<NSLock: 0x84bd20> '(null)') unlocked from thread which did not lock it
		//	2009-06-10 11:17:30.798 Camera2Test[193:7c07] *** Break on _NSLockError() to debug.
		// *** WOHL FEHLER IM MACAM-TREIBER
	}
	@catch(NSException *e) {
		NSLog(@"Camera2>stopAndClose, catching %@ reason %@", [e name], [e reason]);
	}
	@finally {
		//something that you want to do wether the exception is thrown or not.
		[[mCaptureVideoDeviceInput device] close];
	}
}
	
	
- (void) dealloc {		NSLog(@"%s", __PRETTY_FUNCTION__);
	[self stopAndClose];
//#if !__has_feature(objc_arc)
	[mCaptureSession release];
	[mCaptureVideoDeviceInput release];
	[super dealloc];
//#endif
}
	
	
- (BOOL) isRunning {
	return [mCaptureSession isRunning];
}


@end
