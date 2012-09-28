//
//  CRScreenRecorder.m
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/16/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import "CRScreenRecorder.h"

#import <UIKit/UIKit.h>
#import "CRDefines.h"
#import "CRUtils.h"
#include <dlfcn.h>
#include <stdio.h>
#define UIKITPATH "/System/Library/Framework/UIKit.framework/UIKit"

@implementation CRScreenRecorder

- (id)init {
  if ((self = [super init])) {
    void *UIKit = dlopen(UIKITPATH, RTLD_LAZY);    
    NSString *methodName = [CRUtils cr_rot13:@"HVTrgFperraVzntr"]; // UIGetScreenImage
    _CRGetScreenImage = dlsym(UIKit, [methodName UTF8String]);
    dlclose(UIKit);
    
    _size = [UIScreen mainScreen].bounds.size;
  }
  return self;
}

- (void)renderInContext:(CGContextRef)context videoSize:(CGSize)videoSize {
  if (!_CRGetScreenImage) return;
  CGImageRef (*CRGetScreenImage)() = _CRGetScreenImage;
  //NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
  CGImageRef image = CRGetScreenImage();
  //CRDebug(@"GetScreenImage took %0.3fs", [NSDate timeIntervalSinceReferenceDate] - start);
  //start = [NSDate timeIntervalSinceReferenceDate];
  
//  CGFloat imageWidth = CGImageGetWidth(image);
//  CGFloat imageHeight = CGImageGetHeight(image);
//  CRDebug(@"Image size: %0f,%0f", imageWidth, imageHeight);
//  CGFloat y = videoSize.height - _size.height;
  
  CGContextDrawImage(context, CGRectMake(0, 0, _size.width, _size.height), image);
  CGImageRelease(image);
  //CRDebug(@"CGContextDrawImage took %0.3fs", [NSDate timeIntervalSinceReferenceDate] - start);
}

- (CGSize)size {
  return CGSizeMake(_size.width, _size.height);
}

@end
