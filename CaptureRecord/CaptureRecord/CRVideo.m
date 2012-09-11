//
//  CRVideo.m
//  CaptureRecord
//
//  Created by Gabriel Handford on 9/7/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import "CRVideo.h"
#import "CRDefines.h"
#import "CRUtils.h"
#import <AVFoundation/AVFoundation.h>

@interface CRVideo ()
@property (readwrite) CMTime presentationTimeStart;
@property (readwrite) CMTime presentationTimeStop;
@property (strong) NSURL *recordingFileURL;
@property (strong) NSURL *assetURL;
@end

@implementation CRVideo

- (id)init {
  if ((self = [super init])) {
    _presentationTimeStart = kCMTimeNegativeInfinity;
    _presentationTimeStop = kCMTimeNegativeInfinity;
  }
  return self;
}

- (NSTimeInterval)timeInterval {
  if (CMTIME_IS_NEGATIVE_INFINITY(_presentationTimeStart)) return -1;
  if (CMTIME_IS_NEGATIVE_INFINITY(_presentationTimeStop)) return -1;
  return (NSTimeInterval)(CMTimeGetSeconds(_presentationTimeStop) - CMTimeGetSeconds(_presentationTimeStart));
}

- (NSURL *)recordingFileURL:(NSError **)error {
  if (!self.recordingFileURL) {
    NSString *tempFile = [CRUtils cr_temporaryFile:@"output.mp4" deleteIfExists:YES error:error];
    if (!tempFile) {
      CRSetError(error, 0, @"Can't create temp video file.");
      return nil;
    }
    CRDebug(@"File: %@", tempFile);
    self.recordingFileURL = [NSURL fileURLWithPath:tempFile];
  }
  return self.recordingFileURL;
}

- (BOOL)start {
  if (_status != CRVideoStatusNone) return NO;
  [self setStatus:CRVideoStatusStarted];
  return YES;
}

- (BOOL)startSessionWithPresentationTime:(CMTime)presentationTime {
  if (_status != CRVideoStatusStarted) return NO;
  _presentationTimeStart = presentationTime;
  return YES;
}

- (BOOL)stopWithPresentationTime:(CMTime)presentationTime {
  if (_status != CRVideoStatusStarted) return NO;
  _presentationTimeStop = presentationTime;
  [self setStatus:CRVideoStatusStopped];
  return YES;
}

- (void)setStatus:(CRVideoStatus)status {
  _status = status;
  [[NSNotificationCenter defaultCenter] postNotificationName:CRVideoDidChangeNotification object:self];
}

- (void)saveToAlbumWithName:(NSString *)name resultBlock:(CRRecorderSaveResultBlock)resultBlock failureBlock:(CRRecorderSaveFailureBlock)failureBlock {
  if (_status == CRVideoStatusNone) {
    if (failureBlock) failureBlock([CRUtils cr_errorWithDomain:CRErrorDomain code:CRErrorCodeInvalidVideo localizedDescription:@"No recording to save."]);
    return;
  }
  
  if (_status == CRVideoStatusStarted) {
    if (failureBlock) failureBlock([CRUtils cr_errorWithDomain:CRErrorDomain code:CRErrorCodeInvalidState localizedDescription:@"You must stop recording to save the video."]);
    return;
  }
  
  if (_status == CRVideoStatusSaving) {
    if (failureBlock) failureBlock([CRUtils cr_errorWithDomain:CRErrorDomain code:CRErrorCodeInvalidState localizedDescription:@"Video is saving."]);
    return;
  }
  
  if (_status == CRVideoStatusDiscarded) {
    if (failureBlock) failureBlock([CRUtils cr_errorWithDomain:CRErrorDomain code:CRErrorCodeInvalidVideo localizedDescription:@"Video has been discarded."]);
    return;
  }
  
  self.assetURL = nil;
  [self setStatus:CRVideoStatusSaving];
  
  ALAssetsLibrary *library = [CRVideo sharedAssetsLibrary];
  
  [library writeVideoAtPathToSavedPhotosAlbum:self.recordingFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
    if (error) {
      [self setStatus:CRVideoStatusStopped];
      if (failureBlock) failureBlock(error);
      return;
    }
    self.assetURL = assetURL;
    
    if (name) {
      [self _findOrCreateAlbumWithName:name resultBlock:^(ALAssetsGroup *group) {
        [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
          CRDebug(@"Adding asset to group: %@ (editable=%d)", group, group.isEditable);
          if (![group addAsset:asset]) {
            CRWarn(@"Failed to add asset to group");
          }
          CRDebug(@"Saved to album: %@", asset);
          [self setStatus:CRVideoStatusSaved];
          if (resultBlock) resultBlock(assetURL);
        } failureBlock:^(NSError *error) {
          [self setStatus:CRVideoStatusStopped];
          if (failureBlock) failureBlock(error);
        }];
      } failureBlock:^(NSError *error) {
        [self setStatus:CRVideoStatusStopped];
        if (failureBlock) failureBlock(error);
      }];
    } else {
      [self setStatus:CRVideoStatusSaved];
      if (resultBlock) resultBlock(assetURL);
    }
  }];
}

- (BOOL)discard:(NSError **)error {
  if (_status == CRVideoStatusNone) {
    return YES;
  }
  
  if (!self.recordingFileURL) {
    return YES;
  }
  
  if (_status == CRVideoStatusStarted) {
    CRSetError(error, CRErrorCodeInvalidState, @"You must stop recording to save the video.");
    return NO;
  }
  
  if (_status == CRVideoStatusSaving) {
    CRSetError(error, CRErrorCodeInvalidState, @"Video is saving.");
    return NO;
  }
  
  NSString *filePath = [self.recordingFileURL absoluteString];
  BOOL success = YES;
  if ([CRUtils cr_exist:filePath]) {
    success = [[NSFileManager defaultManager] removeItemAtPath:filePath error:error];
  }
  self.recordingFileURL = nil;
  return success;
}

+ (ALAssetsLibrary *)sharedAssetsLibrary {
  static dispatch_once_t pred = 0;
  static ALAssetsLibrary *library = nil;
  dispatch_once(&pred, ^{
    library = [[ALAssetsLibrary alloc] init];
  });
  return library;
}

- (void)_findOrCreateAlbumWithName:(NSString *)name resultBlock:(ALAssetsLibraryGroupResultBlock)resultBlock failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock {
  
  ALAssetsLibrary *library = [CRVideo sharedAssetsLibrary];
  
  __block BOOL foundAlbum = NO;
  [library enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
    if ([name compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
      CRDebug(@"Found album: %@ (%@)", name, group);
      foundAlbum = YES;
      *stop = YES;
      if (resultBlock) resultBlock(group);
      return;
    }
    
    // When group is nil its the end of the enumeration
    if (!group && !foundAlbum) {
      CRDebug(@"Creating album: %@", name);
      [library addAssetsGroupAlbumWithName:name resultBlock:resultBlock failureBlock:failureBlock];
    }
  } failureBlock:failureBlock];
}

@end
