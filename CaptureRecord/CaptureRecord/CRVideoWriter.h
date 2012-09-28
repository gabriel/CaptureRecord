//
//  CRVideoWriter.h
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/13/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import "CRDefines.h"
#import "CRRecordable.h"
#import "CRCameraRecorder.h"
#import "CRVideo.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

/*!
 Video writer records a video from a list of recordables.
 */
@interface CRVideoWriter : NSObject <CRAudioWriter> {
  AVAssetWriter *_writer;
  AVAssetWriterInput *_writerInput;
  AVAssetWriterInputPixelBufferAdaptor *_bufferAdapter;
  
  CVPixelBufferRef _pixelBuffer;
  
  AVAssetWriterInput *_audioWriterInput;
  
  dispatch_source_t _timer;
  
  CRRecorderOptions _options;
  
  NSTimeInterval _startTime;
  CMTime _previousPresentationTime;
  BOOL _started;
  
  CRCameraRecorder *_userRecorder;
  NSMutableArray *_recordables;
  CGSize _videoSize;
  
  size_t _bytesPerRow;
  uint8_t *_data;
  
  NSUInteger _fps;
  NSTimeInterval _fpsTimeStart;
  
  UIEvent *_event;
  NSMutableArray *_touches;
}

@property (readonly, strong) CRVideo *video;


/*!
 Create video writer with recordables.
 @param recordable Recordable
 @param options Options
 */
- (id)initWithRecordable:(id<CRRecordable>)recordable options:(CRRecorderOptions)options;

/*!
 Start the video writer.
 @param error Out error
 @result YES if started succesfully, NO otherwise
 */
- (BOOL)start:(NSError **)error;

/*!
 @result YES if recording, NO otherwise
 */
- (BOOL)isRecording;

/*!
 Stop the video writer.
 @param error Out error
 */
- (BOOL)stop:(NSError **)error;

/*!
 Set event.
 @param event Event
 */
- (void)setEvent:(UIEvent *)event;

/*!
 Save the video to the album with name.
 If the album doesn't exist, it is created.
 
 The video is also saved to the camera roll.
 
 @param name Album name
 @param resultBlock After successfully saving the video
 @param failureBlock If there is a failure
 */
- (void)saveToAlbumWithName:(NSString *)name resultBlock:(CRRecorderSaveResultBlock)resultBlock failureBlock:(CRRecorderSaveFailureBlock)failureBlock;

/*!
 Discard the video.
 @param error Out error
 @result YES if discarded or didn't exist, NO if there was an error
 */
- (BOOL)discard:(NSError **)error;

@end
