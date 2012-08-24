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
#import "CRRecorder.h"
#import "CRUIWindow.h"

@implementation CRAppDelegate

- (void)addActionWithTitle:(NSString *)title targetBlock:(UIControlTargetBlock)targetBlock {
  YKUIButtonCell *cell1 = [[YKUIButtonCell alloc] init];
  cell1.button.title = title;
  cell1.button.targetBlock = targetBlock;
  [_tableView.dataSource addCellDataSource:cell1 section:0];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[CRUIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor blackColor];
  
  _viewStack = [[YKUIViewStack alloc] initWithParentView:self.window];
  
  _recorder = [[CRRecorder alloc] initWithWindow:self.window];
  
  _tableView = [[YKTableView alloc] init];
  YKSUIView *mainView = [YKSUIView viewWithView:_tableView];
  [mainView.navigationBar setTitle:@"Test" animated:NO];
  
  __block CRAppDelegate *blockSelf = self;
  [self addActionWithTitle:@"Start" targetBlock:^() {
    [blockSelf->_recorder start:nil];
  }];
  
  [self addActionWithTitle:@"Stop" targetBlock:^() {
    [blockSelf->_recorder stop:nil];
  }];

  [self addActionWithTitle:@"Play" targetBlock:^() {
    CRMoviePlayerView *moviePlayerView = [[CRMoviePlayerView alloc] init];
    [moviePlayerView setFileURL:blockSelf->_recorder.fileURL];
    [mainView pushView:[YKSUIView viewWithView:moviePlayerView title:@"Play"] duration:0.25 options:YKSUIViewAnimationOptionTransitionSlideOver];
  }];

  [_viewStack setView:mainView duration:0 options:0];
  [self.window makeKeyAndVisible];
  return YES;
}

@end
