//
//  CRMoviePlayerView.h
//  Cap
//
//  Created by Gabriel Handford on 8/16/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface CRMoviePlayerView : YKUILayoutView {
  MPMoviePlayerController *_moviePlayer;
}

- (void)setFileURL:(NSURL *)fileURL;

@end
