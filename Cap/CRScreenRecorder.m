//
//  CRScreenRecorder.m
//  Cap
//
//  Created by Gabriel Handford on 8/16/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRScreenRecorder.h"

@implementation CRScreenRecorder

CGImageRef UIGetScreenImage(void);

- (void)renderInContext:(CGContextRef)context {
  CGImageRef image = UIGetScreenImage();
  CGContextDrawImage(context, CGRectMake(0, 0, 320, 480), image);
  CGImageRelease(image);
}

- (CGSize)size {
  return CGSizeMake(320, 480);
}

@end
