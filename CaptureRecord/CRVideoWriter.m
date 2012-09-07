//
//  CRVideoWriter.m
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/13/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import "CRVideoWriter.h"
#import "CRRecorder.h"
#import "CRUtils.h"

@implementation CRVideoWriter

@synthesize event=_event;

- (id)initWithRecordables:(NSArray */*of id<CRRecordable>*/)recordables options:(CRRecorderOptions)options {
  if ((self = [super init])) {
    _recordables = [recordables mutableCopy];
    _options = options;

    if (!_recordables) _recordables = [NSMutableArray array];
    
    if ((_options & CRRecorderOptionUserRecording) == CRRecorderOptionUserRecording) {
#if !TARGET_IPHONE_SIMULATOR
      _userRecorder = [[CRCameraRecorder alloc] init];
      _userRecorder.audioWriter = self;
      [_recordables addObject:_userRecorder];
#endif
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
  [self _stopTimer];
  if ([self isRecording]) [self stop:nil];
  _userRecorder.audioWriter = nil;
  if (_data) free(_data);
}

- (BOOL)isRecording {
  return !!_writer;
}

- (BOOL)start:(NSError **)error {
  if (_writer) {
    CRSetError(error, CRErrorCodeInvalidState, @"Already started recording.");
    return NO;
  }

  _startTime = 0;
  _previousPresentationTime = kCMTimeNegativeInfinity;
  _video = [[CRVideo alloc] init];
  NSURL *recordingFileURL = [_video recordingFileURL:error];
  if (!recordingFileURL) {
    return NO;
  }
  _writer = [[AVAssetWriter alloc] initWithURL:recordingFileURL fileType:AVFileTypeMPEG4 error:error];
  if (!_writer) {
    return NO;
  }
  [_video start];

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
  
  dispatch_queue_t global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
  _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, global);
  uint64_t interval = 0.001 * NSEC_PER_SEC;
  uint64_t leeway = 0.001 * NSEC_PER_SEC;
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
    _timer = nil;
  }
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
  
  BOOL success = NO;

  if (_writer.status != AVAssetWriterStatusUnknown) {
    [_writerInput markAsFinished];
    [_audioWriterInput markAsFinished];
    _writerInput = nil;
    _audioWriterInput = nil;
    if (_pixelBuffer) {
      CVPixelBufferRelease(_pixelBuffer);
      _pixelBuffer = nil;
    }  
    _bufferAdapter = nil;
    
    CRDebug(@"Waiting to mark finished");
    NSUInteger i = 0;
    while (_writer.status == AVAssetWriterStatusUnknown) {
      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
      if (i++ > 100) {
        CRWarn(@"Timed out waiting for writer to finish");
        break;
      }
    }
    
    CRDebug(@"Finishing");
    success = [_writer finishWriting];
    if (!success) {
      CRSetError(error, 0, @"Error finishing writing");
    }
  }
    
  if (_writer.error) {
    CRWarn(@"Writer error: %@", _writer.error);
  }
  
  [_video stopWithPresentationTime:_previousPresentationTime];
  _started = NO;
  _writer = nil;
  CRDebug(@"Finished");

  return success;
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
    [_video startSessionWithPresentationTime:time];
  }
  
  if (![_writerInput isReadyForMoreMediaData]) {
    CRDebug(@"Not ready for more data (video)");
    return NO;
  }
  
  if (!_pixelBuffer) {
    CVReturn status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, _bufferAdapter.pixelBufferPool, &_pixelBuffer);
    if (status != kCVReturnSuccess) {
      if (_writer.error) {
        if (error) *error = _writer.error;
        CRWarn(@"Error creating pixel buffer: %@", _writer.error);
      } else {
        CRSetError(error, 0, @"Error creating pixel buffer");
      }
      return NO;
    }
  }
  CVPixelBufferLockBaseAddress(_pixelBuffer, 0);
  uint8_t *pixels = CVPixelBufferGetBaseAddress(_pixelBuffer);
  CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(image));
  CFDataGetBytes(imageData, CFRangeMake(0, CFDataGetLength(imageData)), pixels);
  
  if (_bufferAdapter && ![_bufferAdapter appendPixelBuffer:_pixelBuffer withPresentationTime:time]) {
    if (_writer.error) {
      if (error) *error = _writer.error;
      CRWarn(@"Error appending pixel buffer: %@", _writer.error);
    } else {
      CRSetError(error, 0, @"Error appending pixel buffer");
    }
    return NO;
  }
  
  CVPixelBufferUnlockBaseAddress(_pixelBuffer, 0);
  CFRelease(imageData);
  return YES;
}

- (void)renderEvent:(UIEvent *)event context:(CGContextRef)context {
  //CGContextSetAllowsAntialiasing(context, YES);

  CGSize touchSize = CGSizeMake(40, 40);
  if (event) {
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.5 alpha:0.5].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0 alpha:0].CGColor);
    CGContextSetLineWidth(context, 2.0);
    if (event.type == UIEventTypeTouches) {
      for (UITouch *touch in [event allTouches]) {
        switch (touch.phase) {
          case UITouchPhaseBegan:
          case UITouchPhaseMoved:
          case UITouchPhaseStationary: {
            CGPoint p = [touch locationInView:touch.window];
            CGRect rect = CGRectMake(-touchSize.width/2.0f + p.x, -touchSize.height/2.0f + p.y, touchSize.width, touchSize.height);
            CGContextFillEllipseInRect(context, rect);
            CGContextStrokeEllipseInRect(context, rect);
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

- (double)_millisEllapsed {
  NSTimeInterval secondsElapsed = [NSDate timeIntervalSinceReferenceDate] - _startTime;
  return secondsElapsed * 1000.0;
}

- (BOOL)render:(NSError **)error {
  if (_startTime == 0) {
    _startTime = [NSDate timeIntervalSinceReferenceDate];
  }

  static CGColorSpaceRef ColorSpace = NULL;
  if (ColorSpace == NULL) ColorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(_data, _videoSize.width, _videoSize.height, 8, _bytesPerRow, ColorSpace, kCGImageAlphaNoneSkipFirst);
  CGContextSetAllowsAntialiasing(context, NO);
  
  CGFloat width = 0;
  for (id<CRRecordable> recordable in _recordables) {
    [recordable renderInContext:context];
    width += [recordable size].width;
    CGContextTranslateCTM(context, [recordable size].width, 0);
  }
  // Translate back to 0
  CGContextTranslateCTM(context, -width, 0);
  
  // Render touches
  if ((_options & CRRecorderOptionTouchRecording) == CRRecorderOptionTouchRecording) {
    if (self.event) [self renderEvent:self.event context:context];
  }
  
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
    time = CMTimeMake([self _millisEllapsed], 1000);
  }
    
  if ([NSDate timeIntervalSinceReferenceDate] - _fpsTimeStart > 1.0) {
    if (_fps > 0) CRDebug(@"FPS: %d", _fps);
    _fpsTimeStart = [NSDate timeIntervalSinceReferenceDate];
    _fps = 0;
  }
  
  CRDebug(@"Rendering frame: %0.2f", (double)time.value/(double)time.timescale);
  BOOL success = NO;
  if (CMTimeCompare(_previousPresentationTime, time) >= 0) {
    CRDebug(@"Presentation time unchanged, skipping");
  } else {
    _fps++;
    _previousPresentationTime = time;
    success = [self writeVideoFrameAtTime:time image:image error:error];
    if (!success) {
      CRWarn(@"Error rendering video frame: %@", (error ? *error : nil));
    }
  }
  CGImageRelease(image);
  return success;
}

#pragma mark Asset Library

- (void)saveToAlbumWithName:(NSString *)name resultBlock:(CRRecorderSaveResultBlock)resultBlock failureBlock:(CRRecorderSaveFailureBlock)failureBlock {
  if (!_video) {
    if (failureBlock) failureBlock([CRUtils cr_errorWithDomain:CRErrorDomain code:CRErrorCodeInvalidVideo localizedDescription:@"No video available to save."]);
    return;
  }
  
  CRDebug(@"Saving to album");
  [_video saveToAlbumWithName:name resultBlock:resultBlock failureBlock:failureBlock];
}

- (BOOL)discard:(NSError **)error {
  if (!_video) {
    return YES;
  }

  if ([_video discard:error]) {
    _video = nil;
    return YES;
  }
  return NO;
}

@end
