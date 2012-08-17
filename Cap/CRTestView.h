//
//  CRTestView.h
//  Cap
//
//  Created by Gabriel Handford on 8/15/12.
//  Copyright (c) 2012 Gabriel Handford. All rights reserved.
//

@interface CRTestView : YKUILayoutView {
  YKUIButton *_button;
}

+ (YKSUIView *)testStackView;

+ (YKSUIView *)testStackViewWithName:(NSString *)name;

@end
