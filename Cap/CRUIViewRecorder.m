//
//  CRUIViewRecorder.m
//  Cap
//
//  Created by Gabriel Handford on 8/16/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRUIViewRecorder.h"

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

- (void)renderWithWriter:(id<CRWriter>)writer context:(CGContextRef)context {
  CGContextSaveGState(context);
  CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, _size.height));
  CGContextTranslateCTM(context, _view.center.x, _view.center.y);
  CGContextConcatCTM(context,  _view.transform);
  CGContextTranslateCTM(context, -_view.bounds.size.width * _view.layer.anchorPoint.x, -_view.bounds.size.height * _view.layer.anchorPoint.y);
  [_view.layer renderInContext:context];
  CGContextRestoreGState(context);
}

@end
