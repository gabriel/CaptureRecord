//
//  CRAppDelegate.h
//  Cap
//
//  Created by Gabriel Handford on 8/13/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

#import "CRRecorder.h"

@interface CRAppDelegate : UIResponder <UIApplicationDelegate> {
  YKUIViewStack *_viewStack;
  
  YKTableView *_tableView;
  
  CRRecorder *_recorder;
}

@property (strong, nonatomic) CRUIWindow *window;

@end
