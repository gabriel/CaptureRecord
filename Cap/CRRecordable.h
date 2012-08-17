//
//  CRRecordable.h
//  Cap
//
//  Created by Gabriel Handford on 8/16/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

@protocol CRRecordable <NSObject>
- (void)renderInContext:(CGContextRef)context;
- (CGSize)size;
@optional
- (BOOL)start:(NSError **)error;
- (BOOL)stop:(NSError **)error;
@end
