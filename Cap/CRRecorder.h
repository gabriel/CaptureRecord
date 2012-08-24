//
//  CRRecorder.h
//  Cap
//
//  Created by Gabriel Handford on 8/21/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRVideoWriter.h"
#import "CRUIEventRecorder.h"
#import "CRUIWindow.h"

@interface CRRecorder : NSObject <CRUIWindowDelegate> {
  CRVideoWriter *_videoWriter;
  CRUIEventRecorder *_eventRecorder;
  CRUIWindow *_window;
}

- (id)initWithWindow:(CRUIWindow *)window;

- (BOOL)start:(NSError **)error;

- (BOOL)stop:(NSError **)error;

- (NSURL *)fileURL;

@end
