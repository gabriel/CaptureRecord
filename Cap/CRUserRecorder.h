//
//  CRUserRecorder.h
//  Cap
//
//  Created by Gabriel Handford on 8/13/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRRecordable.h"

@interface CRUserRecorder : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, CRRecordable> {
  AVCaptureSession *_captureSession;
  AVCaptureVideoDataOutput *_videoOutput;
  AVCaptureAudioDataOutput *_audioOutput;
    
  uint8_t *_data; // Data from camera
  size_t _dataSize;
  size_t _width;
  size_t _height;
  size_t _bytesPerRow;
  
  CVImageBufferRef _imageBuffer;
  
  dispatch_queue_t _queue;
}

@property (weak) id<CRAudioWriter> audioWriter;
@property CMTime presentationTime;

@end
