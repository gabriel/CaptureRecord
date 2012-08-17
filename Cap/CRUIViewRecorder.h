//
//  CRUIViewRecorder.h
//  Cap
//
//  Created by Gabriel Handford on 8/16/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRRecordable.h"

@interface CRUIViewRecorder : NSObject <CRRecordable> {
  UIView *_view;
  CGSize _size;
}

- (id)initWithView:(UIView *)view size:(CGSize)size;

@end
