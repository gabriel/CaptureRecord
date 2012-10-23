//
//  CRDefines.h
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/13/12.
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

#define CRSetError(__ERROR__, __ERROR_CODE__, __DESC__, ...) do { \
NSString *message = [NSString stringWithFormat:__DESC__, ##__VA_ARGS__]; \
NSLog(@"%@", message); \
if (__ERROR__) *__ERROR__ = [NSError errorWithDomain:CRErrorDomain code:__ERROR_CODE__ \
userInfo:[NSDictionary dictionaryWithObjectsAndKeys:message, NSLocalizedDescriptionKey,  \
nil]]; \
} while (0)

#if DEBUG
#define CRDebug(...) NSLog(__VA_ARGS__)
#define CRWarn(...) NSLog(__VA_ARGS__)
#else
#define CRDebug(...) do { } while(0)
#define CRWarn(...) do { } while(0)
#endif

/*!
 Error domain.
 */
extern NSString *const CRErrorDomain;

/*!
 Exception.
 */
extern NSString *const CRException;

/*!
 Recording did start notification.
 Notification object is the CRRecorder instance that started.
 */
extern NSString *const CRRecorderDidStartNotification;

/*!
 Recording did stop notification.
 Notification object is the CRRecorder instance that stopped.
 */
extern NSString *const CRRecorderDidStopNotification;

/*!
 Video did change notification.
 Notification object is the CRVideo instance that changed.
 */
extern NSString *const CRVideoDidChangeNotification;

/*!
 UIEvent notification.
 Notification object is the UIEvent instance.
 */
extern NSString *const CRUIEventNotification;


typedef enum : NSInteger {
  CRErrorCodeInvalidVideo = -100,
  CRErrorCodeInvalidState = -101,
} CRErrorCode;

/*!
 CRRecorder options.
 */
typedef enum : NSUInteger {
  CRRecorderOptionUserCameraRecording = 1 << 0, // Record the user using the front facing camera
  CRRecorderOptionUserAudioRecording = 1 << 1, // Record the user audio
  CRRecorderOptionTouchRecording = 1 << 2, // Record touches
} CRRecorderOptions;

/*!
 Save result block.
 @param URL Asset URL. To load the ALAsset, use ALAssetsLibrary assetForURL:resultBlock:failureBlock.
 */
typedef void (^CRRecorderSaveResultBlock)(NSURL *URL);

/*!
 Save failure block.
 @param error Error
 */
typedef void (^CRRecorderSaveFailureBlock)(NSError *error);
