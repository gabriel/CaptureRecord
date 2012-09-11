//
//  CRUIWindow.h
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/24/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRUIButton.h"
#import "CRUIRecordOverlay.h"

@class CRUIWindow;

/*!
 Window for the recording.
 */
@interface CRUIWindow : UIWindow {
  CRUIRecordOverlay *_recordOverlay;
}

/*!
 The current window instance.
 
 This is automatically set for most recent constructed CRUIWindow.
 */
+ (CRUIWindow *)window;

@end
