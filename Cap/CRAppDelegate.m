//
//  CRAppDelegate.m
//  Cap
//
//  Created by Gabriel Handford on 8/13/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRAppDelegate.h"
#import "CRTestView.h"

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
  
  [[CRRecorder sharedRecorder] registerWithName:@"Gabriel" code:@"11qz3PGMUjRkRvSM7aeTtMkm/1k="];
  [[CRRecorder sharedRecorder] setAlbumName:@"Capture Record"];
  
  _tableView = [[YKTableView alloc] init];
  YKSUIView *mainView = [YKSUIView viewWithView:_tableView title:@"Test"];
  
  [self addActionWithTitle:@"Alert" targetBlock:^() {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test" message:@"Test" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
  }];

  [_viewStack setView:mainView duration:0 options:0];
  [self.window makeKeyAndVisible];
  return YES;
}

@end
