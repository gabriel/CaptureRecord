//
//  CRCGUtils.h
//
//  Created by Gabriel Handford on 12/30/08.
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
// This file is a modified version of YKCGUtils.

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

// Represents NULL point (CoreGraphics only has CGRectNull)
extern const CGPoint CRCGPointNull;

// Check if point is Null (CoreGraphics only has CGRectIsNull)
extern bool CRCGPointIsNull(CGPoint point);

// Represents NULL size (CoreGraphics only has CGRectNull)
extern const CGSize CRCGSizeNull;

// Check if size is Null (CoreGraphics only has CGRectIsNull)
extern bool CRCGSizeIsNull(CGSize size);

/*!
 Add rounded rect to current context path.
 @param context
 @param rect
 @param strokeWidth Width of stroke (so that we can inset the rect); Since stroke occurs from center of path we need to inset by half the strong amount otherwise the stroke gets clipped.
 @param cornerRadius Corner radius
 */
void CRCGContextAddRoundedRect(CGContextRef context, CGRect rect, CGFloat strokeWidth, CGFloat cornerRadius);

/*!
 Draw rounded rect to current context.
 @param context
 @param rect
 @param fillColor If not NULL, will fill in rounded rect with color
 @param strokeColor Color of stroke
 @param strokeWidth Width of stroke
 @param cornerRadius Radius of rounded corners
 */
void CRCGContextDrawRoundedRect(CGContextRef context, CGRect rect, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius);

/*!
 Draw (fill and/or stroke) path.
 @param context
 @param path
 @param fillColor If not NULL, will fill in rounded rect with color
 @param strokeColor Color of stroke
 @param strokeWidth Width of stroke
 
 */
void CRCGContextDrawPath(CGContextRef context, CGPathRef path, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth);

/*!
 Create rounded rect path.
 @param rect
 @param strokeWidth Width of stroke
 @param cornerRadius Radius of rounded corners
 */
CGPathRef CRCGPathCreateRoundedRect(CGRect rect, CGFloat strokeWidth, CGFloat cornerRadius);

/*!
 Add line from (x, y) to (x2, y2) to context path.
 @param context
 @param x
 @param y
 @param x2
 @param y2
 */
void CRCGContextAddLine(CGContextRef context, CGFloat x, CGFloat y, CGFloat x2, CGFloat y2);

/*!
 Draw line from (x, y) to (x2, y2).
 @param context
 @param x
 @param y
 @param x2
 @param y2
 @param strokeColor Line color
 @param strokeWidth Line width (draw from center of width (x+(strokeWidth/2), y+(strokeWidth/2)))
 */
void CRCGContextDrawLine(CGContextRef context, CGFloat x, CGFloat y, CGFloat x2, CGFloat y2, CGColorRef strokeColor, CGFloat strokeWidth);

/*!
 Draws image inside rounded rect.
 
 @param context Context
 @param image Image to draw
 @param imageSize Image size
 @param rect Rect to draw
 @param strokeColor Stroke color
 @param strokeWidth Stroke size
 @param cornerRadius Corner radius for rounded rect
 @param contentMode Content Mode
 @param backgroundColor If image is smaller than rect (and not scaling image), this background color is used.
 */
void CRCGContextDrawRoundedRectImage(CGContextRef context, CGImageRef image, CGSize imageSize, CGRect rect, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius, UIViewContentMode contentMode, CGColorRef backgroundColor);

/*!
 Draws image inside rounded rect with shadow.
 
 @param context Context
 @param image Image to draw
 @param imageSize Image size
 @param rect Rect to draw
 @param strokeColor Stroke color
 @param strokeWidth Stroke size
 @param cornerRadius Corner radius for rounded rect
 @param contentMode Content Mode
 @param backgroundColor If image is smaller than rect (and not scaling image), this background color is used.
 @param shadowColor Shadow color (or NULL)
 @param shadowBlur Shadow blur amount
 */
void CRCGContextDrawRoundedRectImageWithShadow(CGContextRef context, CGImageRef image, CGSize imageSize, CGRect rect, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius, UIViewContentMode contentMode, CGColorRef backgroundColor, CGColorRef shadowColor, CGFloat shadowBlur);

/*!
 Draws image.
 @param context Context
 @param image Image to draw
 @param imageSize Image size
 @param rect Rect to draw
 @param strokeColor Stroke color
 @param strokeWidth Stroke size
 @param contentMode Content mode
 @param backgroundColor If image is smaller than rect (and not scaling image), this background color is used. 
 */
void CRCGContextDrawImage(CGContextRef context, CGImageRef image, CGSize imageSize, CGRect rect, CGColorRef strokeColor, CGFloat strokeWidth, UIViewContentMode contentMode, CGColorRef backgroundColor);

/*!
 Figure out the rectangle to fit 'size' into 'inSize'.
 @param size
 @param inSize
 @param fill
 */
CGRect CRCGRectScaleAspectAndCenter(CGSize size, CGSize inSize, BOOL fill);

/*!
 Point to place region of size1 into size2, so that its centered.
 @param size1
 @param size2
 */
CGPoint CRCGPointToCenter(CGSize size1, CGSize size2);

/*!
 Point to place region of size1 into size2, so that its centered in Y position.
 */
CGPoint CRCGPointToCenterY(CGSize size, CGSize inSize);

/*!
 Returns if point is zero origin.
 */
BOOL CRCGPointIsZero(CGPoint p);

/*!
 Check if equal.
 @param p1
 @param p2
 */
BOOL CRCGPointIsEqual(CGPoint p1, CGPoint p2);

/*!
 Check if equal.
 @param size1
 @param size2
 */
BOOL CRCGSizeIsEqual(CGSize size1, CGSize size2);

/*!
 Check if size is zero.
 */
BOOL CRCGSizeIsZero(CGSize size);

/*!
 Check if equal within some accuracy.
 @param rect1
 @param rect2
 */
BOOL CRCGRectIsEqual(CGRect rect1, CGRect rect2);

/*!
 Returns a rect that is centered vertically in inRect but horizontally unchanged
 @param rect The inner rect
 @param inRect The rect to center inside of
 */
CGRect CRCGRectToCenterYInRect(CGRect rect, CGRect inRect);

/*!
 @deprecated Behavior of CRCGRectToCenterYInRect is more intuitive
 Returns a rect that is centered vertically in a region with the same size as inRect but horizontally unchanged
 @param rect The inner rect
 @param inRect The rect with the size to center inside of
 */
CGRect CRCGRectToCenterY(CGRect rect, CGRect inRect);

/*!
 TODO(gabe): Document
 */
CGPoint CRCGPointToRight(CGSize size, CGSize inSize);

/*!
 Center size in size.
 @param size Size for element to center
 @param inSize Containing size
 @result Centered on x and y, returning a size same as size (1st argument)
 */
CGRect CRCGRectToCenter(CGSize size, CGSize inSize);

BOOL CRCGSizeIsEmpty(CGSize size);

/*!
 TODO(gabe): Document
 */
CGRect CRCGRectToCenterInRect(CGSize size, CGRect inRect);

/*!
 TODO(gabe): Document
 */
CGFloat CRCGFloatToCenter(CGFloat length, CGFloat inLength, CGFloat min);

/*!
 Adds two rectangles.
 TODO(gabe): Document
 */
CGRect CRCGRectAdd(CGRect rect1, CGRect rect2);


/*!
 Get rect to right align width inside inWidth with maxWidth and padding on the right.
 */
CGRect CRCGRectRightAlign(CGFloat y, CGFloat width, CGFloat inWidth, CGFloat maxWidth, CGFloat padRight, CGFloat height);

/*!
 Right-align rect with inRect.
 If rect's width is larger than withRect, rect.origin.x will be smaller than withRect.origin.x.
 */
CGRect CRCGRectRightAlignWithRect(CGRect rect, CGRect withRect);

/*!
 Copy of CGRect with (x, y) origin set to 0.
 */
CGRect CRCGRectZeroOrigin(CGRect rect);

/*!
 Set size on rect.
 */
CGRect CRCGRectSetSize(CGRect rect, CGSize size);

/*!
 Set height on rect.
 */
CGRect CRCGRectSetHeight(CGRect rect, CGFloat height);

/*
 Set width on rect.
 */
CGRect CRCGRectSetWidth(CGRect rect, CGFloat width);

/*!
 Set x on rect.
 */
CGRect CRCGRectSetX(CGRect rect, CGFloat x);

/*!
 Set y on rect.
 */
CGRect CRCGRectSetY(CGRect rect, CGFloat y);


CGRect CRCGRectSetOrigin(CGRect rect, CGFloat x, CGFloat y);

CGRect CRCGRectSetOriginPoint(CGRect rect, CGPoint p);

CGRect CRCGRectOriginSize(CGPoint origin, CGSize size);

CGRect CRCGRectAddPoint(CGRect rect, CGPoint p);

CGRect CRCGRectAddHeight(CGRect rect, CGFloat height);

CGRect CRCGRectAddX(CGRect rect, CGFloat add);

CGRect CRCGRectAddY(CGRect rect, CGFloat add);

/*!
 Bottom right point in rect. (x + width, y + height).
 */
CGPoint CRCGPointBottomRight(CGRect rect);

CGFloat CRCGDistanceBetween(CGPoint pointA, CGPoint pointB);

/*!
 Returns a rect that is inset inside of size.
 */
CGRect CRCGRectWithInsets(CGSize size, UIEdgeInsets insets);

#pragma mark Border Styles

// Border styles:
// So far only borders for the group text field; And allow you to have top, middle, middle, middle, bottom.
//
//   CRUIBorderStyleNormal
//   -------
//   |     |
//   -------
//
//   CRUIBorderStyleRoundedTop:
//   ╭----╮
//   |     |
//
//
//   CRUIBorderStyleTopLeftRight
//   -------  
//   |     |
//
//  
//   CRUIBorderStyleRoundedBottom
//   -------
//   |     |
//   ╰----╯
//
typedef enum {
  CRUIBorderStyleNone = 0,
  CRUIBorderStyleNormal, // Straight top, right, botton, left
  CRUIBorderStyleRounded, // Rounded top, right, bottom, left
  CRUIBorderStyleTopOnly, // Top (straight) only
  CRUIBorderStyleBottomOnly, // Bottom (straight) only
  CRUIBorderStyleTopBottom, // Top and bottom only
  CRUIBorderStyleRoundedTop, // Rounded top with left and right sides (no bottom)
  CRUIBorderStyleTopLeftRight, // Top, left and right sides (no bottom)
  CRUIBorderStyleBottomLeftRight, // Bottom, left and right sides (no top)
  CRUIBorderStyleRoundedBottom, // Rounded bottom

  CRUIBorderStyleRoundedTopOnly, // Rounded top with no sides
  CRUIBorderStyleRoundedLeftCap, // Rounded left segment
  CRUIBorderStyleRoundedRightCap, // Rounded right segment
  CRUIBorderStyleRoundedBack, // Rounded back button
  
  CRUIBorderStyleRoundedTopWithBotton, // Rounded top with left and right sides (with bottom)
  CRUIBorderStyleRoundedBottomLeftRight, // Rounded bottom (no top)
} CRUIBorderStyle;

CGPathRef CRCGPathCreateStyledRect(CGRect rect, CRUIBorderStyle style, CGFloat strokeWidth, CGFloat cornerRadius);

/*!
 Create path for line.
 @param x1
 @param y1
 @param x2
 @param y2
 */
CGPathRef CRCGPathCreateLine(CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2);

void CRCGContextAddStyledRect(CGContextRef context, CGRect rect, CRUIBorderStyle style, CGFloat strokeWidth, CGFloat cornerRadius);

void CRCGContextDrawBorder(CGContextRef context, CGRect rect, CRUIBorderStyle style, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius);

void CRCGContextDrawBorderWithShadow(CGContextRef context, CGRect rect, CRUIBorderStyle style, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius, CGColorRef shadowColor, CGFloat shadowBlur, BOOL saveRestore);

void CRCGContextDrawRect(CGContextRef context, CGRect rect, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth);

#pragma mark Colors

void CRCGColorGetComponents(CGColorRef color, CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *alpha);

#pragma mark Shading

typedef enum {
  CRUIShadingTypeUnknown = -1,
  CRUIShadingTypeNone = 0,
  CRUIShadingTypeLinear, // Linear color blend (for color to color2)
  CRUIShadingTypeHorizontalEdge, // Horizontal edge (for color to color2 and color3 to color4)
  CRUIShadingTypeHorizontalReverseEdge, // Horizontal edge reversed
  CRUIShadingTypeExponential,
  CRUIShadingTypeMetalEdge,
} CRUIShadingType;

void CRCGContextDrawShadingWithHeight(CGContextRef context, CGColorRef color, CGColorRef color2, CGColorRef color3, CGColorRef color4, CGFloat height, CRUIShadingType shadingType);

void CRCGContextDrawShading(CGContextRef context, CGColorRef color, CGColorRef color2, CGColorRef color3, CGColorRef color4, CGPoint start, CGPoint end, CRUIShadingType shadingType, 
                            BOOL extendStart, BOOL extendEnd);


/*!
 Convert rect for size with content mode.
 @param rect Bounds
 @param size Size of view
 @param contentMode Content mode
 */
CGRect CRCGRectConvert(CGRect rect, CGSize size, UIViewContentMode contentMode);

/*!
 Description for content mode.
 For debugging.
 */
NSString *CRNSStringFromUIViewContentMode(UIViewContentMode contentMode);

/*!
 Scale a CGRect's size while maintaining a fixed center point.
 @param rect CGRect to scale
 @param scale Scale factor by which to increaase the size of the rect
 */
CGRect CRCGRectScaleFromCenter(CGRect rect, CGFloat scale);


void CRCGTransformHSVRGB(float *components);
void CRTransformRGBHSV(float *components);

void CRCGContextDrawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef  endColor);

void CRCGContextDrawLinearGradientWithColors(CGContextRef context, CGRect rect, NSArray */*of CGColorRef*/colors, CGFloat *locations);

UIImage *CRCreateVerticalGradientImage(CGFloat height, CGColorRef topColor, CGColorRef bottomColor);


/*!
 Get a rounded corner mask. For example, for using as a CALayer mask.
 */
UIImage *CRCGContextRoundedMask(CGRect rect, CGFloat cornerRadius);
