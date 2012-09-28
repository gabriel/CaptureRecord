//
//  CRRecorder.m
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/21/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import "CRRecorder.h"
#import "CRUIViewRecorder.h"
#import "CRScreenRecorder.h"
#import "CRCameraRecorder.h"
#import "CRUtils.h"
#import "CRUIWindow.h"

#define UNREGISTERED_MAX_TIME_INTERVAL (30)

@interface CRRecorder ()
@property (strong) NSString *registeredName;
@end

@implementation CRRecorder

- (id)init {
  if ((self = [super init])) {
    _options = CRRecorderOptionUserCameraRecording|CRRecorderOptionUserAudioRecording|CRRecorderOptionTouchRecording;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onEvent:) name:CRUIEventNotification object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (CRRecorder *)sharedRecorder {
  static dispatch_once_t once;
  static id sharedInstance;
  dispatch_once(&once, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (BOOL)registerWithName:(NSString *)name code:(NSString *)code {
  if (!name || [name isEqualToString:@""]) return NO;  

  NSString *generated = [CRUtils cr_HMACSHA1WithMessage:name secret:@"$1$pdQG$7/HJofRWeRHSn9vctZR7C0"];
  code = [code stringByReplacingOccurrencesOfString:@"=" withString:@""];
  generated = [generated stringByReplacingOccurrencesOfString:@"=" withString:@""];
  if ([generated isEqualToString:code]) {
    self.registeredName = name;
  }
  CRDebug(@"Generated: %@, Registered: %@", generated, self.registeredName);
  return !!self.registeredName;
}

- (void)setOptions:(CRRecorderOptions)options {
  if (self.isRecording) [NSException raise:CRException format:@"You can't set recording options while recording is in progress."];
  _options = options;
}

- (BOOL)isRecording {
  return (_videoWriter && _videoWriter.isRecording);
}

- (void)_alert:(NSString *)message {
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alertView show];
}

- (BOOL)start:(NSError **)error {
  if ([self.registeredName isEqualToString:@"Test"] && [[NSDate date] timeIntervalSince1970] > 1354052338) {
    [self _alert:@"This beta version has expired"];
    return NO;
  }
  
  if ([[CRUtils machine] hasPrefix:@"iPhone5"] && [UIScreen mainScreen].bounds.size.height <= 480) {
    [self _alert:@"Recording only works with full size app on iPhone 5."];
    return NO;
  }
  
#if TARGET_IPHONE_SIMULATOR
  UIWindow *window = [CRUIWindow window];
  if (!window) {
    [NSException raise:CRException format:@"No window for recording has been setup. This probably means you are using the simulator and no CRUIWindow has been constructed. See documentation for help on setting up the CRUIWindow."];
  }
  CRUIViewRecorder *viewRecoder = [[CRUIViewRecorder alloc] initWithView:window size:window.frame.size];
#else
  CRScreenRecorder *viewRecoder = [[CRScreenRecorder alloc] init];
#endif
    
  _videoWriter = [[CRVideoWriter alloc] initWithRecordable:viewRecoder options:_options];
  
  if (!self.registeredName) {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_stopForUnregistered) object:nil];
    [self performSelector:@selector(_stopForUnregistered) withObject:nil afterDelay:UNREGISTERED_MAX_TIME_INTERVAL];
  }
  
  if ([_videoWriter start:error]) {
    [[NSNotificationCenter defaultCenter] postNotificationName:CRRecorderDidStartNotification object:self];
    return YES;
  }
  return NO;
}

- (void)_stopForUnregistered {
  [self stop:nil];
}

- (BOOL)stop:(NSError **)error {
  BOOL stopped = [_videoWriter stop:error];
  [[NSNotificationCenter defaultCenter] postNotificationName:CRRecorderDidStopNotification object:self];
  return stopped;
}

- (void)saveVideoToAlbumWithResultBlock:(CRRecorderSaveResultBlock)resultBlock failureBlock:(CRRecorderSaveFailureBlock)failureBlock {
  return [_videoWriter saveToAlbumWithName:_albumName resultBlock:resultBlock failureBlock:failureBlock];
}

- (void)saveVideoToAlbumWithName:(NSString *)name resultBlock:(CRRecorderSaveResultBlock)resultBlock failureBlock:(CRRecorderSaveFailureBlock)failureBlock {
  return [_videoWriter saveToAlbumWithName:name resultBlock:resultBlock failureBlock:failureBlock];
}

- (BOOL)discardVideo:(NSError **)error {
  return [_videoWriter discard:error];
}

#pragma mark Delegates (CRUIWindow)

- (void)_onEvent:(NSNotification *)notification {
  UIEvent *event = [notification object];
  if ([_videoWriter isRecording]) {
    //[_eventRecorder recordEvent:event];
    [_videoWriter setEvent:event];
  }
}

@end
