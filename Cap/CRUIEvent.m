//
//  CRUIEvent.m
//  Cap
//
//  Created by Gabriel Handford on 8/21/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
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
