//
//  CRUIButton.h
//
//  Created by Gabriel Handford on 12/17/08.
//  Copyright 2008 Yelp. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//
// This class is modified version of YKUIButton.
//

#import "CRCGUtils.h"

// A default button height
#define kButtonHeight 37

typedef enum {
  CRUIButtonIconPositionLeft = 0, // Default
  CRUIButtonIconPositionCenter, // Centered
  CRUIButtonIconPositionTop, // Aligned with top of button
} CRUIButtonIconPosition;

typedef enum {
  CRUIButtonSecondaryTitlePositionDefault = 0, // Default, next to title
  CRUIButtonSecondaryTitlePositionBottom, // Underneath the title
  CRUIButtonSecondaryTitlePositionRightAlign, // Next to title, right aligned
  CRUIButtonSecondaryTitlePositionBottomLeftSingle, // Bottom left, single line
} CRUIButtonSecondaryTitlePosition;

@interface CRUIButton : UIControl {

  NSString *_title;
  
  UIColor *_titleColor;
  UIFont *_titleFont;
  UITextAlignment _titleAlignment;
  CGSize _titleSize;
  UIEdgeInsets __titleInsets;
  
  UIColor *_color;
  UIColor *_color2;
  UIColor *_color3;
  UIColor *_color4;
  
  CRUIShadingType _shadingType;
  
  UIImage *_image;
  UIImage *_highlightedImage;
  UIImage *_disabledImage;

  UIEdgeInsets _margin;
  
  UIColor *_highlightedTitleColor;
  UIColor *_highlightedTitleShadowColor;
  CGSize _highlightedTitleShadowOffset;

  UIColor *_highlightedColor;
  UIColor *_highlightedColor2;
  CRUIShadingType _highlightedShadingType;
  UIColor *_highlightedBorderColor;
  UIColor *_highlightedBorderShadowColor;
  CGFloat _highlightedBorderShadowBlur;
  UIImage *_highlightedIconImage;
  
  UIColor *_disabledTitleColor;
  UIColor *_disabledColor;
  UIColor *_disabledColor2; 
  UIColor *_disabledBorderColor;
  CRUIShadingType _disabledShadingType;
  UIImage *_disabledIconImage;
  CGFloat _disabledAlpha;
  UIColor *_disabledTitleShadowColor;
  
  UIColor *_selectedTitleColor;
  UIColor *_selectedColor;
  UIColor *_selectedColor2;
  CRUIShadingType _selectedShadingType;
  UIColor *_selectedBorderShadowColor;
  CGFloat _selectedBorderShadowBlur;
  UIImage *_selectedIconImage;

  UIColor *_borderColor;
  CGFloat _borderWidth;
  CRUIBorderStyle _borderStyle;
  CGFloat _cornerRadius;
  CGFloat _cornerRadiusRatio;
  UIColor *_borderShadowColor;
  CGFloat _borderShadowBlur;
  
  UIColor *_titleShadowColor;
  CGSize _titleShadowOffset;
  
  UIImageView *_iconImageView;
  CGSize _iconImageSize;
  CGPoint _iconOrigin;
  
  UIImage *_accessoryImage;
  UIImage *_highlightedAccessoryImage;
  
  CRUIButtonIconPosition _iconPosition;
  UIColor *_iconShadowColor;
  
  UIActivityIndicatorView *_activityIndicatorView;
  
  NSString *_secondaryTitle;
  UIColor *_secondaryTitleColor;
  UIFont *_secondaryTitleFont;
  CRUIButtonSecondaryTitlePosition _secondaryTitlePosition;
  
  NSString *_abbreviatedTitle;
  CGSize _abbreviatedTitleSize;
  
  NSInteger _maxLineCount;
    
  BOOL _titleHidden;
  BOOL _highlightedEnabled;
  BOOL _selectedEnabled;
}

/*!
 Text for button.
 */
@property (retain, nonatomic) NSString *title; 

/*!
 Text font for button.
 */
@property (retain, nonatomic) UIFont *titleFont;

/*!
 Text alignment for title. Defaults to center.
 */
@property (assign, nonatomic) UITextAlignment titleAlignment;

/*!
 Text color for title.
 */
@property (retain, nonatomic) UIColor *titleColor;

/*!
 Background color for button.
 Can be used with shadingType, color2, color3, color4.
 */
@property (retain, nonatomic) UIColor *color; 

/*!
 Background (alternate) color for button.
 Not all shading types use color2.
 */
@property (retain, nonatomic) UIColor *color2;

/*!
 Background (alternate) color for button.
 Not all shading types use color3.
 */
@property (retain, nonatomic) UIColor *color3;

/*!
 Background (alternate) color for button.
 Not all shading types use color4.
 */
@property (retain, nonatomic) UIColor *color4;

/*!
 Shading type for background.
 */
@property (assign, nonatomic) CRUIShadingType shadingType;

/*!
 Border style.
 Defaults to CRUIBorderStyleRounded.
 */
@property (assign, nonatomic) CRUIBorderStyle borderStyle;

/*!
 Border color.
 */
@property (retain, nonatomic) UIColor *borderColor;

/*!
 Border width (stroke).
 */
@property (assign, nonatomic) CGFloat borderWidth;

/*!
 Border corner radius.
 */
@property (assign, nonatomic) CGFloat cornerRadius;

/*!
 Border corner radius ratio. For example 1.0 will be the most corner radius (half the height).
 */
@property (assign, nonatomic) CGFloat cornerRadiusRatio;

/*!
 Border shadow color (for inner glow).
 */
@property (retain, nonatomic) UIColor *borderShadowColor;

/*!
 Border shadow blur amount (for inner glow).
 */
@property (assign, nonatomic) CGFloat borderShadowBlur;

/*!
 Text shadow color.
 */
@property (retain, nonatomic) UIColor *titleShadowColor;

/*!
 Background image.
 */
@property (retain, nonatomic) UIImage *image;

/*!
 Margins for element.
 */
@property (assign, nonatomic) UIEdgeInsets margin;

/*!
 Background image (highlighted).
 */
@property (retain, nonatomic) UIImage *highlightedImage;

/*@!
 Background image (disabled).
 */
@property (retain, nonatomic) UIImage *disabledImage;

/*!
 Text shadow offset.
 */
@property (assign, nonatomic) CGSize titleShadowOffset;

/*!
 Image (view) to display to the left of the text.
 Alternatively, you can set the image.
 */
@property (retain, nonatomic) UIImageView *iconImageView;

/*!
 Image to display on the right side of the button.
 */
@property (retain, nonatomic) UIImage *accessoryImage;

/*!
 Insets for title text.
 */
@property (assign, nonatomic) UIEdgeInsets titleInsets; 

/*!
 Insets (padding).
 */
@property (assign, nonatomic) UIEdgeInsets insets;

/*!
 Hide the text.
 */
@property (assign, nonatomic, getter=isTitleHidden) BOOL titleHidden;

/*!
 Image to display to the left of the text.
 Alternatively, you can set the imageView.
 */
@property (retain, nonatomic) UIImage *iconImage;

/*!
 If set, will use this size instead of the image.size.
 Defaults to CGSizeZero (disabled).
 */
@property (assign, nonatomic) CGSize iconImageSize; 

/*!
 Override position for icon.
 Only supported for CRUIButtonIconPositionTop.
 Set a value of CGFLOAT_MAX to skip.
 */
@property (assign, nonatomic) CGPoint iconOrigin;

/*!
 Icon position.
 Defaults to CRUIButtonIconPositionLeft.
 */
@property (assign, nonatomic) CRUIButtonIconPosition iconPosition;

/*!
 Icon shadow color.
 */
@property (retain, nonatomic) UIColor *iconShadowColor;

/*!
 Text color for title (highlighted).
 */
@property (retain, nonatomic) UIColor *highlightedTitleColor;

/*!
 Background color for button (highlighted).
 Can be used with shadingType, color2, color3, color4.
 */
@property (retain, nonatomic) UIColor *highlightedColor;

/*!
 Background (alternate) color for button (highlighted).
 Not all shading types use color2.
 */
@property (retain, nonatomic) UIColor *highlightedColor2;

/*!
 Shading type for background (highlighted).
 */
@property (assign, nonatomic) CRUIShadingType highlightedShadingType;

/*!
 Border color (highlighted).
 */
@property (retain, nonatomic) UIColor *highlightedBorderColor;

/*!
 Border shadow color (highlighted).
 */
@property (retain, nonatomic) UIColor *highlightedBorderShadowColor;

/*!
 Border shadow blur (highlighted).
 */
@property (assign, nonatomic) CGFloat highlightedBorderShadowBlur;

/*!
 Text shadow color (highlighted).
 */
@property (retain, nonatomic) UIColor *highlightedTitleShadowColor;

/*!
 Text shadow offset (highlighted).
 */
@property (assign, nonatomic) CGSize highlightedTitleShadowOffset;

/*!
 Icon image (highlighted).
 */
@property (retain, nonatomic) UIImage *highlightedIconImage;

/*!
 Image to display on the right side of the button (highlighted).
 */
@property (retain, nonatomic) UIImage *highlightedAccessoryImage;

/*!
 Text color for title (selected).
 */
@property (retain, nonatomic) UIColor *selectedTitleColor;

/*!
 Background color for button (selected).
 Can be used with shadingType, color2, color3, color4.
 */
@property (retain, nonatomic) UIColor *selectedColor;

/*!
 Background (alternate) color for button (selected).
 Not all shading types use color2.
 */
@property (retain, nonatomic) UIColor *selectedColor2;

/*!
 Shading type for background (selected).
 */
@property (assign, nonatomic) CRUIShadingType selectedShadingType;

/*!
 Border shadow color (selected).
 */
@property (retain, nonatomic) UIColor *selectedBorderShadowColor;

/*!
 Border shadow blur (selected).
 */
@property (assign, nonatomic) CGFloat selectedBorderShadowBlur;

/*!
 Icon image (selected).
 */
@property (retain, nonatomic) UIImage *selectedIconImage;

/*!
 Text shadow color (selected).
 */
@property (retain, nonatomic) UIColor *selectedTitleShadowColor;

/*!
 Text shadow offset (selected).
 */
@property (assign, nonatomic) CGSize selectedTitleShadowOffset;

/*!
 Text color for title (selected).
 */
@property (retain, nonatomic) UIColor *disabledTitleColor;

/*!
 Background color for button (highlighted).
 Can be used with shadingType, color2, color3, color4.
 */
@property (retain, nonatomic) UIColor *disabledColor;

/*!
 Background (alternate) color for button (highlighted).
 Not all shading types use color2.
 */
@property (retain, nonatomic) UIColor *disabledColor2;

/*!
 Border color (disabled).
 */
@property (retain, nonatomic) UIColor *disabledBorderColor;

/*!
 Shading type for background (disabled).
 */
@property (assign, nonatomic) CRUIShadingType disabledShadingType;

/*!
 Icon (disabled).
 */
@property (retain, nonatomic) UIImage *disabledIconImage;

/*!
 Alpha (disabled). Defaults to 50%.
 */
@property (assign, nonatomic) CGFloat disabledAlpha;

/*!
 Title shadow color (disabled).
 */
@property (retain, nonatomic) UIColor *disabledTitleShadowColor;

/*!
 Secondary title, that appears next to title.
 */
@property (retain, nonatomic) NSString *secondaryTitle;

/*!
 Secondary title color.
 */
@property (retain, nonatomic) UIColor *secondaryTitleColor;

/*!
 Secondary title font. Defaults to titleFont.
 */
@property (retain, nonatomic) UIFont *secondaryTitleFont;

/*!
 Secondary title position.
 */
@property (assign, nonatomic) CRUIButtonSecondaryTitlePosition secondaryTitlePosition;

/*!
 Maximum line count. Default is no max (0).
 */
@property (assign, nonatomic) NSInteger maxLineCount;

/*!
 Abbreviated title to use if title doesn't fit.
 */
@property (retain, nonatomic) NSString *abbreviatedTitle;

- (void)sharedInit;

/*!
 Button.
 @param frame Frame
 @param title Title
 @param target Target
 @param action Action
 */
- (id)initWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)action;

/*!
 Button.
 @param frame Frame
 @param title Title
 */
- (id)initWithFrame:(CGRect)frame title:(NSString *)title;

/*!
 @result Button
 */
+ (CRUIButton *)button;

/*!
 Button.
 @param frame Frame
 @param title Title
 */
+ (CRUIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title;

/*!
 Button.
 @param frame Frame
 @param title Title
 @param target Target
 @param action Action
 */
+ (CRUIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)action;

/*!
 Button.
 @param title Title
 @param target Target
 @param action Action
 */
+ (CRUIButton *)buttonWithTitle:(NSString *)title target:(id)target action:(SEL)action;

/*!
 Size to fit button with a minimum size.
 @param minSize Min size
 */
- (void)sizeToFitWithMinimumSize:(CGSize)minSize;

/*!
 Size that fits title.
 @param size Size
 @result Size to only fit the title text (with insets).
 */
- (CGSize)sizeThatFitsTitle:(CGSize)size;

/*!
 Size that fits title.
 @param size Size
 @param minWidth Min width
 @result Size to only fit the title text (with insets).
 */
- (CGSize)sizeThatFitsTitle:(CGSize)size minWidth:(CGFloat)minWidth;

/*!
 Size that fits title and icon.
 @param size Size
 @result Size to fit the title text and icon (with insets).
 */
- (CGSize)sizeThatFitsTitleAndIcon:(CGSize)size;

/*!
 Set border.
 @param borderStyle Border style
 @param color Color
 @param width Width
 @param cornerRadius Corner radius
 */
- (void)setBorderStyle:(CRUIBorderStyle)borderStyle color:(UIColor *)color width:(CGFloat)width cornerRadius:(CGFloat)cornerRadius;

/*!
 Activity indicator view.
 */
- (UIActivityIndicatorView *)activityIndicatorView;

/*!
 Set activity indicator animating.
 @param animating Animating
 */
- (void)setActivityIndicatorAnimating:(BOOL)animating;

/*!
 @result YES if activity indicator is animating
 */
- (BOOL)isAnimating;

/*!
 Draw the view in the given rect.
 @param rect Rect to draw in.
 */
- (void)drawInRect:(CGRect)rect;

@end
