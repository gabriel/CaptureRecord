//
//  CRAppDelegate.h
//  Cap
//
//  Created by Gabriel Handford on 8/13/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRVideoRecorder.h"

@interface CRAppDelegate : UIResponder <UIApplicationDelegate> {
  YKUIViewStack *_viewStack;
  
  YKTableView *_tableView;
  
  CRVideoRecorder *_videoRecorder;
}

@property (strong, nonatomic) UIWindow *window;

@end
