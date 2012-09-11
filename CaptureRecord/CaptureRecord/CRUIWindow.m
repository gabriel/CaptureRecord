//
//  CRUIWindow.m
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/24/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import "CRUIWindow.h"
#import "CRDefines.h"
#import "CRRecorder.h"

@implementation CRUIWindow

- (void)sharedInit {
  _recordOverlay = [[CRUIRecordOverlay alloc] init];
  _recordOverlay.hidden = YES;
  [self addSubview:_recordOverlay];  
  [CRUIWindow setWindow:self];
}

static CRUIWindow *gWindow = NULL;

+ (void)setWindow:(CRUIWindow *)window {
  gWindow = window;
}

+ (CRUIWindow *)window {
  return gWindow;
}

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    [self sharedInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
  if ((self = [super initWithCoder:decoder])) {
    [self sharedInit];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  _recordOverlay.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
  [self bringSubviewToFront:_recordOverlay];
}

- (void)sendEvent:(UIEvent *)event {
  [super sendEvent:event];
  [self _gestureEvent:event];  
  [[NSNotificationCenter defaultCenter] postNotificationName:CRUIEventNotification object:event];
}

- (void)_gestureRecognized {
  CRDebug(@"Gesture recognized");
  _recordOverlay.hidden = NO;
}

- (void)_gestureEvent:(UIEvent *)event {
  if (event.type == UIEventTypeTouches) {
    if ([[event allTouches] count] != 2) return;
    UITouch *touch = [[event allTouches] anyObject];
    if (touch.phase == UITouchPhaseEnded && touch.tapCount >= 3) {
      [self _gestureRecognized];
    }
  }
}

@end

