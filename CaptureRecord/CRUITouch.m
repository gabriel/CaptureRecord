//
//  CRUITouch.m
//  CaptureRecord
//
//  Created by Gabriel Handford on 9/10/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import "CRUITouch.h"

@implementation CRUITouch

- (id)initWithPoint:(CGPoint)point {
  if ((self = [super init])) {
    _point = point;
    _time = [NSDate timeIntervalSinceReferenceDate];
  }
  return self;
}

@end
