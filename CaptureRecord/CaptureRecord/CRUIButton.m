//
//  CRUIButton.m
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

#import "CRUIButton.h"

@implementation CRUIButton

@synthesize title=_title, titleColor=_titleColor, titleFont=_titleFont, borderWidth=_borderWidth, color=_color, color2=_color2, color3=_color3, color4=_color4, highlightedTitleColor=_highlightedTitleColor, highlightedColor=_highlightedColor, highlightedColor2=_highlightedColor2, highlightedShadingType=_highlightedShadingType, disabledTitleColor=_disabledTitleColor, disabledColor=_disabledColor, disabledColor2=_disabledColor2, disabledShadingType=_disabledShadingType, shadingType=_shadingType, borderColor=_borderColor, borderStyle=_borderStyle, titleShadowColor=_titleShadowColor, accessoryImage=_accessoryImage, highlightedAccessoryImage=_highlightedAccessoryImage, titleAlignment=_titleAlignment, titleHidden=_titleHidden, titleInsets=_titleInsets, titleShadowOffset=_titleShadowOffset, selectedTitleColor=_selectedTitleColor, selectedColor=_selectedColor, selectedColor2=_selectedColor2, selectedShadingType=_selectedShadingType, cornerRadius=_cornerRadius, highlightedTitleShadowColor=_highlightedTitleShadowColor, highlightedTitleShadowOffset=_highlightedTitleShadowOffset, disabledBorderColor=_disabledBorderColor, insets=_insets, borderShadowColor=_borderShadowColor, borderShadowBlur=_borderShadowBlur, iconImageSize=_iconImageSize, iconImageView=_iconImageView, highlightedImage=_highlightedImage, image=_image, selectedBorderShadowColor=_selectedBorderShadowColor, selectedBorderShadowBlur=_selectedBorderShadowBlur, disabledImage=_disabledImage, iconPosition=_iconPosition, highlightedBorderShadowColor=_highlightedBorderShadowColor, highlightedBorderShadowBlur=_highlightedBorderShadowBlur, secondaryTitle=_secondaryTitle, secondaryTitleColor=_secondaryTitleColor, secondaryTitleFont=_secondaryTitleFont, iconOrigin=_iconOrigin, maxLineCount=_maxLineCount, highlightedBorderColor=_highlightedBorderColor, disabledIconImage=_disabledIconImage, margin=_margin, cornerRadiusRatio=_cornerRadiusRatio, secondaryTitlePosition=_secondaryTitlePosition, selectedIconImage=_selectedIconImage, highlightedIconImage=_highlightedIconImage, abbreviatedTitle=_abbreviatedTitle, selectedTitleShadowColor=_selectedTitleShadowColor, selectedTitleShadowOffset=_selectedTitleShadowOffset, iconShadowColor=_iconShadowColor, disabledAlpha=_disabledAlpha, disabledTitleShadowColor=_disabledTitleShadowColor;

- (id)init {
  return [self initWithFrame:CGRectZero];
}

- (void)sharedInit {
  self.userInteractionEnabled = YES;
  self.opaque = YES;
  self.backgroundColor = [UIColor clearColor];
  self.contentMode = UIViewContentModeRedraw;
  _highlightedEnabled = YES;
  _selectedEnabled = NO;
  _titleAlignment = UITextAlignmentCenter;
  _insets = UIEdgeInsetsZero;
  _titleInsets = UIEdgeInsetsZero;
  _iconImageSize = CGSizeZero;
  _iconOrigin = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
  _selectedShadingType = CRUIShadingTypeUnknown;
  _highlightedShadingType = CRUIShadingTypeUnknown;
  _disabledShadingType = CRUIShadingTypeUnknown;
  _margin = UIEdgeInsetsZero;
  _disabledAlpha = 1.0;
  _titleColor = [UIColor blackColor];
  _titleFont = [UIFont boldSystemFontOfSize:14.0];
  _titleShadowOffset = CGSizeZero;
  self.accessibilityTraits |= UIAccessibilityTraitButton;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if ((self = [super initWithCoder:aDecoder])) {
    [self sharedInit];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    [self sharedInit];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)action {
  if ((self = [self initWithFrame:frame])) {
    self.title = title;
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title {
  if ((self = [self initWithFrame:frame title:title target:nil action:NULL])) { }
  return self;
}

+ (CRUIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title {
  return [[[self class] alloc] initWithFrame:frame title:title];
}

+ (CRUIButton *)buttonWithTitle:(NSString *)title target:(id)target action:(SEL)action {
  return [self buttonWithFrame:CGRectZero title:title target:target action:action];
}

+ (CRUIButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)action {
  return [[[self class] alloc] initWithFrame:frame title:title target:target action:action];
}

- (CGSize)_sizeForTitle:(NSString *)title constrainedToSize:(CGSize)constrainedToSize {
  if (_maxLineCount > 0) {
    CGSize lineSize = [@" " sizeWithFont:_titleFont];
    constrainedToSize.height = lineSize.height * _maxLineCount;
  }

  CGSize titleSize = CGSizeZero;

  if (title) {
    titleSize = [title sizeWithFont:_titleFont constrainedToSize:constrainedToSize lineBreakMode:UILineBreakModeTailTruncation];
    // TODO: Probably need this because sizeWithFont and draw methods produce different sizing
    titleSize.width += 2;
  }

  if (_secondaryTitle) {
    if (_secondaryTitlePosition == CRUIButtonSecondaryTitlePositionDefault || _secondaryTitlePosition == CRUIButtonSecondaryTitlePositionRightAlign) {
      constrainedToSize.width -= roundf(titleSize.width);
      CGSize secondaryTitleSize = [_secondaryTitle sizeWithFont:(_secondaryTitleFont ? _secondaryTitleFont : _titleFont) constrainedToSize:constrainedToSize lineBreakMode:UILineBreakModeTailTruncation];
      titleSize.width += roundf(secondaryTitleSize.width);
    } else if (_secondaryTitlePosition == CRUIButtonSecondaryTitlePositionBottom) {
      CGSize secondaryTitleSize = [_secondaryTitle sizeWithFont:(_secondaryTitleFont ? _secondaryTitleFont : _titleFont) constrainedToSize:constrainedToSize lineBreakMode:UILineBreakModeTailTruncation];
      titleSize.height += roundf(secondaryTitleSize.height);
    } else if (_secondaryTitlePosition == CRUIButtonSecondaryTitlePositionBottomLeftSingle) {
      CGSize secondaryTitleSize = [_secondaryTitle sizeWithFont:(_secondaryTitleFont ? _secondaryTitleFont : _titleFont)];
      titleSize.height += roundf(secondaryTitleSize.height);
    }
  }
  return titleSize;
}

- (void)layoutSubviews {
  [super layoutSubviews];

  CGFloat y = 0;
  CGSize size = self.frame.size;

  y += _insets.top;
  UIEdgeInsets titleInsets = [self _titleInsets];
  y += titleInsets.top;

  // If the title is nil, but _titleSize hasn't been updated yet
  // Happens when the title gets changed from non-nil to nil.
  if (!CRCGSizeIsZero(_titleSize) && !_title) {
    _titleSize = CGSizeZero;
    _abbreviatedTitleSize = CGSizeZero;
  } else if (_title) {
    CGSize constrainedToSize = size;
    // Subtract insets
    constrainedToSize.width -= (titleInsets.left + titleInsets.right);
    constrainedToSize.width -= (_insets.left + _insets.right);

    // Subtract icon width
    CGSize iconSize = _iconImageSize;
    if (_iconImageView.image && CRCGSizeIsZero(iconSize)) {
      iconSize = _iconImageView.image.size;
      iconSize.width += 2; // TODO(gabe): Set configurable
    }
    constrainedToSize.width -= iconSize.width;

    if (_activityIndicatorView && _activityIndicatorView.isAnimating) {
      constrainedToSize.width -= _activityIndicatorView.frame.size.width;
    }

    if (constrainedToSize.height == 0) {
      constrainedToSize.height = 9999;
    }

    _titleSize = [self _sizeForTitle:_title constrainedToSize:constrainedToSize];
    _abbreviatedTitleSize = [self _sizeForTitle:_abbreviatedTitle constrainedToSize:constrainedToSize];

    if (_activityIndicatorView) {
      if (_titleHidden) {
        CGPoint p = CRCGPointToCenter(_activityIndicatorView.frame.size, size);
        _activityIndicatorView.frame = CGRectMake(p.x, p.y, _activityIndicatorView.frame.size.width, _activityIndicatorView.frame.size.height);
      } else {
        CGPoint p = CRCGPointToCenter(_titleSize, size);
        p.x -= _activityIndicatorView.frame.size.width + 4;
        _activityIndicatorView.frame = CGRectMake(p.x, p.y, _activityIndicatorView.frame.size.width, _activityIndicatorView.frame.size.height);
      }
    }

    y += _titleSize.height;
  }

  y += titleInsets.bottom;
  y += _insets.bottom;
}

- (void)setEnabled:(BOOL)enabled {
  [super setEnabled:enabled];
  if (_disabledAlpha == 1.0) return;
  self.alpha = (!enabled ? _disabledAlpha : 1.0);
}

- (UIEdgeInsets)_titleInsets {
  UIEdgeInsets titleInsets = _titleInsets;
  if (_borderStyle == CRUIBorderStyleRoundedBack) {
    titleInsets.left += 4;
  }
  return titleInsets;
}

- (CGSize)sizeThatFitsTitle:(CGSize)size minWidth:(CGFloat)minWidth {
  CGSize sizeThatFitsTitle = [self sizeThatFitsTitle:size];
  if (sizeThatFitsTitle.width < minWidth) sizeThatFitsTitle.width = minWidth;
  return sizeThatFitsTitle;
}

- (CGSize)sizeThatFitsTitle:(CGSize)size {
  CGSize titleSize = [self _sizeForTitle:_title constrainedToSize:size];
  CGSize accessoryImageSize = CGSizeZero;
  if (_accessoryImage) {
    accessoryImageSize = _accessoryImage.size;
    accessoryImageSize.width += 10;
  }
  UIEdgeInsets titleInsets = [self _titleInsets];
  return CGSizeMake(titleSize.width + _insets.left + _insets.right + titleInsets.left + titleInsets.right + accessoryImageSize.width, titleSize.height + titleInsets.top + titleInsets.bottom + _insets.top + _insets.bottom);
}

- (CGSize)sizeThatFitsTitleAndIcon:(CGSize)size {
  CGSize titleSize = [self sizeThatFitsTitle:size];
  CGSize iconSize = _iconImageSize;
  if (_iconImageView.image && CRCGSizeIsZero(iconSize)) {
    iconSize = _iconImageView.image.size;
  }
  return CGSizeMake(titleSize.width + iconSize.width, titleSize.height + iconSize.height);
}

- (void)setHighlighted:(BOOL)highlighted {
  for (UIView *view in [self subviews]) {
    if ([view respondsToSelector:@selector(setHighlighted:)]) {
      [(id)view setHighlighted:highlighted];
    }
  }
  [super setHighlighted:highlighted];
}

- (void)didChangeValueForKey:(NSString *)key {
  [super didChangeValueForKey:key];
  [self setNeedsLayout];
  [self setNeedsDisplay];
}

- (void)setTitleInsets:(UIEdgeInsets)titleInsets {
  _titleInsets = titleInsets;
  [self didChangeValueForKey:@"titleInsets"];
}

- (void)setTitleFont:(UIFont *)titleFont {
  _titleFont = titleFont;
  [self didChangeValueForKey:@"titleFont"];
}

- (void)setTitle:(NSString *)title {
  _title = title;
  [self didChangeValueForKey:@"title"];
}

- (void)setSecondaryTitle:(NSString *)secondaryTitle {
  _secondaryTitle = secondaryTitle;
  [self didChangeValueForKey:@"secondaryTitle"];
}

- (void)setTitleHidden:(BOOL)titleHidden {
  _titleHidden = titleHidden;
  [self didChangeValueForKey:@"titleHidden"];
}

- (void)setColor:(UIColor *)color {
  _color = color;
  // Set shading type to none if a color is set
  if (_shadingType == CRUIShadingTypeUnknown) {
    _shadingType = CRUIShadingTypeNone;
  }
  [self didChangeValueForKey:@"color"];
}

- (void)_cornerRadiusChanged {
  if (_borderStyle == CRUIBorderStyleNone && (_cornerRadius > 0 || _cornerRadiusRatio > 0)) {
    _borderStyle = CRUIBorderStyleRounded;
    [self didChangeValueForKey:@"borderStyle"];
  }
  [self didChangeValueForKey:@"cornerRadius"];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
  _cornerRadius = cornerRadius;
  [self _cornerRadiusChanged];
}

- (void)setCornerRadiusRatio:(CGFloat)cornerRadiusRatio {
  _cornerRadiusRatio = cornerRadiusRatio;
  [self didChangeValueForKey:@"cornerRadiusRatio"];
  [self _cornerRadiusChanged];
}

+ (CRUIButton *)button {
  return [[CRUIButton alloc] init];
}

- (void)sizeToFitWithMinimumSize:(CGSize)minSize {
  CGSize size = [self sizeThatFits:minSize];
  if (size.width < minSize.width) size.width = minSize.width;
  if (size.height < minSize.height) size.height = minSize.height;
  self.frame = CRCGRectSetSize(self.frame, size);
}

- (void)setBorderStyle:(CRUIBorderStyle)borderStyle {
  _borderStyle = borderStyle;
  [self didChangeValueForKey:@"borderStyle"];
}

- (void)setBorderStyle:(CRUIBorderStyle)borderStyle color:(UIColor *)color width:(CGFloat)width cornerRadius:(CGFloat)cornerRadius {
  self.borderStyle = borderStyle;
  self.borderColor = color;
  self.borderWidth = width;
  self.cornerRadius = cornerRadius;  
}

- (void)setIconImage:(UIImage *)iconImage {
  _iconImageView = [[UIImageView alloc] initWithImage:iconImage];
}

- (UIImage *)iconImage {
  return _iconImageView.image;
}

- (UIColor *)textColorForState:(UIControlState)state {

  BOOL isSelected = self.isSelected;
  BOOL isHighlighted = (self.isHighlighted && self.userInteractionEnabled);
  BOOL isDisabled = !self.isEnabled;

  if (_selectedTitleColor && isSelected) {
    return _selectedTitleColor;
  } else if (_highlightedTitleColor && isHighlighted) {
    return _highlightedTitleColor;
  } else if (_disabledTitleColor && isDisabled) {
    return _disabledTitleColor;
  } else if (_titleColor) {
    return _titleColor;
  } else {
    return [UIColor blackColor];
  }
}

- (UIActivityIndicatorView *)activityIndicatorView {
  if (!_activityIndicatorView) {
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.hidesWhenStopped = YES;
    [self addSubview:_activityIndicatorView];
  }
  return _activityIndicatorView;
}

- (void)setActivityIndicatorAnimating:(BOOL)animating {
  UIActivityIndicatorView *activityIndicatorView = [self activityIndicatorView];
  if (animating) [activityIndicatorView startAnimating];
  else [activityIndicatorView stopAnimating];
  self.userInteractionEnabled = !animating;
  [self setNeedsLayout];
}

- (BOOL)isAnimating {
  return [_activityIndicatorView isAnimating];
}

- (void)drawInRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();

  UIControlState state = self.state;
  CGRect bounds = rect;
  bounds = UIEdgeInsetsInsetRect(bounds, _margin);
  CGSize size = bounds.size;

  size.height -= _insets.top + _insets.bottom;

  BOOL isHighlighted = (self.isHighlighted && self.userInteractionEnabled);
  BOOL isSelected = self.isSelected;
  BOOL isDisabled = !self.isEnabled;

  CRUIShadingType shadingType = _shadingType;
  UIColor *color = _color;
  UIColor *color2 = _color2;
  UIColor *color3 = _color3;
  UIColor *color4 = _color4;
  UIColor *borderColor = _borderColor;

  UIImage *image = _image;

  UIColor *borderShadowColor = _borderShadowColor;
  CGFloat borderShadowBlur = _borderShadowBlur;

  CGFloat cornerRadius = _cornerRadius;
  if (_cornerRadiusRatio > 0) {
    cornerRadius = roundf(bounds.size.height/2.0f) * _cornerRadiusRatio;
  }

  UIColor *titleShadowColor = _titleShadowColor;
  CGSize titleShadowOffset = _titleShadowOffset;
  UIImage *icon = _iconImageView.image;
  UIImage *accessoryImage = _accessoryImage;

  if (isDisabled) {
    if (_disabledShadingType != CRUIShadingTypeUnknown) shadingType = _disabledShadingType;
    if (_disabledColor) color = _disabledColor;
    if (_disabledColor2) color2 = _disabledColor2;
    if (_disabledBorderColor) borderColor = _disabledBorderColor;
    if (_disabledImage) image = _disabledImage;
    if (_disabledIconImage) icon = _disabledIconImage;
    if (_disabledTitleShadowColor) titleShadowColor = _disabledTitleShadowColor;
  } else if (isHighlighted) {
    if (_highlightedShadingType != CRUIShadingTypeUnknown) shadingType = _highlightedShadingType;
    if (_highlightedColor) color = _highlightedColor;
    if (_highlightedColor2) color2 = _highlightedColor2;
    if (_highlightedImage) image = _highlightedImage;
    if (_highlightedBorderColor) borderColor = _highlightedBorderColor;
    if (_highlightedBorderShadowColor) borderShadowColor = _highlightedBorderShadowColor;
    if (_highlightedBorderShadowBlur) borderShadowBlur = _highlightedBorderShadowBlur;
    if (_highlightedTitleShadowColor) titleShadowColor = _highlightedTitleShadowColor;
    if (!CGSizeEqualToSize(_highlightedTitleShadowOffset, CGSizeZero)) titleShadowOffset = _highlightedTitleShadowOffset;
    if (_highlightedIconImage) icon = _highlightedIconImage;
    if (_highlightedAccessoryImage) accessoryImage = _highlightedAccessoryImage;
  } else if (isSelected) {
    // Set from selected properties; Fall back to highlighted properties
    if (_selectedShadingType != CRUIShadingTypeUnknown) shadingType = _selectedShadingType;
    else if (_highlightedShadingType != CRUIShadingTypeUnknown) shadingType = _highlightedShadingType;
    if (_selectedColor) color = _selectedColor;
    else if (_highlightedColor) color = _highlightedColor;
    if (_selectedColor2) color2 = _selectedColor2;
    else if (_highlightedColor2) color2 = _highlightedColor2;
    if (_highlightedImage) image = _highlightedImage;
    if (_selectedBorderShadowColor) borderShadowColor = _selectedBorderShadowColor;
    if (_selectedBorderShadowBlur) borderShadowBlur = _selectedBorderShadowBlur;
    if (_selectedIconImage) icon = _selectedIconImage;
    if (_selectedTitleShadowColor) titleShadowColor = _selectedTitleShadowColor;
    else if (_highlightedTitleShadowColor) titleShadowColor = _highlightedTitleShadowColor;
    if (!CGSizeEqualToSize(_selectedTitleShadowOffset, CGSizeZero)) titleShadowOffset = _selectedTitleShadowOffset;
    else if (!CGSizeEqualToSize(_highlightedTitleShadowOffset, CGSizeZero)) titleShadowOffset = _highlightedTitleShadowOffset;
  }

  // Set a sensible default
  if (borderShadowColor && borderShadowBlur == 0) borderShadowBlur = 3;

  UIColor *fillColor = color;

  CGFloat borderWidth = _borderWidth;

  // Clip for border styles that support it (that form a cohesive path)
  BOOL clip = (_borderStyle != CRUIBorderStyleTopOnly && _borderStyle != CRUIBorderStyleBottomOnly && _borderStyle != CRUIBorderStyleTopBottom && _borderStyle != CRUIBorderStyleNone && _borderStyle != CRUIBorderStyleNormal);

  if (color && shadingType != CRUIShadingTypeNone) {
    if (clip) {
      CGContextSaveGState(context);
    }

    CRCGContextAddStyledRect(context, bounds, _borderStyle, borderWidth, cornerRadius);
    if (clip) {
      CGContextClip(context);
    }

    CRCGContextDrawShading(context, color.CGColor, color2.CGColor, color3.CGColor, color4.CGColor, bounds.origin, CGPointMake(bounds.origin.x, CGRectGetMaxY(bounds)), shadingType, NO, NO);
    fillColor = nil;

    if (clip) {
      CGContextRestoreGState(context);
    }
  }

  if (_borderWidth > 0 || cornerRadius > 0) {
    if (borderShadowColor) {
      CGContextSaveGState(context);
      // Need to clip without border width adjustment
      if (clip) {
        CRCGContextAddStyledRect(context, bounds, _borderStyle, 0, cornerRadius);
        CGContextClip(context);
      }

      CRCGContextDrawBorderWithShadow(context, bounds, _borderStyle, fillColor.CGColor, borderColor.CGColor, borderWidth, cornerRadius, borderShadowColor.CGColor, borderShadowBlur, NO);
      CGContextRestoreGState(context);
    } else {
      CRCGContextDrawBorder(context, bounds, _borderStyle, fillColor.CGColor, borderColor.CGColor, borderWidth, cornerRadius);
    }
  } else if (fillColor) {
    [fillColor setFill];
    CGContextFillRect(context, bounds);
  }

  if (image) {
    [image drawInRect:bounds];
  }

  UIColor *textColor = [self textColorForState:state];

  UIFont *font = self.titleFont;

  NSString *title = _title;
  CGSize titleSize = _titleSize;

  // Check if we need to use abbreviated title
  if (_abbreviatedTitle) {
    CGSize titleSizeAbbreviated = [_title sizeWithFont:_titleFont];
    if (titleSizeAbbreviated.width > _titleSize.width) {
      title = _abbreviatedTitle;
      titleSize = _abbreviatedTitleSize;
    }
  }

  CGFloat y = bounds.origin.y + roundf(CRCGPointToCenter(titleSize, size).y) + _insets.top;

  BOOL showIcon = (icon != nil && !_iconImageView.hidden);
  CGSize iconSize = _iconImageSize;
  if (icon && CRCGSizeIsZero(iconSize)) {
    iconSize = icon.size;
  }

  UIEdgeInsets titleInsets = [self _titleInsets];
  if (!_titleHidden) {
    CGFloat lineWidth = titleSize.width + titleInsets.left + titleInsets.right;
    if (showIcon && _iconPosition == CRUIButtonIconPositionLeft) lineWidth += iconSize.width;
    CGFloat x = bounds.origin.x;

    if (_titleAlignment == UITextAlignmentCenter) {
      CGFloat width = size.width - _insets.left - _insets.right;
      if (accessoryImage) width -= accessoryImage.size.width;
      x += roundf(width/2.0 - lineWidth/2.0) + _insets.left;
    } else {
      x += _insets.left;
    }
    if (x < 0) x = 0;

    if (showIcon) {
      if (_iconShadowColor) CGContextSetShadowWithColor(context, CGSizeZero, 5.0, _iconShadowColor.CGColor);
      switch (_iconPosition) {
        case CRUIButtonIconPositionLeft: {
          CGPoint iconTop = CRCGPointToCenter(iconSize, size);
          iconTop.x = x;
          iconTop.y += bounds.origin.y + _insets.top;
          [icon drawInRect:CGRectMake(iconTop.x, iconTop.y, iconSize.width, iconSize.height)];
          x += iconSize.width;
          break;
        }
        case CRUIButtonIconPositionTop: {
          CGPoint iconTop = CRCGPointToCenter(iconSize, size);
          [icon drawInRect:CGRectMake(iconTop.x, _insets.top, iconSize.width, iconSize.height)];
          y = _insets.top + iconSize.height + titleInsets.top;
          break;
        }
        case CRUIButtonIconPositionCenter: {
          CGPoint iconTop = CRCGPointToCenter(iconSize, CGSizeMake(size.width, size.height - titleSize.height));
          if (_iconOrigin.x != CGFLOAT_MAX) iconTop.x = _iconOrigin.x;
          if (_iconOrigin.y != CGFLOAT_MAX) iconTop.y = _iconOrigin.y;
          [icon drawInRect:CGRectMake(iconTop.x, iconTop.y + _insets.top, iconSize.width, iconSize.height)];
          y = iconTop.y + _insets.top + iconSize.height + titleInsets.top;
          break;
        }
      }
      CGContextSetShadowWithColor(context, CGSizeZero, 0.0, NULL);
      showIcon = NO;
    } else if (!CRCGSizeIsZero(iconSize)) {
      if (_iconPosition == CRUIButtonIconPositionLeft) {
        x += iconSize.width;
      }
    }

    [textColor setFill];
    CGContextSetShadowWithColor(context, titleShadowOffset, 0.0, titleShadowColor.CGColor);

    x += titleInsets.left;
    if (y < _insets.top) y = _insets.top + titleInsets.top;

    // Draw title. If we have a secondary title, we'll need to adjust for alignment.
    if (!_secondaryTitle) {
      [title drawInRect:CGRectMake(x, y, titleSize.width, titleSize.height) withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:_titleAlignment];
    } else if (_secondaryTitle) {
      CGSize titleSizeAdjusted = [title sizeWithFont:_titleFont constrainedToSize:titleSize lineBreakMode:UILineBreakModeTailTruncation];
      titleSizeAdjusted = [title drawInRect:CGRectMake(x, y, titleSizeAdjusted.width, titleSizeAdjusted.height) withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:_titleAlignment];
      if (_secondaryTitleColor) [_secondaryTitleColor set];
      if (_secondaryTitleFont) font = _secondaryTitleFont;
      if (_secondaryTitlePosition == CRUIButtonSecondaryTitlePositionDefault) {
        x += titleSizeAdjusted.width;
        [_secondaryTitle drawAtPoint:CGPointMake(x, y) withFont:font];  
      } else if (_secondaryTitlePosition == CRUIButtonSecondaryTitlePositionRightAlign) {
        x += titleSizeAdjusted.width;
        [_secondaryTitle drawInRect:CGRectMake(x, y, size.width - x - _insets.right - _titleInsets.right, size.height) withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
      } else if (_secondaryTitlePosition == CRUIButtonSecondaryTitlePositionBottom) {
        x = _insets.left + titleInsets.left;
        y += titleSizeAdjusted.height + titleInsets.bottom;
        // TODO(gabe): Needed to put "+ _insets.bottom" so secondary text would wrap
        CGRect secondaryTitleRect = CGRectMake(x, y, size.width - x - _insets.right - titleInsets.right, size.height - y + _insets.bottom);
        [_secondaryTitle drawInRect:secondaryTitleRect withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];  
      } else if (_secondaryTitlePosition == CRUIButtonSecondaryTitlePositionBottomLeftSingle) {
        x = _insets.left + titleInsets.left;
        y += titleSizeAdjusted.height;
        CGRect secondaryTitleRect = CGRectMake(x, y, size.width - x - _insets.right - titleInsets.right, 0);
        [_secondaryTitle drawAtPoint:secondaryTitleRect.origin forWidth:secondaryTitleRect.size.width withFont:font lineBreakMode:UILineBreakModeTailTruncation];  
      }
    }
  }

  if (accessoryImage) {
    [accessoryImage drawAtPoint:CRCGPointToRight(accessoryImage.size, CGSizeMake(size.width - 10, bounds.size.height))];
  }

  if (showIcon) {
    if (_iconShadowColor) CGContextSetShadowWithColor(context, CGSizeZero, 3.0, _iconShadowColor.CGColor);
    [icon drawInRect:CRCGRectToCenterInRect(iconSize, bounds)];
    CGContextSetShadowWithColor(context, CGSizeZero, 0.0, NULL);
  }
}

- (void)drawRect:(CGRect)rect {
  [self drawInRect:self.bounds];
}

#pragma mark UIControl

- (BOOL)touchesAllInView:(NSSet */*of UITouch*/)touches withEvent:(UIEvent *)event {
  // If any touch not in button, ignore
  for(UITouch *touch in touches) {
    CGPoint point = [touch locationInView:self];
    if (![self pointInside:point withEvent:event]) return NO;
  }
  return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  BOOL continueTracking = ([self pointInside:[touch locationInView:self] withEvent:event]);
  if (!continueTracking) {
    [self touchesCancelled:[NSSet setWithObject:touch] withEvent:event];
  }
  return continueTracking;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_highlightedEnabled && self.userInteractionEnabled) {
    if (![self touchesAllInView:touches withEvent:event]) return;
    self.highlighted = YES;
    [self setNeedsDisplay];
  }
  [super touchesBegan:touches withEvent:event];
  
  if (_highlightedEnabled && self.userInteractionEnabled) {
    // Force runloop to redraw so highlighted control appears instantly; must come after call to super
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.05]];
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_selectedEnabled && [self touchesAllInView:touches withEvent:event] && self.userInteractionEnabled) {
    self.selected = !self.isSelected;
  }
  
  [super touchesEnded:touches withEvent:event];
  
  if (_highlightedEnabled && self.userInteractionEnabled) {
    // Unhighlight the control in a short while to give it a chance to be drawn highlighted
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
      [self setHighlighted:NO];
      [self setNeedsDisplay];
    });
  }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesCancelled:touches withEvent:event];
  if (_highlightedEnabled && self.userInteractionEnabled) {
    self.highlighted = NO;
    [self setNeedsDisplay];
  }
}

@end
