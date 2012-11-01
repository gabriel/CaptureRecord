//
//  CRUIWindow.h
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/24/12.
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
 Disable all controls and event listeners.
 */
@property BOOL disabled;

/*!
 The current window instance.
 
 This is automatically set for most recent constructed CRUIWindow.
 */
+ (CRUIWindow *)window;

/*!
 Disable all controls and event listeners for the window.
 @param disabled Disable
 */
+ (void)setDisabled:(BOOL)disabled;

@end
