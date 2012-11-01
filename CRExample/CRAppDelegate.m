//
//  CRAppDelegate.m
//  Cap
//
//  Created by Gabriel Handford on 8/13/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRAppDelegate.h"

@implementation CRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[CRUIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];  
  
  [[CRRecorder sharedRecorder] setAlbumName:@"Capture Record"];
  //[[CRRecorder sharedRecorder] setOptions:0];
  
  // To disable:
  //[CRUIWindow setDisabled:YES];
  
  [self.window makeKeyAndVisible];
  return YES;
}

@end
