//
//  CRUIWindow.m
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/24/12.
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

+ (void)setDisabled:(BOOL)disabled {
  [[self window] setDisabled:disabled];
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
  if (_disabled) return;
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

