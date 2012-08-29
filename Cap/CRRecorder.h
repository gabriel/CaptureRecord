//
//  CRRecorder.h
//  Cap
//
//  Created by Gabriel Handford on 8/21/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRVideoWriter.h"
#import "CRUIEventRecorder.h"
#import "CRUIWindow.h"
#import "CRDefines.h"

/*!
 The CRRecorder records a window and optionally user and touch events to a video.
 */
@interface CRRecorder : NSObject <CRUIWindowDelegate> {
  CRVideoWriter *_videoWriter;
  CRUIEventRecorder *_eventRecorder;
  CRUIWindow *_window;
}

/*!
 Create recorder for window.
 @param window Window
 @param options
 */
- (id)initWithWindow:(CRUIWindow *)window options:(CRRecorderOptions)options;

/*!
 Start the recording.
 @param error Out error
 @result YES if started succesfully, NO otherwise
 */
- (BOOL)start:(NSError **)error;

/*!
 Stop the recording.
 @param error Out error
 @result YES if started succesfully, NO otherwise
*/
- (BOOL)stop:(NSError **)error;

/*!
 Save the video to the camera roll.
 
 Video can only be saved if it exists; the writer was started and stopped.
 
 @param resultBlock After successfully saving the video
 @param failureBlock If there is a failure
 */
- (void)saveToAlbumWithResultBlock:(CRRecorderSaveResultBlock)resultBlock failureBlock:(CRRecorderSaveFailureBlock)failureBlock;

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
 The shared assets library instance used when saving videos.
 */
+ (ALAssetsLibrary *)sharedAssetsLibrary;

@end
