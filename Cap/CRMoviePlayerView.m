//
//  CRMoviePlayerView.m
//  Cap
//
//  Created by Gabriel Handford on 8/16/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRMoviePlayerView.h"

@implementation CRMoviePlayerView

- (void)sharedInit {
  [super sharedInit];
  self.layout = [YKLayout layoutForView:self];
  _moviePlayer = [[MPMoviePlayerController alloc] init];
  _moviePlayer.controlStyle = MPMovieControlStyleDefault;
  [self addSubview:_moviePlayer.view];
}

- (CGSize)layout:(id<YKLayout>)layout size:(CGSize)size {
  [layout setFrame:CGRectMake(0, 0, size.width, size.height) view:_moviePlayer.view];
  return size;
}

- (void)setFileURL:(NSURL *)fileURL {
  _moviePlayer.contentURL = fileURL;
}

@end
