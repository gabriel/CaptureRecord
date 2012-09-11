//
//  CRUIViewRecorder.h
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/16/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRRecordable.h"

/*!
 Recorder for a UIView.
 */
@interface CRUIViewRecorder : NSObject <CRRecordable> {
  UIView *_view;
  CGSize _size;
}

/*!
 Create UIView recorder of size.
 @param view View
 @param size Size
 */
- (id)initWithView:(UIView *)view size:(CGSize)size;

@end
