//
//  UIView+ComposingKit.m
//  ARKit
//
//  Created by Objective-C on 16/8/26.
//  Copyright © 2016年 Objective-C. All rights reserved.
//

#import "UIView+ComposingKit.h"

@implementation UIView (ComposingKit)

- (void)setAr_origin:(CGPoint)ar_origin {
    CGRect frame = self.frame;
    frame.origin = ar_origin;
    self.frame = frame;
}

- (CGPoint)ar_origin {
    return self.frame.origin;
}

- (void)setAr_originX:(CGFloat)ar_originX {
    [self setAr_origin:CGPointMake(ar_originX, self.ar_originY)];
}

- (CGFloat)ar_originX {
    return self.ar_origin.x;
}

- (void)setAr_originY:(CGFloat)ar_originY {
    [self setAr_origin:CGPointMake(self.ar_originX, ar_originY)];
}

- (CGFloat)ar_originY {
    return self.ar_origin.y;
}

- (void)setAr_center:(CGPoint)ar_center {
    self.center = ar_center;
}

- (CGPoint)ar_center {
    return self.center;
}

- (void)setAr_centerX:(CGFloat)ar_centerX {
    [self setAr_center:CGPointMake(ar_centerX, self.ar_centerY)];
}

- (CGFloat)ar_centerX {
    return self.ar_center.x;
}

- (void)setAr_centerY:(CGFloat)ar_centerY {
    [self setAr_center:CGPointMake(self.ar_centerX, ar_centerY)];
}

- (CGFloat)ar_centerY {
    return self.ar_center.y;
}

- (void)setAr_size:(CGSize)ar_size {
    CGRect frame = self.frame;
    frame.size = ar_size;
    self.frame = frame;
}

- (CGSize)ar_size {
    return self.frame.size;
}

- (void)setAr_width:(CGFloat)ar_width {
    self.ar_size = CGSizeMake(ar_width, self.ar_height);
}

- (CGFloat)ar_width {
    return self.ar_size.width;
}

- (void)setAr_height:(CGFloat)ar_height {
    self.ar_size = CGSizeMake(self.ar_width, ar_height);
}

- (CGFloat)ar_height {
    return self.ar_size.height;
}

- (CGFloat)ar_left {
    return self.frame.origin.x;
}

- (void)setAr_left:(CGFloat)ar_left {
    CGRect frame = self.frame;
    frame.origin.x = ar_left;
    self.frame = frame;
}

- (CGFloat)ar_top {
    return self.frame.origin.y;
}

- (void)setAr_top:(CGFloat)ar_top {
    CGRect frame = self.frame;
    frame.origin.y = ar_top;
    self.frame = frame;
}

- (CGFloat)ar_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setAr_right:(CGFloat)ar_right {
    CGRect frame = self.frame;
    frame.origin.x = ar_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)ar_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setAr_bottom:(CGFloat)ar_bottom {
    CGRect frame = self.frame;
    frame.origin.y = ar_bottom - frame.size.height;
    self.frame = frame;
}

- (UIViewController *)ar_viewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (CGFloat)ar_visibleAlpha {
    if ([self isKindOfClass:[UIWindow class]]) {
        if (self.hidden) return 0;
        return self.alpha;
    }
    if (!self.window) return 0;
    CGFloat alpha = 1;
    UIView *v = self;
    while (v) {
        if (v.hidden) {
            alpha = 0;
            break;
        }
        alpha *= v.alpha;
        v = v.superview;
    }
    return alpha;
}

- (CGPoint)ar_convertPoint:(CGPoint)point toViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertPoint:point toWindow:nil];
        } else {
            return [self convertPoint:point toView:nil];
        }
    }
    
    UIWindow *from = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    UIWindow *to = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if ((!from || !to) || (from == to)) return [self convertPoint:point toView:view];
    point = [self convertPoint:point toView:from];
    point = [to convertPoint:point fromWindow:from];
    point = [view convertPoint:point fromView:to];
    return point;
}

- (CGPoint)ar_convertPoint:(CGPoint)point fromViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertPoint:point fromWindow:nil];
        } else {
            return [self convertPoint:point fromView:nil];
        }
    }
    
    UIWindow *from = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    UIWindow *to = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    if ((!from || !to) || (from == to)) return [self convertPoint:point fromView:view];
    point = [from convertPoint:point fromView:view];
    point = [to convertPoint:point fromWindow:from];
    point = [self convertPoint:point fromView:to];
    return point;
}

- (CGRect)ar_convertRect:(CGRect)rect toViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertRect:rect toWindow:nil];
        } else {
            return [self convertRect:rect toView:nil];
        }
    }
    
    UIWindow *from = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    UIWindow *to = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if (!from || !to) return [self convertRect:rect toView:view];
    if (from == to) return [self convertRect:rect toView:view];
    rect = [self convertRect:rect toView:from];
    rect = [to convertRect:rect fromWindow:from];
    rect = [view convertRect:rect fromView:to];
    return rect;
}

- (CGRect)ar_convertRect:(CGRect)rect fromViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertRect:rect fromWindow:nil];
        } else {
            return [self convertRect:rect fromView:nil];
        }
    }
    
    UIWindow *from = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    UIWindow *to = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    if ((!from || !to) || (from == to)) return [self convertRect:rect fromView:view];
    rect = [from convertRect:rect fromView:view];
    rect = [to convertRect:rect fromWindow:from];
    rect = [self convertRect:rect fromView:to];
    return rect;
}

@end

@implementation UIColor (ComposingKit)

static inline NSUInteger hexStrToInt(NSString *str) {
    uint32_t result = 0;
    sscanf([str UTF8String], "%X", &result);
    return result;
}

static BOOL hexStrToRGBA(NSString *str,
                         CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a) {
    str = [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([str hasPrefix:@"#"]) {
        str = [str substringFromIndex:1];
    } else if ([str hasPrefix:@"0X"]) {
        str = [str substringFromIndex:2];
    }
    
    NSUInteger length = [str length];
    //         RGB            RGBA          RRGGBB        RRGGBBAA
    if (length != 3 && length != 4 && length != 6 && length != 8) {
        return NO;
    }
    
    //RGB,RGBA,RRGGBB,RRGGBBAA
    if (length < 5) {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 1)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(1, 1)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(2, 1)]) / 255.0f;
        if (length == 4)  *a = hexStrToInt([str substringWithRange:NSMakeRange(3, 1)]) / 255.0f;
        else *a = 1;
    } else {
        *r = hexStrToInt([str substringWithRange:NSMakeRange(0, 2)]) / 255.0f;
        *g = hexStrToInt([str substringWithRange:NSMakeRange(2, 2)]) / 255.0f;
        *b = hexStrToInt([str substringWithRange:NSMakeRange(4, 2)]) / 255.0f;
        if (length == 8) *a = hexStrToInt([str substringWithRange:NSMakeRange(6, 2)]) / 255.0f;
        else *a = 1;
    }
    return YES;
}

+ (instancetype)colorWithHexString:(NSString *)hexStr {
    CGFloat r, g, b, a;
    if (hexStrToRGBA(hexStr, &r, &g, &b, &a)) {
        return [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    return nil;
}

@end
