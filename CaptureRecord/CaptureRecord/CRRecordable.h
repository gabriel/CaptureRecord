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

/*!
 Render the recordable in the specified context.
 @param context Context to render in
 */
- (void)renderInContext:(CGContextRef)context;

/*!
 @result The size of the recordable. This size must be fixed and is required before any rendering begins.
 */
- (CGSize)size;

@optional

/*!
 When the recording is started, we will notify the recordable.
 @param error Out error
 @result YES if started successfully, NO otherwise
 */
- (BOOL)start:(NSError **)error;

/*!
 When the recording is stopped, we will notify the recordable.
 @param error Out error
 @result YES if stopped successfully, NO otherwise
 */
- (BOOL)stop:(NSError **)error;

@end

/*!
 The CRAudioWriter protocol defines that a class can record audio. 
 
 @see CRVideoWriter
 */
@protocol CRAudioWriter <NSObject>
/*!
 Append audio sample buffer.
 @param sampleBuffer Audio sample buffer
 */
- (BOOL)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end
