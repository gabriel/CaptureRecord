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

- (id)initWithWindow:(CRUIWindow *)window options:(CRRecorderOptions)options {
  if ((self = [super init])) {
#if TARGET_IPHONE_SIMULATOR
    CRUIViewRecorder *viewRecoder = [[CRUIViewRecorder alloc] initWithView:window size:window.frame.size];
#else
    //CRScreenRecorder *viewRecoder = [[CRScreenRecorder alloc] init];
    CRUIViewRecorder *viewRecoder = [[CRUIViewRecorder alloc] initWithView:window size:window.frame.size];
#endif
    _videoWriter = [[CRVideoWriter alloc] initWithRecordables:[NSArray arrayWithObjects:viewRecoder, nil] options:options];
    
    _window = window;
    _window.eventDelegate = self;
    
    _eventRecorder = [[CRUIEventRecorder alloc] init];
  }
  return self;
}

- (void)dealloc {
  _window.eventDelegate = nil;
}

- (BOOL)start:(NSError **)error {
  return [_videoWriter start:error];
}

- (BOOL)stop:(NSError **)error {
  return [_videoWriter stop:error];
}

- (void)saveToAlbumWithResultBlock:(CRRecorderSaveResultBlock)resultBlock failureBlock:(CRRecorderSaveFailureBlock)failureBlock {
  return [_videoWriter saveToAlbumWithName:nil resultBlock:resultBlock failureBlock:failureBlock];
}

- (void)saveToAlbumWithName:(NSString *)name resultBlock:(CRRecorderSaveResultBlock)resultBlock failureBlock:(CRRecorderSaveFailureBlock)failureBlock {
  return [_videoWriter saveToAlbumWithName:name resultBlock:resultBlock failureBlock:failureBlock];
}

+ (ALAssetsLibrary *)sharedAssetsLibrary {
  static dispatch_once_t pred = 0;
  static ALAssetsLibrary *library = nil;
  dispatch_once(&pred, ^{
    library = [[ALAssetsLibrary alloc] init];
  });
  return library;
}

#pragma mark Delegates (CRUIWindow)

- (void)window:(CRUIWindow *)window didSendEvent:(UIEvent *)event {
  if ([_videoWriter isRunning]) {
    [_eventRecorder recordEvent:event];
    _videoWriter.event = event;
  }
}

@end
