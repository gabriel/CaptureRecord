//
//  CRAppDelegate.h
//  Cap
//
//  Created by Gabriel Handford on 8/13/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

@interface CRAppDelegate : UIResponder <UIApplicationDelegate> {
  YKUIViewStack *_viewStack;
  
  YKTableView *_tableView;
}

@property (strong, nonatomic) CRUIWindow *window;

@end
