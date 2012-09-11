//
//  CRUITouch.h
//  CaptureRecord
//
//  Created by Gabriel Handford on 9/10/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>

@interface CRUITouch : NSObject

@property CGPoint point;
@property NSTimeInterval time;

- (id)initWithPoint:(CGPoint)point;

@end
