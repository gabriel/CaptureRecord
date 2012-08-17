//
//  CRVideoRecorder.m
//  Cap
//
//  Created by Gabriel Handford on 8/13/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRVideoRecorder.h"

@implementation CRVideoRecorder

@synthesize fileURL=_fileURL;

- (id)initWithRecordables:(NSArray */*of id<CRRecordable>*/)recordables {
  if ((self = [super init])) {
    _recordables = recordables;
    
    _videoSize = CGSizeZero;
    for (id<CRRecordable> recordable in recordables) {
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
  if (_data) free(_data);
}

- (BOOL)start:(NSError **)error {
  if (_writer) {
    CRSetError(error, 0, @"Already started");
    return NO;
  }
  
  NSString *tempFile = [NSFileManager gh_temporaryFile:@"output.m4v" deleteIfExists:YES error:error];
  if (!tempFile) {
    CRSetError(error, 0, @"Can't create temp file");
    return NO;
  }
  
  CRDebug(@"File: %@", tempFile);
  
  _fileURL = [NSURL fileURLWithPath:tempFile];
  _writer = [[AVAssetWriter alloc] initWithURL:_fileURL fileType:AVFileTypeAppleM4V error:error];
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
  [_writer startWriting];
  [_writer startSessionAtSourceTime:CMTimeMake(0, 1000)];
  _startTime = [NSDate timeIntervalSinceReferenceDate];
  
  for (id<CRRecordable> recordable in _recordables) {
    if ([recordable respondsToSelector:@selector(start:)]) {
      [recordable start:nil];
    }
  }

  [self _startTimer];
  return YES;
}

- (void)_startTimer {
  _timer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(_render) userInfo:nil repeats:YES];
  // So timer fires while scrolling
  [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
  [_timer fire];
}

- (void)_render {
  [self render:nil];
}

- (void)_stopTimer {
  [_timer invalidate];
  _timer = nil;
}

- (BOOL)stop:(NSError **)error {
  CRDebug(@"Stopping");
  [self _stopTimer];
  [_writerInput markAsFinished];
  
  for (id<CRRecordable> recordable in _recordables) {
    if ([recordable respondsToSelector:@selector(stop:)]) {
      [recordable stop:nil];
    }
  }

  int status = _writer.status;
  CRDebug(@"Waiting to mark finished");
  while (status == AVAssetWriterStatusUnknown) {
    [NSThread sleepForTimeInterval:0.1f];
    status = _writer.status;
  }
  
  CRDebug(@"Finishing");
  BOOL success = [_writer finishWriting];
  if (!success) {
    CRSetError(error, 0, @"Error finishing writing");
    return NO;
  }
  
  CRDebug(@"Finished");
    
  _bufferAdapter = nil;
  _writerInput = nil;
  _writer = nil;
  return YES;
}

- (BOOL)writeVideoFrameAtTime:(CMTime)time image:(CGImageRef)image error:(NSError **)error {
  if (![_writerInput isReadyForMoreMediaData]) {
    CRDebug(@"Not ready for more data");
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
  
  if (![_bufferAdapter appendPixelBuffer:pixelBuffer withPresentationTime:time]) {
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

- (BOOL)render:(NSError **)error {
  NSTimeInterval secondsElapsed = [NSDate timeIntervalSinceReferenceDate] - _startTime;
  int64_t millisElapsed = (int64_t)(secondsElapsed * 1000.0);
  CRDebug(@"Rendering frame: %0.2f", secondsElapsed);
  
  CGContextRef context = [self _createBitmapContext];
  
  for (id<CRRecordable> recordable in _recordables) {
    [recordable renderInContext:context];
    CGContextTranslateCTM(context, [recordable size].width, 0);
  }
  CGImageRef image = CGBitmapContextCreateImage(context);
  CGContextRelease(context);
  
  BOOL success = [self writeVideoFrameAtTime:CMTimeMake(millisElapsed, 1000) image:image error:error];
  CGImageRelease(image);
  return success;
}

@end
