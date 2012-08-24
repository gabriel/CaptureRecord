//
//  CRUIWindow.m
//  Cap
//
//  Created by Gabriel Handford on 8/24/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRUIWindow.h"

@implementation CRUIWindow

- (void)sendEvent:(UIEvent *)event {
  [super sendEvent:event];
  [self.eventDelegate window:self didSendEvent:event];
}

@end
