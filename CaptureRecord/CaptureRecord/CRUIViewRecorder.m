//
//  CRUIViewRecorder.m
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

#import "CRUIViewRecorder.h"
#import <QuartzCore/QuartzCore.h>

@implementation CRUIViewRecorder

- (id)initWithView:(UIView *)view size:(CGSize)size {
  if ((self = [super init])) {
    _view = view;
    _size = size;
  }
  return self;
}

- (CGSize)size {
  return _size;
}

- (void)renderInContext:(CGContextRef)context videoSize:(CGSize)videoSize {
  CGContextSaveGState(context);
  CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, _size.height));
  CGContextTranslateCTM(context, _view.center.x, _view.center.y);
  CGContextConcatCTM(context,  _view.transform);
  CGContextTranslateCTM(context, -_view.bounds.size.width * _view.layer.anchorPoint.x, -_view.bounds.size.height * _view.layer.anchorPoint.y);
  [_view.layer renderInContext:context];
  CGContextRestoreGState(context);
}

@end
