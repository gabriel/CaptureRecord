//
//  CRVideoWriter.m
//  Cap
//
//  Created by Gabriel Handford on 8/13/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRVideoWriter.h"

@implementation CRVideoWriter

@synthesize fileURL=_fileURL, event=_event;

- (id)initWithRecordables:(NSArray */*of id<CRRecordable>*/)recordables isUserRecordingEnabled:(BOOL)isUserRecordingEnabled {
  if ((self = [super init])) {
    _recordables = [recordables mutableCopy];

    if (!_recordables) _recordables = [NSMutableArray array];
    
    if (isUserRecordingEnabled) {
      _userRecorder = [[CRUserRecorder alloc] init];
      _userRecorder.audioWriter = self;
      [_recordables addObject:_userRecorder];
    }

    _videoSize = CGSizeZero;
    for (id<CRRecordable> recordable in _recordables) {
      CGSize size = [recordable size];
      _videoSize.width += size.width;
      if (size.height > _videoSize.height) _videoSize.height = size.height;
    }
    
    _bytesPerRow = (_videoSize.width * 4);
    size_t byteCount = (_bytesPerRow * _videoSize.height);
    _data = malloc(byteCount);

  }
  return self;
}

- (void)dealloc {
  if ([self isRunning]) [self stop:nil];
  _userRecorder.audioWriter = nil;
  [self _stopTimer];
  if (_data) free(_data);
}

- (BOOL)isStarted {
  return !!_writer;
}

- (BOOL)start:(NSError **)error {
  if (_writer) {
    CRSetError(error, 0, @"Already started");
    return NO;
  }
  
  NSString *tempFile = [NSFileManager gh_temporaryFile:@"output.mp4" deleteIfExists:YES error:error];
  if (!tempFile) {
    CRSetError(error, 0, @"Can't create temp file");
    return NO;
  }
  
  CRDebug(@"File: %@", tempFile);
  
  _fileURL = [NSURL fileURLWithPath:tempFile];
  _writer = [[AVAssetWriter alloc] initWithURL:_fileURL fileType:AVFileTypeMPEG4 error:error];
  if (!_writer) return NO;

  NSDictionary *videoCompressionProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithDouble:1024.0 * 1024.0], AVVideoAverageBitRateKey,
                                              nil];
  
  NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                 AVVideoCodecH264, AVVideoCodecKey,
                                 [NSNumber numberWithInt:_videoSize.width], AVVideoWidthKey,
                                 [NSNumber numberWithInt:_videoSize.height], AVVideoHeightKey,
                                 videoCompressionProperties, AVVideoCompressionPropertiesKey,
                                 nil];
  
  _writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
  if (!_writerInput) {
    CRSetError(error, 0, @"Error with writer input");
    return NO;
  }
  
  _writerInput.expectsMediaDataInRealTime = YES;
  NSDictionary *bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
  
  _bufferAdapter = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_writerInput sourcePixelBufferAttributes:bufferAttributes];
  
  [_writer addInput:_writerInput];
  
  // Add the audio input
  AudioChannelLayout acl;
  bzero(&acl, sizeof(acl));
  acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    
  /*
  double preferredHardwareSampleRate = [[AVAudioSession sharedInstance] currentHardwareSampleRate];
  NSDictionary *audioOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                       [NSNumber numberWithDouble:preferredHardwareSampleRate], AVSampleRateKey,
                                       [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                       [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                       [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                       [NSData dataWithBytes:&acl length:sizeof(acl)], AVChannelLayoutKey,
                                       nil];
   */

  /*
  NSDictionary *audioOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:kAudioFormatiLBC], AVFormatIDKey,
                                       [NSNumber numberWithInt:12000], AVSampleRateKey,
                                       [NSNumber numberWithInt:12000], AVEncoderBitRateKey,
                                       [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                       [NSData dataWithBytes:&acl length:sizeof(acl)], AVChannelLayoutKey,
                                       nil];
  */

  NSDictionary *audioOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                       [NSNumber numberWithInt:12000], AVSampleRateKey,
                                       [NSNumber numberWithInt:12000], AVEncoderBitRateKey,
                                       //[NSNumber numberWithInt:AVAudioQualityLow], AVEncoderAudioQualityKey,
                                       [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                       [NSData dataWithBytes:&acl length:sizeof(acl)], AVChannelLayoutKey,
                                       nil];

  _audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioOutputSettings];
  _audioWriterInput.expectsMediaDataInRealTime = YES;
  [_writer addInput:_audioWriterInput];
  
  for (id<CRRecordable> recordable in _recordables) {
    if ([recordable respondsToSelector:@selector(start:)]) {
      [recordable start:nil];
    }
  }

  [self _startTimer];
  return YES;
}

- (void)_startTimer {
  if (_timer != NULL) return;
  
  dispatch_queue_t global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, global);
  uint64_t interval = 0.05 * NSEC_PER_SEC; // 16ms
  uint64_t leeway = 0.1 * NSEC_PER_SEC;
  dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), interval, leeway);
  __block id blockSelf = self;
  dispatch_source_set_event_handler(_timer, ^() {
    [blockSelf render:nil];
  });
  dispatch_resume(_timer);
}

- (void)_render {
  [self render:nil];
}

- (void)_stopTimer {
  if (_timer) {
    dispatch_source_cancel(_timer);
    dispatch_release(_timer);
  }
  _timer = nil;
}

- (BOOL)isRunning {
  return !!_writer;
}

- (BOOL)stop:(NSError **)error {
  if (!_writer) {
    CRSetError(error, 0, @"Can't stop, its not running");
    return NO;
  }
  CRDebug(@"Stopping");
  [self _stopTimer];
  
  for (id<CRRecordable> recordable in _recordables) {
    if ([recordable respondsToSelector:@selector(stop:)]) {
      [recordable stop:nil];
    }
  }
  
  _bufferAdapter = nil;
  [_writerInput markAsFinished];
  _writerInput = nil;
  [_audioWriterInput markAsFinished];
  _audioWriterInput = nil;

  int status = _writer.status;
  CRDebug(@"Waiting to mark finished");
  NSUInteger i = 0;
  while (status == AVAssetWriterStatusUnknown) {
    [NSThread sleepForTimeInterval:0.1f];
    status = _writer.status;
    if (i++ > 100) {
      CRWarn(@"Timeout waiting for writer to finish");
      break;
    }
  }
  
  CRDebug(@"Finishing");
  BOOL success = [_writer finishWriting];
  
  if (_writer.error) {
    CRWarn(@"Writer error: %@", _writer.error);
  }
  
  if (!success) {
    CRSetError(error, 0, @"Error finishing writing");
    return NO;
  }

  _writer = nil;
  CRDebug(@"Finished");
  return YES;
}

- (BOOL)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer {
  if (!_started) return NO;

  if (![_audioWriterInput isReadyForMoreMediaData]) {
    CRDebug(@"Not ready for more data (audio)");
    return NO;
  }
  //CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
  //CRDebug(@"Audio timestamp: %0.2f", ((double)time.value * time.timescale));
  return [_audioWriterInput appendSampleBuffer:sampleBuffer];
}

- (BOOL)writeVideoFrameAtTime:(CMTime)time image:(CGImageRef)image error:(NSError **)error {
  if (!_started) {
    _started = YES;
    CRDebug(@"Starting writing");
    [_writer startWriting];
    [_writer startSessionAtSourceTime:time];
  }
  
  if (![_writerInput isReadyForMoreMediaData]) {
    CRDebug(@"Not ready for more data (video)");
    return NO;
  }
  
  CVPixelBufferRef pixelBuffer = NULL;
  CVReturn status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, _bufferAdapter.pixelBufferPool, &pixelBuffer);
  if (status != kCVReturnSuccess) {
    CRSetError(error, 0, @"Error creating pixel buffer");
    return NO;
  }
  CVPixelBufferLockBaseAddress(pixelBuffer, 0);
  uint8_t *pixels = CVPixelBufferGetBaseAddress(pixelBuffer);
  CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(image));
  CFDataGetBytes(imageData, CFRangeMake(0, CFDataGetLength(imageData)), pixels);
  
  if (_bufferAdapter && ![_bufferAdapter appendPixelBuffer:pixelBuffer withPresentationTime:time]) {
    CRSetError(error, 0, @"Error appending pixel buffer");
    return NO;
  }
  
  CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
  CVPixelBufferRelease(pixelBuffer);
  CFRelease(imageData);
  return YES;
}

- (CGContextRef)_createBitmapContext {
  static CGColorSpaceRef ColorSpace = NULL;
  if (ColorSpace == NULL) ColorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(_data, _videoSize.width, _videoSize.height, 8, _bytesPerRow, ColorSpace, kCGImageAlphaNoneSkipFirst);
  CGContextSetAllowsAntialiasing(context, NO);
  return context;
}

- (void)renderEvent:(UIEvent *)event context:(CGContextRef)context {
  CGSize touchSize = CGSizeMake(40, 40);
  if (event) {
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.5 alpha:0.5].CGColor);
    if (event.type == UIEventTypeTouches) {
      for (UITouch *touch in [event allTouches]) {
        switch (touch.phase) {
          case UITouchPhaseBegan:
          case UITouchPhaseMoved:
          case UITouchPhaseStationary: {
            CGPoint p = [touch locationInView:touch.window];
            CGContextFillEllipseInRect(context, CGRectMake(-touchSize.width/2.0f + p.x, -touchSize.height/2.0f + p.y, touchSize.width, touchSize.height));
            break;
          }
          case UITouchPhaseCancelled:
          case UITouchPhaseEnded:
            break;
        }
      }
    }
  }
}

- (int64_t)millisEllapsed {
  NSTimeInterval secondsElapsed = [NSDate timeIntervalSinceReferenceDate] - _startTime;
  return (int64_t)secondsElapsed * 1000.0;
}

- (BOOL)render:(NSError **)error {
  if (_startTime == 0) {
    _startTime = [NSDate timeIntervalSinceReferenceDate];
  }

  CGContextRef context = [self _createBitmapContext];
  
  CGFloat width = 0;
  for (id<CRRecordable> recordable in _recordables) {
    [recordable renderWithWriter:self context:context];
    width += [recordable size].width;
    CGContextTranslateCTM(context, [recordable size].width, 0);
  }
  // Translate back to 0
  CGContextTranslateCTM(context, -width, 0);
  // Render touches
  if (self.event) [self renderEvent:self.event context:context];
  
  CGImageRef image = CGBitmapContextCreateImage(context);
  CGContextRelease(context);
  
  CMTime time = kCMTimeNegativeInfinity;
  if (_userRecorder) {
    time = [_userRecorder presentationTime];
    if (CMTIME_IS_NEGATIVE_INFINITY(time)) {
      CRDebug(@"No presentation time, skipping");
      return NO;
    }
  } else {
    int64_t millisElapsed = [self millisEllapsed];
    time = CMTimeMake(millisElapsed, 1000);
  }
    
  CRDebug(@"Rendering frame: %0.2f", (double)time.value/(double)time.timescale);
  
  BOOL success = [self writeVideoFrameAtTime:time image:image error:error];
  CGImageRelease(image);
  return success;
}

@end
