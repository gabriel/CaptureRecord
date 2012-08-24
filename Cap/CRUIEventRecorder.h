//
//  CRUIEventRecorder.h
//  Cap
//
//  Created by Gabriel Handford on 8/21/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

@interface CRUIEventRecorder : NSObject {
  NSMutableArray *_events;
}

- (void)recordEvent:(UIEvent *)event;

@end
