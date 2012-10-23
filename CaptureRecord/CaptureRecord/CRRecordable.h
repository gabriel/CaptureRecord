//
//  CRRecordable.h
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

#import <CoreMedia/CoreMedia.h>

/*!
 The CRRecordable protocol defines a renderable view with a fixed size.
 
 If the CRRecordable needs to start and stop, they can define those methods and will be notified of start and stop events.
 
 @see CRScreenRecorder
 @see CRCameraRecorder
 @see CRUIViewRecorder
 */
@protocol CRRecordable <NSObject>

/*!
 Render the recordable in the specified context.
 @param context Context to render in
 @param videoSize Video size
 */
- (void)renderInContext:(CGContextRef)context videoSize:(CGSize)videoSize;

/*!
 @result The size of the recordable. This size must be fixed and is required before any rendering begins.
 */
- (CGSize)size;

@optional

/*!
 When the recording is started, we will notify the recordable.
 @param error Out error
 @result YES if started successfully, NO otherwise
 */
- (BOOL)start:(NSError **)error;

/*!
 When the recording is stopped, we will notify the recordable.
 @param error Out error
 @result YES if stopped successfully, NO otherwise
 */
- (BOOL)stop:(NSError **)error;

@end

/*!
 The CRAudioWriter protocol defines that a class can record audio. 
 
 @see CRVideoWriter
 */
@protocol CRAudioWriter <NSObject>
/*!
 Append audio sample buffer.
 @param sampleBuffer Audio sample buffer
 */
- (BOOL)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end
