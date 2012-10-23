//
//  CRCameraRecorder.m
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/13/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//
//  Licensed under the Cocoa Controls commercial license agreement, v1, included
//  with the original package and can also be found at:
//  <http://CocoaControls.com/licenses/v1/license.pdf>.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "CRCameraRecorder.h"
#import "CRDefines.h"

@implementation CRCameraRecorder

- (id)init {
  if ((self = [super init])) {
    self.presentationTime = kCMTimeNegativeInfinity;
  }
  return self;
}

- (void)dealloc {
  [self close];
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
  
  [videoCaptureDevice lockForConfiguration:nil];
  if ([videoCaptureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
    videoCaptureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
  
  if ([videoCaptureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
    videoCaptureDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
  
  if ([videoCaptureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
    videoCaptureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
  [videoCaptureDevice unlockForConfiguration];
  
  AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:error];
  if (!videoInput) return NO;
  
  [_captureSession setSessionPreset:AVCaptureSessionPresetLow]; // AVCaptureSessionPresetMedium
  [_captureSession addInput:videoInput];
  
  AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
  if (audioCaptureDevice) {
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:error];
    if (!audioInput) return NO;
    CRDebug(@"Adding audio input: %@", audioInput);
    [_captureSession addInput:audioInput];
  }
  
  _queue = dispatch_queue_create("rel.me.Cap", NULL);
  
  // Video capture
  _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
  _videoOutput.alwaysDiscardsLateVideoFrames = YES;
  _videoOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                nil];
  [_videoOutput setSampleBufferDelegate:self queue:_queue];
  AVCaptureConnection *videoOutputConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];  
  if (videoOutputConnection.isVideoMinFrameDurationSupported) {
    videoOutputConnection.videoMinFrameDuration = CMTimeMake(1, 15);
  }
  if (videoOutputConnection.isVideoMaxFrameDurationSupported) {
    videoOutputConnection.videoMaxFrameDuration = CMTimeMake(1, 30);
  }
  
  if (![_captureSession canAddOutput:_videoOutput]) {
    CRSetError(error, 0, @"Can't add video output: %@", _videoOutput);
    return NO;
  }
  
  [_captureSession addOutput:_videoOutput];
  
  // Audio capture
  _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
  [_audioOutput setSampleBufferDelegate:self queue:_queue];
  [_captureSession addOutput:_audioOutput];
  
  CRDebug(@"Starting capture session...");
  [_captureSession startRunning];
  CRDebug(@"Started capture session");
  return YES;
}

- (BOOL)stop:(NSError **)error {
  return [self close];
}

- (BOOL)close {
  if (!_captureSession) return NO;
  CRDebug(@"Closing capture session");
  [_captureSession stopRunning];
  
  // Wait until it stops
  NSUInteger i = 0;
  while (_captureSession.isRunning) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    if (i++ > 100) {
      CRWarn(@"Timed out waiting for capture session to close");
      break;
    }
  }
  
  [_captureSession removeOutput:_videoOutput];
  [_captureSession removeOutput:_audioOutput];
  _captureSession = nil;
  dispatch_release(_queue);
  _queue = nil;
  self.presentationTime = kCMTimeNegativeInfinity;
  
  //_videoOutput.sampleBufferDelegate = nil;
  _videoOutput = nil;
  _audioOutput = nil;
  
  free(_data);
  _data = NULL;
  _dataSize = 0;
  CRDebug(@"Closed capture session");
  return YES;
}

- (void)renderInContext:(CGContextRef)context videoSize:(CGSize)videoSize {
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
  CGContextSaveGState(context);
  CGContextTranslateCTM(context, 0, 480);
  CGContextRotateCTM(context, -M_PI/2.0);
  CGContextDrawImage(context, CGRectMake(0, 0, 480, 320), image);
  CGContextRestoreGState(context);
  CGImageRelease(image);
  CGDataProviderRelease(dataProvider);
}

- (CGSize)size {
  return CGSizeMake(320, 480);
}

#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
  
  if (captureOutput == _audioOutput) {
    [self.audioWriter appendSampleBuffer:sampleBuffer];
    return;
  }

  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  if (imageBuffer == NULL) return;
  
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
  self.presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
  
  CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
}

@end
