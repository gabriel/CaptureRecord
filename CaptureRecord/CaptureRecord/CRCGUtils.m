//
//  CRCGUtils.m
//

#import "CRCGUtils.h"

void _CRCGContextDrawStyledRect(CGContextRef context, CGRect rect, CRUIBorderStyle style, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius);
void _CRCGContextDrawImage(CGContextRef context, CGImageRef image, CGSize imageSize, CGRect rect, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius, UIViewContentMode contentMode, CGColorRef backgroundColor, CGColorRef shadowColor, CGFloat shadowBlur);
void _CRhorizontalEdgeColorBlendFunctionImpl(void *info, const CGFloat *in, CGFloat *out, BOOL reverse);
void _CRmetalEdgeColorBlendFunctionImpl(void *info, const CGFloat *in, CGFloat *out);
void _CRhorizontalEdgeColorBlendFunction(void *info, const CGFloat *in, CGFloat *out);
void _CRhorizontalReverseEdgeColorBlendFunction(void *info, const CGFloat *in, CGFloat *out);
void _CRmetalEdgeColorBlendFunction(void *info, const CGFloat *in, CGFloat *out);
void _CRlinearColorBlendFunction(void *info, const CGFloat *in, CGFloat *out);
void _CRexponentialColorBlendFunction(void *info, const CGFloat *in, CGFloat *out);
void _CRcolorReleaseInfoFunction(void *info);

const CGPoint CRCGPointNull = {CGFLOAT_MAX, CGFLOAT_MAX};

bool CRCGPointIsNull(CGPoint point) {
  return point.x == CRCGPointNull.x && point.y == CRCGPointNull.y;
}

const CGSize CRCGSizeNull = {CGFLOAT_MAX, CGFLOAT_MAX};

bool CRCGSizeIsNull(CGSize size) {
  return size.width == CRCGSizeNull.width && size.height == CRCGSizeNull.height;
}

CGPathRef CRCGPathCreateLine(CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2) {
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, x1, y1);
  CGPathAddLineToPoint(path, NULL, x2, y2);
  return path;
}

CGPathRef CRCGPathCreateRoundedRect(CGRect rect, CGFloat strokeWidth, CGFloat cornerRadius) { 
  
  // TODO: Switch to UIBezierPath?
  // UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
  // return CGPathRetain(path.CGPath);
  
  CGMutablePathRef path = CGPathCreateMutable();
  
  CGFloat fw, fh;
  
  CGRect insetRect = CGRectInset(rect, strokeWidth/2.0f, strokeWidth/2.0f);
  CGFloat cornerWidth = cornerRadius, cornerHeight = cornerRadius;
  
  CGAffineTransform transform = CGAffineTransformIdentity;
  transform = CGAffineTransformTranslate(transform, CGRectGetMinX(insetRect), CGRectGetMinY(insetRect));
  if (cornerWidth > 0 && cornerHeight > 0) {
    transform = CGAffineTransformScale(transform, cornerWidth, cornerHeight);
    fw = CGRectGetWidth(insetRect) / cornerWidth;
    fh = CGRectGetHeight(insetRect) / cornerHeight;
  } else {
    fw = CGRectGetWidth(insetRect);
    fh = CGRectGetHeight(insetRect);
  }
  
  CGPathMoveToPoint(path, &transform, fw, fh/2); 
  CGPathAddArcToPoint(path, &transform, fw, fh, fw/2, fh, 1);
  CGPathAddArcToPoint(path, &transform, 0, fh, 0, fh/2, 1);
  CGPathAddArcToPoint(path, &transform, 0, 0, fw/2, 0, 1);
  CGPathAddArcToPoint(path, &transform, fw, 0, fw, fh/2, 1);  
  CGPathCloseSubpath(path);
  
  return path;
}

void CRCGContextAddRoundedRect(CGContextRef context, CGRect rect, CGFloat strokeWidth, CGFloat cornerRadius) {      
  CGPathRef path = CRCGPathCreateRoundedRect(rect, strokeWidth, cornerRadius);
  CGContextAddPath(context, path);  
  CGPathRelease(path);
}

void CRCGContextDrawPath(CGContextRef context, CGPathRef path, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth) { 
  if (fillColor != NULL) CGContextSetFillColorWithColor(context, fillColor);  
  if (strokeColor != NULL) CGContextSetStrokeColorWithColor(context, strokeColor);    
  CGContextSetLineWidth(context, strokeWidth);
  CGContextAddPath(context, path);
  if (strokeColor != NULL && fillColor != NULL) CGContextDrawPath(context, kCGPathFillStroke);
  else if (strokeColor == NULL && fillColor != NULL) CGContextDrawPath(context, kCGPathFill);
  else if (strokeColor != NULL && fillColor == NULL) CGContextDrawPath(context, kCGPathStroke);
}

void CRCGContextDrawRoundedRect(CGContextRef context, CGRect rect, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius) {   
  CGPathRef path = CRCGPathCreateRoundedRect(rect, strokeWidth, cornerRadius);
  CRCGContextDrawPath(context, path, fillColor, strokeColor, strokeWidth);
  CGPathRelease(path);
}

void CRCGContextAddLine(CGContextRef context, CGFloat x, CGFloat y, CGFloat x2, CGFloat y2) {
  CGContextMoveToPoint(context, x, y);
  CGContextAddLineToPoint(context, x2, y2);
}

void CRCGContextDrawLine(CGContextRef context, CGFloat x, CGFloat y, CGFloat x2, CGFloat y2, CGColorRef strokeColor, CGFloat strokeWidth) {
  CGContextBeginPath(context);  
  CRCGContextAddLine(context, x, y, x2, y2);
  if (strokeColor != NULL) CGContextSetStrokeColorWithColor(context, strokeColor);
  CGContextSetLineWidth(context, strokeWidth);
  CGContextStrokePath(context);   
}

void CRCGContextDrawImage(CGContextRef context, CGImageRef image, CGSize imageSize, CGRect rect, CGColorRef strokeColor, CGFloat strokeWidth, 
                          UIViewContentMode contentMode, CGColorRef backgroundColor) { 
  _CRCGContextDrawImage(context, image, imageSize, rect, strokeColor, strokeWidth, 0.0, contentMode, backgroundColor, NULL, 0);
}

void CRCGContextDrawRoundedRectImage(CGContextRef context, CGImageRef image, CGSize imageSize, CGRect rect, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius, UIViewContentMode contentMode, CGColorRef backgroundColor) {
  CRCGContextDrawRoundedRectImageWithShadow(context, image, imageSize, rect, strokeColor, strokeWidth, cornerRadius, contentMode, backgroundColor, NULL, 0);
}

void CRCGContextDrawRoundedRectImageWithShadow(CGContextRef context, CGImageRef image, CGSize imageSize, CGRect rect, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius, UIViewContentMode contentMode, CGColorRef backgroundColor, CGColorRef shadowColor, CGFloat shadowBlur) {  
  CGContextSaveGState(context);
  _CRCGContextDrawImage(context, image, imageSize, rect, strokeColor, strokeWidth, cornerRadius, contentMode, backgroundColor, shadowColor, shadowBlur);
  CGContextRestoreGState(context);
}

void _CRCGContextDrawImage(CGContextRef context, CGImageRef image, CGSize imageSize, CGRect rect, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius, UIViewContentMode contentMode, CGColorRef backgroundColor, CGColorRef shadowColor, CGFloat shadowBlur) {
  
  // Clip for rounded corners
  if (cornerRadius > 0) {
    CRCGContextAddRoundedRect(context, rect, 0, cornerRadius);
    CGContextClip(context);
  }
  
  // Fill background color
  if (backgroundColor != NULL) {
    CGContextSetFillColorWithColor(context, backgroundColor);
    CGContextFillRect(context, rect);
  }
  
  CGRect imageBounds = CRCGRectConvert(rect, imageSize, contentMode);
  if (image == NULL) imageBounds = rect;

  if (image != NULL) {
    CGContextSaveGState(context);
    // Clip the context so the image doesn't interact with the corner rendering
    if (strokeWidth > 0 && cornerRadius > 0) {
      CRCGContextAddRoundedRect(context, rect, strokeWidth, cornerRadius);
      CGContextClip(context);
    }
    // Flip coordinate system, otherwise image will be drawn upside down
    CGContextTranslateCTM (context, 0, imageBounds.size.height);
    CGContextScaleCTM (context, 1.0, -1.0);   
    imageBounds.origin.y *= -1; // Going opposite direction
    CGContextDrawImage(context, imageBounds, image);
    CGContextRestoreGState(context);
  }
  
  if (shadowColor != NULL) {
    CRCGContextDrawBorderWithShadow(context, rect, CRUIBorderStyleRounded, NULL, strokeColor, strokeWidth, cornerRadius, shadowColor, shadowBlur, YES);
  } else if (strokeColor != NULL && strokeWidth > 0) {    
    CRCGContextDrawRoundedRect(context, rect, NULL, strokeColor, strokeWidth, cornerRadius);
  }
}

CGRect CRCGRectScaleAspectAndCenter(CGSize size, CGSize inSize, BOOL fill) {
  if (CRCGSizeIsEmpty(size)) return CGRectZero;
  
  CGRect rect;
  CGFloat widthScaleRatio = inSize.width / size.width;
  CGFloat heightScaleRatio = inSize.height / size.height;
  
  if (widthScaleRatio < heightScaleRatio) {
    if (fill) {
      CGFloat height = inSize.height;
      CGFloat width = roundf(size.width * heightScaleRatio);
      CGFloat x = roundf((inSize.width - width) / 2.0);
      rect = CGRectMake(x, 0, width, height);
    } else {    
      CGFloat height = roundf(size.height * widthScaleRatio);
      CGFloat y = roundf((inSize.height / 2.0) - (height / 2.0));
      rect = CGRectMake(0, y, inSize.width, height);
    }
  } else {
    if (fill) {
      CGFloat width = inSize.width;
      CGFloat height = roundf(size.height * widthScaleRatio);
      CGFloat y = roundf((inSize.height - height) / 2.0);
      rect = CGRectMake(0, y, width, height);
    } else { 
      CGFloat width = roundf(size.width * heightScaleRatio);
      CGFloat x = roundf((inSize.width / 2.0) - (width / 2.0));
      rect = CGRectMake(x, 0, width, inSize.height);
    }
  }
  return rect;
}

#define CRCGIsEqualWithAccuracy(n1, n2, accuracy) (n1 >= (n2-accuracy) && n1 <= (n2+accuracy))

BOOL CRCGPointIsZero(CGPoint p) {
  return (CRCGIsEqualWithAccuracy(p.x, 0, 0.0001) && CRCGIsEqualWithAccuracy(p.y, 0, 0.0001));
}

BOOL CRCGPointIsEqual(CGPoint p1, CGPoint p2) {
  return (CRCGIsEqualWithAccuracy(p1.x, p2.x, 0.0001) && CRCGIsEqualWithAccuracy(p1.y, p2.y, 0.0001));
}

BOOL CRCGRectIsEqual(CGRect rect1, CGRect rect2) {
  return (CRCGPointIsEqual(rect1.origin, rect2.origin) && CRCGSizeIsEqual(rect1.size, rect2.size));  
}

CGPoint CRCGPointToCenterY(CGSize size, CGSize inSize) {
  CGPoint p = CGPointMake(0, roundf((inSize.height - size.height) / 2.0f));
  if (p.y < 0.0f) p.y = 0.0f;
  return p;
}

CGPoint CRCGPointToCenter(CGSize size, CGSize inSize) {
  // We round otherwise views will anti-alias
  CGPoint p = CGPointMake(roundf((inSize.width - size.width) / 2.0), roundf((inSize.height - size.height) / 2.0f));
  // Allowing negative values here allows us to center a larger view on a smaller view.
  // Though set to 0 if inSize.height was 0
  if (inSize.height == 0.0f) p.y = 0.0f;
  return p;
}

CGPoint CRCGPointToRight(CGSize size, CGSize inSize) {
  CGPoint p = CGPointMake(inSize.width - size.width, roundf(inSize.height / 2.0 - size.height / 2.0));
  if (p.x < 0) p.x = 0;
  if (p.y < 0) p.y = 0;
  return p;
}

BOOL CRCGSizeIsEqual(CGSize size1, CGSize size2) {
  return (CRCGIsEqualWithAccuracy(size1.height, size2.height, 0.0001) && CRCGIsEqualWithAccuracy(size1.width, size2.width, 0.0001));
}

BOOL CRCGSizeIsZero(CGSize size) {
  return (size.width == 0 && size.height == 0);
}

BOOL CRCGSizeIsEmpty(CGSize size) {
  return (CRCGIsEqualWithAccuracy(size.height, 0, 0.0001) && CRCGIsEqualWithAccuracy(size.width, 0, 0.0001));
}

CGRect CRCGRectToCenter(CGSize size, CGSize inSize) {
  CGPoint p = CRCGPointToCenter(size, inSize);
  return CGRectMake(p.x, p.y, size.width, size.height);
}

CGRect CRCGRectToCenterInRect(CGSize size, CGRect inRect) {
  CGPoint p = CRCGPointToCenter(size, inRect.size);
  return CGRectMake(p.x + inRect.origin.x, p.y + inRect.origin.y, size.width, size.height);
}

CGRect CRCGRectToCenterY(CGRect rect, CGRect inRect) {
  CGPoint centeredPoint = CRCGPointToCenter(rect.size, inRect.size);
  return CRCGRectSetY(rect, centeredPoint.y);
}

CGRect CRCGRectToCenterYInRect(CGRect rect, CGRect inRect) {
  CGPoint p = CRCGPointToCenterY(rect.size, inRect.size);
  return CRCGRectSetY(rect, p.y + inRect.origin.y);
}

CGFloat CRCGFloatToCenter(CGFloat length, CGFloat inLength, CGFloat min) {
  CGFloat pos = roundf(inLength / 2.0 - length / 2.0);
  if (pos < min) pos = min;
  return pos;
}

CGRect CRCGRectAdd(CGRect rect1, CGRect rect2) {
  return CGRectMake(rect1.origin.x + rect2.origin.x, rect1.origin.y + rect2.origin.y, rect1.size.width + rect2.size.width, rect1.size.height + rect2.size.height);
}

CGRect CRCGRectRightAlign(CGFloat y, CGFloat width, CGFloat inWidth, CGFloat maxWidth, CGFloat padRight, CGFloat height) {
  if (width > maxWidth) width = maxWidth;
  CGFloat x = (inWidth - width - padRight);
  return CGRectMake(x, y, width, height);
}

CGRect CRCGRectRightAlignWithRect(CGRect rect, CGRect inRect) {
  CGFloat x = inRect.origin.x + inRect.size.width - rect.size.width;
  return CGRectMake(x, rect.origin.y, rect.size.width, rect.size.height);
}

CGRect CRCGRectZeroOrigin(CGRect rect) {
  return CGRectMake(0, 0, rect.size.width, rect.size.height);
}

CGRect CRCGRectSetSize(CGRect rect, CGSize size) {
  rect.size = size;
  return rect;
}

CGRect CRCGRectSetHeight(CGRect rect, CGFloat height) {
  rect.size.height = height;
  return rect;  
}

CGRect CRCGRectAddHeight(CGRect rect, CGFloat add) {
  rect.size.height += add;
  return rect;  
}

CGRect CRCGRectAddX(CGRect rect, CGFloat add) {
  rect.origin.x += add;
  return rect;  
}

CGRect CRCGRectAddY(CGRect rect, CGFloat add) {
  rect.origin.y += add;
  return rect;  
}

CGRect CRCGRectSetWidth(CGRect rect, CGFloat width) {
  rect.size.width = width;
  return rect;  
}

CGRect CRCGRectSetOrigin(CGRect rect, CGFloat x, CGFloat y) {
  rect.origin = CGPointMake(x, y);
  return rect;
}

CGRect CRCGRectSetX(CGRect rect, CGFloat x) {
  rect.origin.x = x;
  return rect;
}

CGRect CRCGRectSetY(CGRect rect, CGFloat y) {
  rect.origin.y = y;
  return rect;
}

CGRect CRCGRectSetOriginPoint(CGRect rect, CGPoint p) {
  rect.origin = p;
  return rect;
}

CGRect CRCGRectOriginSize(CGPoint origin, CGSize size) {
  CGRect rect;
  rect.origin = origin;
  rect.size = size;
  return rect;
}

CGRect CRCGRectAddPoint(CGRect rect, CGPoint p) {
  rect.origin.x += p.x;
  rect.origin.y += p.y;
  return rect;
}

CGPoint CRCGPointBottomRight(CGRect rect) {
  return CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
}

CGFloat CRCGDistanceBetween(CGPoint pointA, CGPoint pointB) {
  CGFloat dx = pointB.x - pointA.x;
  CGFloat dy = pointB.y - pointA.y;
  return sqrt(dx*dx + dy*dy);
}

CGRect CRCGRectWithInsets(CGSize size, UIEdgeInsets insets) {
  CGRect rect = CGRectZero;
  rect.origin.x = insets.left;
  rect.origin.y = insets.top;
  rect.size.width = size.width - insets.left - insets.right;
  rect.size.height = size.height - insets.top - insets.bottom;
  return rect;
}

#pragma mark Border Styles

void CRCGContextAddStyledRect(CGContextRef context, CGRect rect, CRUIBorderStyle style, CGFloat strokeWidth, CGFloat cornerRadius) {  
  CGPathRef path = CRCGPathCreateStyledRect(rect, style, strokeWidth, cornerRadius);
  if (path != NULL) {
    CGContextAddPath(context, path);  
  }
  CGPathRelease(path);
}

CGPathRef CRCGPathCreateStyledRect(CGRect rect, CRUIBorderStyle style, CGFloat strokeWidth, CGFloat cornerRadius) {  
  
  CGFloat fw, fh;
  CGFloat cornerWidth = cornerRadius, cornerHeight = cornerRadius;
  
  if (style == CRUIBorderStyleNone) return NULL;

  // Handle case where we have 0 corner radius
  if (cornerRadius == 0 && style == CRUIBorderStyleRounded) {
    style = CRUIBorderStyleNormal;
  }

  if (style == CRUIBorderStyleRounded) {
    return CRCGPathCreateRoundedRect(rect, strokeWidth, cornerRadius);
  }
  
  CGFloat strokeInset = strokeWidth/2.0f;
  
  // Need to adjust path rect to inset (since the stroke is drawn from the middle of the path)
  CGRect insetBounds;
  switch(style) {
      // Borders with only bottom and sides
    case CRUIBorderStyleBottomLeftRight:
    case CRUIBorderStyleRoundedBottomLeftRight:
      insetBounds = CGRectMake(rect.origin.x + strokeInset, rect.origin.y, rect.size.width - (strokeInset * 2), rect.size.height - strokeInset);
      break;
      
    // Borders with only top and sides
    case CRUIBorderStyleRoundedTop:
    case CRUIBorderStyleRoundedTopOnly:
    case CRUIBorderStyleTopLeftRight:
      insetBounds = CGRectMake(rect.origin.x + strokeInset, rect.origin.y + strokeInset, rect.size.width - (strokeInset * 2), rect.size.height - strokeInset);
      break;      
      
    // Borders with only top
    case CRUIBorderStyleTopOnly:
      insetBounds = CGRectMake(rect.origin.x, rect.origin.y + strokeInset, rect.size.width, rect.size.height - strokeInset);
      break;
      
    // Borders with only top and bottom
    case CRUIBorderStyleTopBottom:
      insetBounds = CGRectMake(rect.origin.x, rect.origin.y + strokeInset, rect.size.width, rect.size.height - (strokeInset * 2));
      break;
      
    // Borders with only bottom
    case CRUIBorderStyleBottomOnly:
      insetBounds = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height - strokeInset);
      break;
      
    // Borders with all 4 sides
    case CRUIBorderStyleNormal:
    case CRUIBorderStyleRounded:
    case CRUIBorderStyleRoundedBottom:
    case CRUIBorderStyleRoundedTopWithBotton:
    case CRUIBorderStyleRoundedLeftCap:
    case CRUIBorderStyleRoundedRightCap:
    case CRUIBorderStyleRoundedBack:
      insetBounds = CGRectMake(rect.origin.x + strokeInset, rect.origin.y + strokeInset, rect.size.width - (strokeInset * 2), rect.size.height - (strokeInset * 2));
      break;  
          
    case CRUIBorderStyleNone:
      insetBounds = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
      break;
  }
  rect = insetBounds;
  
  CGAffineTransform transform = CGAffineTransformIdentity;
  transform = CGAffineTransformTranslate(transform, CGRectGetMinX(rect), CGRectGetMinY(rect));
  if (cornerWidth > 0 && cornerHeight > 0) {
    transform = CGAffineTransformScale(transform, cornerWidth, cornerHeight);
    fw = CGRectGetWidth(rect) / cornerWidth;
    fh = CGRectGetHeight(rect) / cornerHeight;
  } else {
    fw = CGRectGetWidth(rect);
    fh = CGRectGetHeight(rect);
  }
  
  CGMutablePathRef path = CGPathCreateMutable();
  
  switch(style) {
    case CRUIBorderStyleRoundedBottom:
      CGPathMoveToPoint(path, &transform, -strokeInset, 0); // Fill in missing line end cap
      CGPathAddLineToPoint(path, &transform, fw, 0);
      CGPathAddLineToPoint(path, &transform, fw, fh/2);
      CGPathAddArcToPoint(path, &transform, fw, fh, fw/2, fh, 1);
      CGPathAddArcToPoint(path, &transform, 0, fh, 0, fh/2, 1);
      CGPathAddLineToPoint(path, &transform, 0, 0);
      CGPathMoveToPoint(path, &transform, fw, 0);
      break;
      
    case CRUIBorderStyleRoundedTop:
      CGPathMoveToPoint(path, &transform, 0, fh);
      CGPathAddLineToPoint(path, &transform, 0, fh/2);
      CGPathAddArcToPoint(path, &transform, 0, 0, fw/2, 0, 1);
      CGPathAddArcToPoint(path, &transform, fw, 0, fw, fh/2, 1);      
      CGPathAddLineToPoint(path, &transform, fw, fh);
      CGPathMoveToPoint(path, &transform, 0, fh); // Don't draw bottom border
      break;
      
    case CRUIBorderStyleRoundedTopWithBotton:
      CGPathMoveToPoint(path, &transform, 0, fh);
      CGPathAddLineToPoint(path, &transform, 0, fh/2);
      CGPathAddArcToPoint(path, &transform, 0, 0, fw/2, 0, 1);
      CGPathAddArcToPoint(path, &transform, fw, 0, fw, fh/2, 1);      
      CGPathAddLineToPoint(path, &transform, fw, fh);
      CGPathAddLineToPoint(path, &transform, 0, fh);
      break;
      
    case CRUIBorderStyleRoundedTopOnly:
      CGPathMoveToPoint(path, &transform, 0, 1);
      CGPathAddArcToPoint(path, &transform, 0, 0, fw/2, 0, 1);
      CGPathAddArcToPoint(path, &transform, fw, 0, fw, fh/2, 1);
      CGPathMoveToPoint(path, &transform, fw, fh);
      break;
      
    case CRUIBorderStyleTopOnly:
      CGPathMoveToPoint(path, &transform, fw, 0);
      CGPathAddLineToPoint(path, &transform, 0, 0);
      break;
      
    case CRUIBorderStyleBottomOnly:
      CGPathMoveToPoint(path, &transform, fw, fh);
      CGPathAddLineToPoint(path, &transform, 0, fh);
      break;
      
    case CRUIBorderStyleTopBottom:
      CGPathMoveToPoint(path, &transform, 0, 0);
      CGPathAddLineToPoint(path, &transform, fw, 0);
      CGPathMoveToPoint(path, &transform, fw, fh);
      CGPathAddLineToPoint(path, &transform, 0, fh);
      break;
      
    case CRUIBorderStyleTopLeftRight:
      CGPathMoveToPoint(path, &transform, 0, fh);
      CGPathAddLineToPoint(path, &transform, 0, 0);
      CGPathAddLineToPoint(path, &transform, fw, 0);
      CGPathAddLineToPoint(path, &transform, fw, fh);
      break;
      
    case CRUIBorderStyleBottomLeftRight:
      CGPathMoveToPoint(path, &transform, fw, 0);
      CGPathAddLineToPoint(path, &transform, fw, fh);
      CGPathAddLineToPoint(path, &transform, 0, fh);
      CGPathAddLineToPoint(path, &transform, 0, 0);
      break;
      
    case CRUIBorderStyleRoundedBottomLeftRight:
      CGPathMoveToPoint(path, &transform, fw, 0);
      CGPathAddLineToPoint(path, &transform, fw, fh/2);
      CGPathAddArcToPoint(path, &transform, fw, fh, fw/2, fh, 1);
      CGPathAddArcToPoint(path, &transform, 0, fh, 0, fh/2, 1);
      CGPathAddLineToPoint(path, &transform, 0, 0);      
      CGPathMoveToPoint(path, &transform, fw, 0);
      break;
      
    case CRUIBorderStyleNormal:
      CGPathMoveToPoint(path, &transform, 0, fh + strokeInset); // Fill in missing line end cap
      CGPathAddLineToPoint(path, &transform, 0, 0);
      CGPathAddLineToPoint(path, &transform, fw, 0);      
      CGPathAddLineToPoint(path, &transform, fw, fh);
      CGPathAddLineToPoint(path, &transform, 0, fh);
      break;
      
    case CRUIBorderStyleRoundedLeftCap:
      CGPathMoveToPoint(path, &transform, 0, fh/2);
      CGPathAddArcToPoint(path, &transform, 0, 0, fw/2, 0, 1);
      CGPathAddLineToPoint(path, &transform, fw, 0);
      CGPathAddLineToPoint(path, &transform, fw, fh);
      CGPathAddLineToPoint(path, &transform, fw/2, fh);
      CGPathAddArcToPoint(path, &transform, 0, fh, 0, fh/2, 1);
      CGPathAddLineToPoint(path, &transform, 0, fh/2);
      break;
      
    case CRUIBorderStyleRoundedRightCap:
      CGPathMoveToPoint(path, &transform, 0, fh);
      CGPathAddLineToPoint(path, &transform, 0, 0);
      CGPathAddLineToPoint(path, &transform, fw/2, 0);
      CGPathAddArcToPoint(path, &transform, fw, 0, fw, fh/2, 1);
      CGPathAddArcToPoint(path, &transform, fw, fh, fw/2, fh, 1);
      CGPathAddLineToPoint(path, &transform, 0, fh);
      break;

    case CRUIBorderStyleRoundedBack: {
      CGFloat px = 2.5; // TODO(gabe): Magic pixel math
        
      CGPathMoveToPoint(path, &transform, fw/2.0f, fh);
      CGPathAddArcToPoint(path, &transform, px, fh, 0, fh/2.0f, 1);
      CGPathAddLineToPoint(path, &transform, 0, fh/2.0f);
      //CGPathAddArcToPoint(path, &transform, 0, fh/2.0f + 1, 0, fh/2.0f - 1, 1);
      CGPathAddArcToPoint(path, &transform, px, 0, fw/2.0f, 0, 1);
      CGPathAddArcToPoint(path, &transform, fw, 0, fw, fh/2.0f, 1);
      CGPathAddArcToPoint(path, &transform, fw, fh, fw/2.0f, fh, 1);
      CGPathCloseSubpath(path);
      }
      break;
      
    case CRUIBorderStyleRounded:
      // Drawn in different method
      break;
      
    case CRUIBorderStyleNone:
      break;
  }
  
  return path;
}

void _CRCGContextDrawStyledRect(CGContextRef context, CGRect rect, CRUIBorderStyle style, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius) {

  // If style is not a complete path, then we need to fill the rect as a separate operation
  if (fillColor != NULL && (style == CRUIBorderStyleTopOnly || style == CRUIBorderStyleBottomOnly || style == CRUIBorderStyleTopBottom)) {
    if (fillColor != NULL) CGContextSetFillColorWithColor(context, fillColor);
    CGContextFillRect(context, rect);
    fillColor = NULL;
  }
  
  CGContextSetLineWidth(context, strokeWidth);

  CRCGContextAddStyledRect(context, rect, style, strokeWidth, cornerRadius); 
  
  if (strokeColor != NULL) CGContextSetStrokeColorWithColor(context, strokeColor);  
  if (fillColor != NULL) CGContextSetFillColorWithColor(context, fillColor);
  
  if (fillColor != NULL && strokeColor != NULL) {     
    CGContextDrawPath(context, kCGPathFillStroke);
  } else if (strokeColor != NULL) {
    CGContextDrawPath(context, kCGPathStroke);
  } else if (fillColor != NULL) {
    CGContextDrawPath(context, kCGPathFill);
  } 
}

void CRCGContextDrawBorder(CGContextRef context, CGRect rect, CRUIBorderStyle style, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius) {  
  _CRCGContextDrawStyledRect(context, rect, style, fillColor, strokeColor, strokeWidth, cornerRadius);
}

void CRCGContextDrawBorderWithShadow(CGContextRef context, CGRect rect, CRUIBorderStyle style, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth, CGFloat cornerRadius, CGColorRef shadowColor, CGFloat shadowBlur, BOOL saveRestore) {
  if (saveRestore) CGContextSaveGState(context);
  CGContextSetShadowWithColor(context, CGSizeZero, shadowBlur, shadowColor);
  CRCGContextDrawBorder(context, rect, style, fillColor, strokeColor, strokeWidth, cornerRadius);
  if (saveRestore) CGContextRestoreGState(context);
}

void CRCGContextDrawRect(CGContextRef context, CGRect rect, CGColorRef fillColor, CGColorRef strokeColor, CGFloat strokeWidth) {
  _CRCGContextDrawStyledRect(context, rect, CRUIBorderStyleNormal, fillColor, strokeColor, strokeWidth, 1);
}

#pragma mark Colors

void CRCGColorGetComponents(CGColorRef color, CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *alpha) {
  const CGFloat *components = CGColorGetComponents(color);
  *red = *green = *blue = 0.0;
  *alpha = 1.0;
  size_t num = CGColorGetNumberOfComponents(color);
  if (num <= 2) {
    *red = components[0];
    *green = components[0];
    *blue = components[0];
    if (num == 2) *alpha = components[1];
  } else if (num >= 3) {
    *red = components[0];
    *green = components[1];
    *blue = components[2];
    if (num >= 4) *alpha = components[3];
  }
}

#pragma mark Shading

//
// Portions adapted from:
// http://wilshipley.com/blog/2005/07/pimp-my-code-part-3-gradient.html
//


// For shading
typedef struct {
  CGFloat red1, green1, blue1, alpha1;
  CGFloat red2, green2, blue2, alpha2;
  CGFloat red3, green3, blue3, alpha3;
  CGFloat red4, green4, blue4, alpha4;
} _CRUIColors;

void _CRhorizontalEdgeColorBlendFunctionImpl(void *info, const CGFloat *in, CGFloat *out, BOOL reverse) {
  _CRUIColors *colors = (_CRUIColors *)info;
  
  float v = *in;
  if ((!reverse && v < 0.5) || (reverse && v >= 0.5)) {
    v = (v * 2.0) * 0.3 + 0.6222;
    *out++ = 1.0 - v + colors->red1 * v;
    *out++ = 1.0 - v + colors->green1 * v;
    *out++ = 1.0 - v + colors->blue1 * v;
    *out++ = 1.0 - v + colors->alpha1 * v;
  } else {
    *out++ = colors->red2;
    *out++ = colors->green2;
    *out++ = colors->blue2;
    *out++ = colors->alpha2;
  }
}

void _CRmetalEdgeColorBlendFunctionImpl(void *info, const CGFloat *in, CGFloat *out) {
  _CRUIColors *colors = (_CRUIColors *)info;
  
  float v = *in;
  if (v < 0.5) {
    v = (v * 2.0);
    *out++ = (v * colors->red2) + (1 - v) * colors->red1;
    *out++ = (v * colors->green2) + (1 - v) * colors->green1;
    *out++ = (v * colors->blue2) + (1 - v) * colors->blue1;
    *out++ = (v * colors->alpha2) + (1 - v) * colors->alpha1;
  } else {
    v = ((v - 0.5) * 2.0);
    *out++ = (v * colors->red4) + (1 - v) * colors->red3;
    *out++ = (v * colors->green4) + (1 - v) * colors->green3;
    *out++ = (v * colors->blue4) + (1 - v) * colors->blue3;
    *out++ = (v * colors->alpha4) + (1 - v) * colors->alpha3;
  }
}

void _CRhorizontalEdgeColorBlendFunction(void *info, const CGFloat *in, CGFloat *out) {
  _CRhorizontalEdgeColorBlendFunctionImpl(info, in, out, NO);
}

void _CRhorizontalReverseEdgeColorBlendFunction(void *info, const CGFloat *in, CGFloat *out) {
  _CRhorizontalEdgeColorBlendFunctionImpl(info, in, out, YES);
}

void _CRmetalEdgeColorBlendFunction(void *info, const CGFloat *in, CGFloat *out) {
  _CRmetalEdgeColorBlendFunctionImpl(info, in, out);
}

void _CRlinearColorBlendFunction(void *info, const CGFloat *in, CGFloat *out) {
  _CRUIColors *colors = info;
  
  out[0] = (1.0 - *in) * colors->red1 + *in * colors->red2;
  out[1] = (1.0 - *in) * colors->green1 + *in * colors->green2;
  out[2] = (1.0 - *in) * colors->blue1 + *in * colors->blue2;
  out[3] = (1.0 - *in) * colors->alpha1 + *in * colors->alpha2;
}

void _CRexponentialColorBlendFunction(void *info, const CGFloat *in, CGFloat *out) {
  _CRUIColors *colors = info;
  float amount1 = (1.0 - powf(*in, 2));
  float amount2 = (1.0 - amount1);
  
  out[0] = (amount1 * colors->red1) + (amount2 * colors->red2);
  out[1] = (amount1 * colors->green1) + (amount2 * colors->green2);
  out[2] = (amount1 * colors->blue1) + (amount2 * colors->blue2);
  out[3] = (amount1 * colors->alpha1) + (amount2 * colors->alpha2);
}

void _CRcolorReleaseInfoFunction(void *info) {
  free(info);
}

static const CGFunctionCallbacks CRlinearFunctionCallbacks = {0, &_CRlinearColorBlendFunction, &_CRcolorReleaseInfoFunction};
static const CGFunctionCallbacks CRhorizontalEdgeFunctionCallbacks = {0, &_CRhorizontalEdgeColorBlendFunction, &_CRcolorReleaseInfoFunction};
static const CGFunctionCallbacks CRhorizontalReverseEdgeFunctionCallbacks = {0, &_CRhorizontalReverseEdgeColorBlendFunction, &_CRcolorReleaseInfoFunction};
static const CGFunctionCallbacks CRexponentialFunctionCallbacks = {0, &_CRexponentialColorBlendFunction, &_CRcolorReleaseInfoFunction};
static const CGFunctionCallbacks CRmetalEdgeFunctionCallbacks = {0, &_CRmetalEdgeColorBlendFunction, &_CRcolorReleaseInfoFunction};

void CRCGContextDrawShadingWithHeight(CGContextRef context, CGColorRef color, CGColorRef color2, CGColorRef color3, CGColorRef color4, CGFloat height, CRUIShadingType shadingType) {
  CRCGContextDrawShading(context, color, color2, color3, color4, CGPointMake(0, 0), CGPointMake(0, height), shadingType, YES, YES);
}

void CRCGContextDrawShading(CGContextRef context, CGColorRef color, CGColorRef color2, CGColorRef color3, CGColorRef color4, CGPoint start, CGPoint end, CRUIShadingType shadingType, 
                            BOOL extendStart, BOOL extendEnd) {
  
  const CGFunctionCallbacks *callbacks;
  
  switch (shadingType) {
    case CRUIShadingTypeHorizontalEdge:
      callbacks = &CRhorizontalEdgeFunctionCallbacks;
      break;      
    case CRUIShadingTypeHorizontalReverseEdge:
      callbacks = &CRhorizontalReverseEdgeFunctionCallbacks;
      break;
    case CRUIShadingTypeLinear:
      callbacks = &CRlinearFunctionCallbacks;
      break;
    case CRUIShadingTypeExponential:
      callbacks = &CRexponentialFunctionCallbacks;
      break;
    case CRUIShadingTypeMetalEdge:
      callbacks = &CRmetalEdgeFunctionCallbacks;
      break;
    default:
      return;
  }  
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  
  _CRUIColors *colors = malloc(sizeof(_CRUIColors));
  
  CRCGColorGetComponents(color, &colors->red1, &colors->green1, &colors->blue1, &colors->alpha1);
  CRCGColorGetComponents((color2 != NULL ? color2 : color), &colors->red2, &colors->green2, &colors->blue2, &colors->alpha2);
  if (color3 != NULL) {
    CRCGColorGetComponents(color3, &colors->red3, &colors->green3, &colors->blue3, &colors->alpha3);
  }
  if (color4 != NULL) {
    CRCGColorGetComponents(color4, &colors->red4, &colors->green4, &colors->blue4, &colors->alpha4);
  }
  
  static const CGFloat domainAndRange[8] = {0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0};
  
  CGFunctionRef blendFunctionRef = CGFunctionCreate(colors, 1, domainAndRange, 4, domainAndRange, callbacks);
  CGShadingRef shading = CGShadingCreateAxial(colorSpace, start, end, blendFunctionRef, extendStart, extendEnd);
  CGContextDrawShading(context, shading);
  CGShadingRelease(shading);
  CGFunctionRelease(blendFunctionRef);
  CGColorSpaceRelease(colorSpace);
}

// From Three20: UIImageAdditions#convertRect
// https://github.com/facebook/three20/blob/master/src/Three20Style/Sources/UIImageAdditions.m
CGRect CRCGRectConvert(CGRect rect, CGSize size, UIViewContentMode contentMode) {
  if (size.width != rect.size.width || size.height != rect.size.height) {
    if (contentMode == UIViewContentModeLeft) {
      return CGRectMake(rect.origin.x,
                        rect.origin.y + floor(rect.size.height/2 - size.height/2),
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeRight) {
      return CGRectMake(rect.origin.x + (rect.size.width - size.width),
                        rect.origin.y + floor(rect.size.height/2 - size.height/2),
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeTop) {
      return CGRectMake(rect.origin.x + floor(rect.size.width/2 - size.width/2),
                        rect.origin.y,
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeBottom) {
      return CGRectMake(rect.origin.x + floor(rect.size.width/2 - size.width/2),
                        rect.origin.y + floor(rect.size.height - size.height),
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeCenter) {
      return CGRectMake(rect.origin.x + floor(rect.size.width/2 - size.width/2),
                        rect.origin.y + floor(rect.size.height/2 - size.height/2),
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeBottomLeft) {
      return CGRectMake(rect.origin.x,
                        rect.origin.y + floor(rect.size.height - size.height),
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeBottomRight) {
      return CGRectMake(rect.origin.x + (rect.size.width - size.width),
                        rect.origin.y + (rect.size.height - size.height),
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeTopLeft) {
      return CGRectMake(rect.origin.x,
                        rect.origin.y,                        
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeTopRight) {
      return CGRectMake(rect.origin.x + (rect.size.width - size.width),
                        rect.origin.y,
                        size.width, size.height);
    } else if (contentMode == UIViewContentModeScaleAspectFill) {
      CGSize imageSize = size;
      CGFloat imageRatio = imageSize.width / imageSize.height;
      CGFloat rectRatio = rect.size.width / rect.size.height;
      if (imageRatio > rectRatio) {
        imageSize.width = floorf(imageRatio * rect.size.height);
        imageSize.height = rect.size.height;
      } else {
        imageSize.height = floorf(rect.size.width / imageRatio);
        imageSize.width = rect.size.width;
      }
      return CGRectMake(rect.origin.x + floorf(rect.size.width/2 - imageSize.width/2),
                        rect.origin.y + floorf(rect.size.height/2 - imageSize.height/2),
                        imageSize.width, imageSize.height);
    } else if (contentMode == UIViewContentModeScaleAspectFit) {
      if ((size.height/size.width) < (rect.size.height/rect.size.width)) {
        size.height = floorf((size.height/size.width) * rect.size.width);
        size.width = rect.size.width;
      } else {
        size.width = floorf((size.width/size.height) * rect.size.height);
        size.height = rect.size.height;
      }
      return CGRectMake(rect.origin.x + floorf(rect.size.width/2 - size.width/2),
                        rect.origin.y + floorf(rect.size.height/2 - size.height/2),
                        size.width, size.height);
    }
  }
  return rect;
}


NSString *CRNSStringFromUIViewContentMode(UIViewContentMode contentMode) {
  switch (contentMode) {
    case UIViewContentModeScaleToFill: return @"UIViewContentModeScaleToFill";
    case UIViewContentModeScaleAspectFit: return @"UIViewContentModeScaleAspectFit";
    case UIViewContentModeScaleAspectFill: return @"UIViewContentModeScaleAspectFill";
    case UIViewContentModeRedraw: return @"UIViewContentModeRedraw";
    case UIViewContentModeCenter: return @"UIViewContentModeCenter";
    case UIViewContentModeTop: return @"UIViewContentModeTop";
    case UIViewContentModeBottom: return @"UIViewContentModeBottom";
    case UIViewContentModeLeft: return @"UIViewContentModeLeft";
    case UIViewContentModeRight: return @"UIViewContentModeRight";
    case UIViewContentModeTopLeft: return @"UIViewContentModeTopLeft";
    case UIViewContentModeTopRight: return @"UIViewContentModeTopRight";
    case UIViewContentModeBottomLeft: return @"UIViewContentModeBottomLeft";
    case UIViewContentModeBottomRight: return @"UIViewContentModeBottomRight";
  }
  return @"Unknown content mode";
}

CGRect CRCGRectScaleFromCenter(CGRect rect, CGFloat scale) {
  CGSize newRectSize = CGSizeMake(rect.size.width * scale, rect.size.height * scale);
  return CRCGRectToCenterInRect(newRectSize, rect);
}

// Linear gradient function based on code by Ray Wenderlich
// http://www.raywenderlich.com/2033/core-graphics-101-lines-rectangles-and-gradients
void CRCGContextDrawLinearGradientWithColors(CGContextRef context, CGRect rect, NSArray */*of CGColorRef*/colors, CGFloat *locations) {
  CGColorSpaceRef startColorSpace = CGColorGetColorSpace((__bridge CGColorRef)[colors objectAtIndex:0]);
  for (NSInteger i = 1; i < [colors count]; i++) {
    CGColorSpaceRef colorSpace = CGColorGetColorSpace((__bridge CGColorRef)[colors objectAtIndex:i]);
    if (colorSpace != startColorSpace) return;
  }

  CGGradientRef gradient = CGGradientCreateWithColors(startColorSpace, (__bridge CFArrayRef)colors, locations);

  CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
  CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));

  CGContextSaveGState(context);
  CGContextAddRect(context, rect);
  CGContextClip(context);
  CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
  CGContextRestoreGState(context);
  
  CGGradientRelease(gradient);
}

void CRCGContextDrawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef  endColor) {
  NSArray *colors = [NSArray arrayWithObjects:(__bridge id)startColor, (__bridge id)endColor, nil];
  CGFloat locations[] = { 0.0, 1.0 };
  CRCGContextDrawLinearGradientWithColors(context, rect, colors, locations);
}

UIImage *CRCreateVerticalGradientImage(CGFloat height, CGColorRef topColor, CGColorRef bottomColor) {
  
  // If there are performance issues with tiling a lot of skinny images,
  // maybe this could be increased or made into a parameter
  CGFloat width = 1;
  
  // Create new offscreen context with desired size
  UIGraphicsBeginImageContext(CGSizeMake(width, height));
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CRCGContextDrawRect(context, CGRectMake(0, 0, width, height), [UIColor whiteColor].CGColor, [UIColor whiteColor].CGColor, 0.0);
  CRCGContextDrawLinearGradient(context, CGRectMake(0, 0, width, height), topColor, bottomColor);
  
  // assign context to UIImage
  UIImage *outputImg = UIGraphicsGetImageFromCurrentImageContext();
  
  // end context
  UIGraphicsEndImageContext();
  
  return outputImg;
}

UIImage *CRCGContextRoundedMask(CGRect rect, CGFloat cornerRadius) {
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);  
  CGColorSpaceRelease(colorSpace);    
  
  if (context == NULL) {
    return NULL;
  }
  
  CGContextBeginPath(context);
  CGContextSetGrayFillColor(context, 1.0, 0.0);
  CGContextAddRect(context, rect);
  CGContextClosePath(context);
  CGContextDrawPath(context, kCGPathFill);
  
  CGContextSetGrayFillColor(context, 1.0, 1.0);
  CGPathRef path = CRCGPathCreateRoundedRect(rect, 0.0, cornerRadius);
  CGContextAddPath(context, path);
  CGPathRelease(path);  
  CGContextDrawPath(context, kCGPathFill);

  CGImageRef bitmapContext = CGBitmapContextCreateImage(context);
  CGContextRelease(context);

  UIImage *image = [UIImage imageWithCGImage:bitmapContext];
  CGImageRelease(bitmapContext);
  return image;
}  
