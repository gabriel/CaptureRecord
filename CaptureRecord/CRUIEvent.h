//
//  CRUIEvent.h
//  CaptureRecord
//
//  Created by Miscellaneum LLC on 8/21/12.
//  Copyright (c) 2012 Miscellaneum LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRUIEvent : NSObject

@property UIEvent *event;

- (id)initWithEvent:(UIEvent *)event;

@end
