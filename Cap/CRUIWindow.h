//
//  CRUIWindow.h
//  Cap
//
//  Created by Gabriel Handford on 8/24/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

@class CRUIWindow;

@protocol CRUIWindowDelegate <NSObject>
- (void)window:(CRUIWindow *)window didSendEvent:(UIEvent *)event;
@end

@interface CRUIWindow : UIWindow {
  
}

@property (assign, nonatomic) id<CRUIWindowDelegate> eventDelegate;

@end
