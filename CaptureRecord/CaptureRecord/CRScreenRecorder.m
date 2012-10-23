//
//  CRScreenRecorder.m
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/16/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//
//  Licensed under the Cocoa Controls commercial license agreement, v1, included
//  with the original package and can also be found at:
//  <http://CocoaControls.com/licenses/v1/license.pdf>.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
