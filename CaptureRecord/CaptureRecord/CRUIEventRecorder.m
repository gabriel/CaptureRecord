//
//  CRUIEventRecorder.m
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/21/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import "CRUIEventRecorder.h"

@implementation CRUIEventRecorder

- (id)init {
  if ((self = [super init])) {
    _events = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)recordEvent:(UIEvent *)event {
  //CRDebug(@"sendEvent: %@", event);
  [_events addObject:event];
}

@end
