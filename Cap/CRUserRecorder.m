//
//  CRUserRecorder.m
//  Cap
//
//  Created by Gabriel Handford on 8/13/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRUserRecorder.h"

@implementation CRUserRecorder

- (void)dealloc {
  [self close];
}

- (void)_setupVideoDevice:(AVCaptureDevice *)videoCaptureDevice {
  [videoCaptureDevice lockForConfiguration:nil];
  if ([videoCaptureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
    videoCaptureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
  
  if ([videoCaptureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
    videoCaptureDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
  
  if ([videoCaptureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
    videoCaptureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
  [videoCaptureDevice unlockForConfiguration];
}

- (BOOL)start:(NSError **)error {
  if (_captureSession) {
    CRSetError(error, 0, @"Capture session already started");
    return NO;
  }
  
  _captureSession = [[AVCaptureSession alloc] init];
  NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  
  //AVCaptureDevice *videoCaptureDevice = [devices gh_firstObject]; // For back camera
  AVCaptureDevice *videoCaptureDevice = [devices lastObject]; // For front camera
  if (!videoCaptureDevice) return NO;
  [self _setupVideoDevice:videoCaptureDevice];
  
  AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:error];
  if (!videoInput) return NO;
  
  [_captureSession setSessionPreset:AVCaptureSessionPresetLow]; // AVCaptureSessionPresetMedium
  [_captureSession addInput:videoInput];
  
  NSArray *audioCaptureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
  if ([audioCaptureDevices count] > 0) {
    AVCaptureDevice *audioCaptureDevice = [audioCaptureDevices objectAtIndex:0];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:error];
    if (!audioInput) return NO;
    [_captureSession addInput:audioInput];
  }
  
  _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
  _videoOutput.alwaysDiscardsLateVideoFrames = YES;
  //_videoOutput.minFrameDuration = CMTimeMake(1, 15);
  _videoOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                nil];
  
  _queue = dispatch_queue_create("rel.me.Cap", NULL);
  [_videoOutput setSampleBufferDelegate:self queue:_queue];
  
  if (![_captureSession canAddOutput:_videoOutput]) {
    CRSetError(error, 0, @"Can't add video output: %@", _videoOutput);
    return NO;
  }
  
  [_captureSession addOutput:_videoOutput];
  CRDebug(@"Starting capture session...");
  [_captureSession startRunning];
  CRDebug(@"Started capture session");
  return YES;
}

- (void)close {
  if (!_captureSession) return;
  CRDebug(@"Closing capture session");
  [_captureSession stopRunning];
  
  // Wait until it stops
  if (_captureSession.isRunning) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }
  
  _captureSession = nil;
  
  dispatch_release(_queue);
  
  //_videoOutput.sampleBufferDelegate = nil;
  _videoOutput = nil;
  
  free(_data);
  _data = NULL;
  _dataSize = 0;
  CRDebug(@"Closed capture session");
}

- (void)renderInContext:(CGContextRef)context {
  if (_data == NULL) {
    // For testing
    //UIImage *image = [UIImage imageNamed:@"test2.png"];
    //CGContextDrawImage(context, CGRectMake(0, 0, 320, 480), image.CGImage);
    return;
  }
  
  static CGColorSpaceRef ColorSpace = NULL;
  if (ColorSpace == NULL) ColorSpace = CGColorSpaceCreateDeviceRGB();
  
  CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, _data, _dataSize, NULL);
  CGImageRef image = CGImageCreate(_width, _height, 8, 32, _bytesPerRow, ColorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
  CGContextDrawImage(context, CGRectMake(0, 0, 320, 480), image);
  CGImageRelease(image);
  CGDataProviderRelease(dataProvider);
}

- (CGSize)size {
  return CGSizeMake(320, 480);
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  if (imageBuffer == NULL) {
    // TODO: Capture audio
    return;
  }
  
  CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
  
  
  uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
  size_t dataSize = CVPixelBufferGetDataSize(imageBuffer);
  
  _bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
  _width = CVPixelBufferGetWidth(imageBuffer);
  _height = CVPixelBufferGetHeight(imageBuffer);

  if (_data == NULL || dataSize != _dataSize) {
    CRDebug(@"Allocating video data of size: %ld", dataSize);
    if (_data != NULL) free(_data);
    _data = calloc(1, dataSize);
    _dataSize = dataSize;
  }
  
  memcpy(_data, baseAddress, _dataSize); 
  
  CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
}

@end
