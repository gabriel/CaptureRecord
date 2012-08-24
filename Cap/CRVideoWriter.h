//
//  CRVideoWriter.h
//  Cap
//
//  Created by Gabriel Handford on 8/13/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRRecordable.h"

@interface CRVideoWriter : NSObject <CRWriter> {
  AVAssetWriter *_writer;
  AVAssetWriterInput *_writerInput;
  AVAssetWriterInputPixelBufferAdaptor *_bufferAdapter;
  
  NSURL *_fileURL;
  
  dispatch_source_t _timer;
  
  NSTimeInterval _startTime;
  
  UIEvent *_event;
  
  NSArray *_recordables;
  CGSize _videoSize;
  
  size_t _bytesPerRow;
  uint8_t *_data;
}

@property (readonly, nonatomic) NSURL *fileURL;

- (id)initWithRecordables:(NSArray */*of id<CRRecordable>*/)recordables;

- (BOOL)start:(NSError **)error;

- (BOOL)isStarted;

- (BOOL)stop:(NSError **)error;

@end
