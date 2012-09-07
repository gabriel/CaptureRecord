//
//  CRRecordable.h
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/16/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>

/*!
 The CRRecordable protocol defines a renderable view with a fixed size.
 
 If the CRRecordable needs to start and stop, they can define those methods and will be notified of start and stop events.
 
 @see CRScreenRecorder
 @see CRCameraRecorder
 @see CRUIViewRecorder
 */
@protocol CRRecordable <NSObject>
- (void)renderInContext:(CGContextRef)context;
- (CGSize)size;
@optional
- (BOOL)start:(NSError **)error;
- (BOOL)stop:(NSError **)error;
@end

/*!
 The CRAudioWriter protocol defines that a class can record audio. 
 
 @see CRViewWriter
 */
@protocol CRAudioWriter <NSObject>
- (BOOL)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end
