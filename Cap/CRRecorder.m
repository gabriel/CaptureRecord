//
//  CRRecorder.m
//  Cap
//
//  Created by Gabriel Handford on 8/21/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRRecorder.h"
#import "CRUIViewRecorder.h"
#import "CRScreenRecorder.h"
#import "CRUserRecorder.h"

@implementation CRRecorder

- (id)initWithWindow:(CRUIWindow *)window {
  if ((self = [super init])) {
#if TARGET_IPHONE_SIMULATOR
    CRUIViewRecorder *viewRecoder = [[CRUIViewRecorder alloc] initWithView:window size:window.frame.size];
#else
    CRScreenRecorder *viewRecoder = [[CRScreenRecorder alloc] init];
#endif
    _videoWriter = [[CRVideoWriter alloc] initWithRecordables:[NSArray arrayWithObjects:viewRecoder, nil] isUserRecordingEnabled:YES];
    
    _window = window;
    _window.eventDelegate = self;
    
    _eventRecorder = [[CRUIEventRecorder alloc] init];
  }
  return self;
}

- (void)dealloc {
  _window.eventDelegate = nil;
}

- (void)window:(CRUIWindow *)window didSendEvent:(UIEvent *)event {
  if (_videoWriter.isStarted) {
    [_eventRecorder recordEvent:event];
    _videoWriter.event = event;
  }
}

- (BOOL)start:(NSError **)error {
  return [_videoWriter start:error];
}

- (BOOL)stop:(NSError **)error {
  return [_videoWriter stop:error];
}

- (NSURL *)fileURL {
  return [_videoWriter fileURL];
}

@end
