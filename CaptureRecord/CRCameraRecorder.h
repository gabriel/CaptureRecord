//
//  CRCameraRecorder.h
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/13/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import "CRRecordable.h"
#import <AVFoundation/AVFoundation.h>

@interface CRCameraRecorder : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, CRRecordable> {
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
