//
//  CRVideo.h
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 9/7/12.
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

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CRDefines.h"

typedef enum {
  CRVideoStatusNone = 0,
  CRVideoStatusStarted,
  CRVideoStatusStopped,
  CRVideoStatusSaving,
  CRVideoStatusSaved,
  CRVideoStatusDiscarded,
} CRVideoStatus;

/*!
 Video.
 */
@interface CRVideo : NSObject

@property (readonly) CMTime presentationTimeStart;
@property (readonly) CMTime presentationTimeStop;
@property (readonly, strong) NSURL *assetURL;
@property (readonly) CRVideoStatus status;

/*!
 Generate a temporary recording file URL.
 @param error Out error
 @result Recording file URL or nil if one couldn't be generated
 */
- (NSURL *)recordingFileURL:(NSError **)error;

/*!
 @result Video presentation time interval in seconds, or -1 if video is recording or never started.
 */
- (NSTimeInterval)timeInterval;

/*!
 Mark video as started.
 @result YES if not already started
 */
- (BOOL)start;

/*!
 Set presentation time start.
 @param presentationTime Start presentation time
 @result YES if started
 */
- (BOOL)startSessionWithPresentationTime:(CMTime)presentationTime;

/*!
 Mark video as stopped.
 @param presentationTime Stop presentation time
 @result YES if not already stopped
 */
- (BOOL)stopWithPresentationTime:(CMTime)presentationTime;

/*!
 Save the video to the album with name.
 If the album doesn't exist, it is created.
 
 The video is also saved to the camera roll.
 
 @param name Album name
 @param resultBlock After successfully saving the video
 @param failureBlock If there is a failure
 */
- (void)saveToAlbumWithName:(NSString *)name resultBlock:(CRRecorderSaveResultBlock)resultBlock failureBlock:(CRRecorderSaveFailureBlock)failureBlock;

/*!
 Discard the video.
 @param error Out error
 @result YES if discarded or didn't exist, NO if there was an error
 */
- (BOOL)discard:(NSError **)error;

/*!
 The shared assets library instance used when saving videos.
 */
+ (ALAssetsLibrary *)sharedAssetsLibrary;

@end
