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
  CGImageRef image = CRGetScreenImage();
  CGContextDrawImage(context, CGRectMake(0, 0, _size.width, _size.height), image);
  CGImageRelease(image);
}

- (CGSize)size {
  return CGSizeMake(_size.width, _size.height);
}

@end
