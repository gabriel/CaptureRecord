//
//  CRAppDelegate.m
//  Cap
//
//  Created by Gabriel Handford on 8/13/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRAppDelegate.h"
#import "CRTestView.h"
#import "CRMoviePlayerView.h"
#import "CRUIViewRecorder.h"
#import "CRScreenRecorder.h"
#import "CRUserRecorder.h"

@implementation CRAppDelegate

- (void)addActionWithTitle:(NSString *)title targetBlock:(UIControlTargetBlock)targetBlock {
  YKUIButtonCell *cell1 = [[YKUIButtonCell alloc] init];
  cell1.button.title = title;
  cell1.button.targetBlock = targetBlock;
  [_tableView.dataSource addCellDataSource:cell1 section:0];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor blackColor];
  
  _viewStack = [[YKUIViewStack alloc] initWithParentView:self.window];
  
#if TARGET_IPHONE_SIMULATOR
  CRUIViewRecorder *viewRecoder = [[CRUIViewRecorder alloc] initWithView:self.window size:CGSizeMake(320, 480)];
#else
  CRUIViewRecorder *viewRecoder = [[CRUIViewRecorder alloc] initWithView:self.window size:CGSizeMake(320, 480)];
  //CRScreenRecorder *viewRecoder = [[CRScreenRecorder alloc] init];
#endif
  CRUserRecorder *userRecorder = nil;// [[CRUserRecorder alloc] init];
  _videoRecorder = [[CRVideoRecorder alloc] initWithRecordables:[NSArray arrayWithObjects:viewRecoder, userRecorder, nil]];
  
  _tableView = [[YKTableView alloc] init];
  YKSUIView *mainView = [YKSUIView viewWithView:_tableView];
  [mainView.navigationBar setTitle:@"Test" animated:NO];
  
  __block CRAppDelegate *blockSelf = self;
  [self addActionWithTitle:@"Start" targetBlock:^() {
    [blockSelf->_videoRecorder start:nil];
  }];
  
  [self addActionWithTitle:@"Stop" targetBlock:^() {
    [blockSelf->_videoRecorder stop:nil];
  }];

  [self addActionWithTitle:@"Open" targetBlock:^() {
    CRMoviePlayerView *moviePlayerView = [[CRMoviePlayerView alloc] init];
    [moviePlayerView setFileURL:blockSelf->_videoRecorder.fileURL];
    [mainView pushView:[YKSUIView viewWithView:moviePlayerView] duration:0.25 options:YKSUIViewAnimationOptionTransitionSlideOver];
  }];

  [_viewStack setView:mainView duration:0 options:0];
  [self.window makeKeyAndVisible];
  return YES;
}

@end
