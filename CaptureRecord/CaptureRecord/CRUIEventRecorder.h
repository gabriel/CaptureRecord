//
//  CRUIEventRecorder.h
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/21/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRUIEventRecorder : NSObject {
  NSMutableArray *_events;
}

- (void)recordEvent:(UIEvent *)event;

@end
