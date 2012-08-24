//
//  CRUIEventRecorder.m
//  Cap
//
//  Created by Gabriel Handford on 8/21/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRUIEventRecorder.h"
#import "CRUIEvent.h"

@implementation CRUIEventRecorder

- (id)init {
  if ((self = [super init])) {
    _events = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)recordEvent:(UIEvent *)event {
  //CRDebug(@"sendEvent: %@", event);
  CRUIEvent *recordEvent = [[CRUIEvent alloc] initWithEvent:event];
  [_events addObject:recordEvent];
}

@end
