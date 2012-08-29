//
//  CRVideoWriter.h
//  Cap
//
//  Created by Gabriel Handford on 8/13/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRRecordable.h"
#import "CRUserRecorder.h"

/*!
 Video writer records a video from a list of recordables.
 */
@interface CRVideoWriter : NSObject <CRWriter, CRAudioWriter> {
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
  
  NSURL *_fileURL;
  
  CRUserRecorder *_userRecorder;
  NSMutableArray *_recordables;
  CGSize _videoSize;
  
  size_t _bytesPerRow;
  uint8_t *_data;
}

/*!
 Create video writer with recordables.
 @param recordables Recordables
 @param options Options
 */
- (id)initWithRecordables:(NSArray */*of id<CRRecordable>*/)recordables options:(CRRecorderOptions)options;

/*!
 Start the video writer.
 @param error Out error
 @result YES if started succesfully, NO otherwise
 */
- (BOOL)start:(NSError **)error;

/*!
 @result YES if started and running, NO otherwise
 */
- (BOOL)isRunning;

/*!
 Stop the video writer.
 @param error Out error
 */
- (BOOL)stop:(NSError **)error;

/*!
 Save the video to the album with name.
 If the album doesn't exist, it is created.
 
 The video is also saved to the camera roll.
 
 @param name Album name
 @param resultBlock After successfully saving the video
 @param failureBlock If there is a failure
 */
- (void)saveToAlbumWithName:(NSString *)name resultBlock:(CRRecorderSaveResultBlock)resultBlock failureBlock:(CRRecorderSaveFailureBlock)failureBlock;

@end
