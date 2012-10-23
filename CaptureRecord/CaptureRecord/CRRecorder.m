//
//  CRRecorder.m
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/21/12.
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

#import "CRRecorder.h"
#import "CRUIViewRecorder.h"
#import "CRScreenRecorder.h"
#import "CRCameraRecorder.h"
#import "CRUtils.h"
#import "CRUIWindow.h"

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
