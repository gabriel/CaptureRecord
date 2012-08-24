//
//  CRRecordable.h
//  Cap
//
//  Created by Gabriel Handford on 8/16/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

@protocol CRWriter <NSObject>
@property (readwrite) UIEvent *event;
@end

@protocol CRRecordable <NSObject>
- (void)renderWithWriter:(id<CRWriter>)writer context:(CGContextRef)context;
- (CGSize)size;
@optional
- (BOOL)start:(NSError **)error;
- (BOOL)stop:(NSError **)error;
@end
