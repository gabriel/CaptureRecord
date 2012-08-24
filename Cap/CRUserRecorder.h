//
//  CRUserRecorder.h
//  Cap
//
//  Created by Gabriel Handford on 8/13/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRRecordable.h"

@interface CRUserRecorder : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, CRRecordable> {
  AVCaptureSession *_captureSession;
  AVCaptureVideoDataOutput *_videoOutput;
    
  uint8_t *_data; // Data from camera
  size_t _dataSize;
  size_t _width;
  size_t _height;
  size_t _bytesPerRow;
  
  CVImageBufferRef _imageBuffer;
  
  dispatch_queue_t _queue;
}

@end
