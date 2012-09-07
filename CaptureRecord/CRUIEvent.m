//
//  CRUIEvent.m
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/21/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import "CRUIEvent.h"

@implementation CRUIEvent

- (id)initWithEvent:(UIEvent *)event {
  if ((self = [self init])) {
    _event = event;
  }
  return self;
}

@end
