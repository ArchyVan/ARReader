//
//  ARTextEffectWindow.m
//  ARReader
//
//  Created by Objective-C on 2017/1/23.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARTextEffectWindow.h"
#import "ARTextUtilities.h"
#import "UIView+Reader.h"

@implementation ARTextEffectWindow

+ (instancetype)sharedWindow {
    static ARTextEffectWindow *one = nil;
    if (one == nil) {
        // iOS 9 compatible
        NSString *mode = [NSRunLoop currentRunLoop].currentMode;
        if (mode.length == 27 &&
            [mode hasPrefix:@"UI"] &&
            [mode hasSuffix:@"InitializationRunLoopMode"]) {
            return nil;
        }
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!ARTextIsAppExtension()) {
            one = [self new];
            one.frame = (CGRect){.size = ARTextScreenSize()};
            one.userInteractionEnabled = NO;
            one.windowLevel = UIWindowLevelStatusBar + 1;
            one.hidden = NO;
            
            // for iOS 9:
            one.opaque = NO;
            one.backgroundColor = [UIColor clearColor];
            one.layer.backgroundColor = [UIColor clearColor].CGColor;
        }
    });
    return one;
}

// stop self from becoming the KeyWindow
- (void)becomeKeyWindow {
    [[ARTextSharedApplication().delegate window] makeKeyWindow];
}

- (UIViewController *)rootViewController {
    for (UIWindow *window in [ARTextSharedApplication() windows]) {
        if (self == window) continue;
        if (window.hidden) continue;
        UIViewController *topViewController = window.rootViewController;
        if (topViewController) return topViewController;
    }
    UIViewController *viewController = [super rootViewController];
    if (!viewController) {
        viewController = [UIViewController new];
        [super setRootViewController:viewController];
    }
    return viewController;
}

// Bring self to front
- (void)_updateWindowLevel {
    UIApplication *app = ARTextSharedApplication();
    if (!app) return;
    
    UIWindow *top = app.windows.lastObject;
    UIWindow *key = app.keyWindow;
    if (key && key.windowLevel > top.windowLevel) top = key;
    if (top == self) return;
    self.windowLevel = top.windowLevel + 1;
}

- (CGPoint)_correctedCenter:(CGPoint)center forMagnifier:(ARTextMagnifier *)mag rotation:(CGFloat)rotation {
    CGFloat degree = ARTextRadiansToDegrees(rotation);
    
    degree /= 45.0;
    if (degree < 0) degree += (int)(-degree/8.0 + 1) * 8;
    if (degree > 8) degree -= (int)(degree/8.0) * 8;
    
    CGFloat caretExt = 10;
    if (degree <= 1 || degree >= 7) { //top
        if (mag.type == ARTextMagnifierTypeCaret) {
            if (center.y < caretExt)
                center.y = caretExt;
        } else if (mag.type == ARTextMagnifierTypeRanged) {
            if (center.y < mag.bounds.size.height)
                center.y = mag.bounds.size.height;
        }
    } else if (1 < degree && degree < 3) { // right
        if (mag.type == ARTextMagnifierTypeCaret) {
            if (center.x > self.bounds.size.width - caretExt)
                center.x = self.bounds.size.width - caretExt;
        } else if (mag.type == ARTextMagnifierTypeRanged) {
            if (center.x > self.bounds.size.width - mag.bounds.size.height)
                center.x = self.bounds.size.width - mag.bounds.size.height;
        }
    } else if (3 <= degree && degree <= 5) { // bottom
        if (mag.type == ARTextMagnifierTypeCaret) {
            if (center.y > self.bounds.size.height - caretExt)
                center.y = self.bounds.size.height - caretExt;
        } else if (mag.type == ARTextMagnifierTypeRanged) {
            if (center.y > mag.bounds.size.height)
                center.y = mag.bounds.size.height;
        }
    } else if (5 < degree && degree < 7) { // left
        if (mag.type == ARTextMagnifierTypeCaret) {
            if (center.x < caretExt)
                center.x = caretExt;
        } else if (mag.type == ARTextMagnifierTypeRanged) {
            if (center.x < mag.bounds.size.height)
                center.x = mag.bounds.size.height;
        }
    }
    
    return center;
}

/**
 Capture screen snapshot and set it to magnifier.
 @return Magnifier rotation radius.
 */
- (CGFloat)_updateMagnifier:(ARTextMagnifier *)mag {
    UIApplication *app = ARTextSharedApplication();
    if (!app) return 0;
    
    UIView *hostView = mag.hostView;
    UIWindow *hostWindow = [hostView isKindOfClass:[UIWindow class]] ? (id)hostView : hostView.window;
    if (!hostView || !hostWindow) return 0;
    CGPoint captureCenter = [self ar_convertPoint:mag.hostCaptureCenter fromViewOrWindow:hostView];
    captureCenter = captureCenter;
    CGRect captureRect = {.size = mag.snapshotSize};
    captureRect.origin.x = captureCenter.x - captureRect.size.width / 2;
    captureRect.origin.y = captureCenter.y - captureRect.size.height / 2;
    
    CGAffineTransform trans = ARTextCGAffineTransformGetFromViews(hostView, self);
    CGFloat rotation = ARTextCGAffineTransformGetRotation(trans);
    
    if (mag.captureDisabled) {
        if (!mag.snapshot || mag.snapshot.size.width > 1) {
            static UIImage *placeholder;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                CGRect rect = mag.bounds;
                rect.origin = CGPointZero;
                UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
                CGContextRef context = UIGraphicsGetCurrentContext();
                [[UIColor colorWithWhite:1 alpha:0.8] set];
                CGContextFillRect(context, rect);
                placeholder = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            });
            mag.captureFadeAnimation = YES;
            mag.snapshot = placeholder;
            mag.captureFadeAnimation = NO;
        }
        return rotation;
    }
    
    UIGraphicsBeginImageContextWithOptions(captureRect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return rotation;
    
    CGPoint tp = CGPointMake(captureRect.size.width / 2, captureRect.size.height / 2);
    tp = CGPointApplyAffineTransform(tp, CGAffineTransformMakeRotation(rotation));
    CGContextRotateCTM(context, -rotation);
    CGContextTranslateCTM(context, tp.x - captureCenter.x, tp.y - captureCenter.y);
    
    NSMutableArray *windows = app.windows.mutableCopy;
    UIWindow *keyWindow = app.keyWindow;
    if (![windows containsObject:keyWindow]) [windows addObject:keyWindow];
    [windows sortUsingComparator:^NSComparisonResult(UIWindow *w1, UIWindow *w2) {
        if (w1.windowLevel < w2.windowLevel) return NSOrderedAscending;
        else if (w1.windowLevel > w2.windowLevel) return NSOrderedDescending;
        return NSOrderedSame;
    }];
    UIScreen *mainScreen = [UIScreen mainScreen];
    for (UIWindow *window in windows) {
        if (window.hidden || window.alpha <= 0.01) continue;
        if (window.screen != mainScreen) continue;
        if ([window isKindOfClass:self.class]) break; //don't capture window above self
        CGContextSaveGState(context);
        CGContextConcatCTM(context, ARTextCGAffineTransformGetFromViews(window, self));
        [window.layer renderInContext:context]; //render
        //[window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO]; //slower when capture whole window
        CGContextRestoreGState(context);
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (mag.snapshot.size.width == 1) {
        mag.captureFadeAnimation = YES;
    }
    mag.snapshot = image;
    mag.captureFadeAnimation = NO;
    return rotation;
}

- (void)showMagnifier:(ARTextMagnifier *)mag {
    if (!mag) return;
    if (mag.superview != self) [self addSubview:mag];
    [self _updateWindowLevel];
    CGFloat rotation = [self _updateMagnifier:mag];
    CGPoint center = [self ar_convertPoint:mag.hostPopoverCenter fromViewOrWindow:mag.hostView];
    CGAffineTransform trans = CGAffineTransformMakeRotation(rotation);
    trans = CGAffineTransformScale(trans, 0.3, 0.3);
    mag.transform = trans;
    mag.center = center;
    if (mag.type == ARTextMagnifierTypeRanged) {
        mag.alpha = 0;
    }
    NSTimeInterval time = mag.type == ARTextMagnifierTypeCaret ? 0.08 : 0.1;
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (mag.type == ARTextMagnifierTypeCaret) {
            CGPoint newCenter = CGPointMake(0, -mag.fitSize.height / 2);
            newCenter = CGPointApplyAffineTransform(newCenter, CGAffineTransformMakeRotation(rotation));
            newCenter.x += center.x;
            newCenter.y += center.y;
            mag.center = [self _correctedCenter:newCenter forMagnifier:mag rotation:rotation];
        } else {
            mag.center = [self _correctedCenter:center forMagnifier:mag rotation:rotation];
        }
        mag.transform = CGAffineTransformMakeRotation(rotation);
        mag.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)moveMagnifier:(ARTextMagnifier *)mag {
    if (!mag) return;
    [self _updateWindowLevel];
    CGFloat rotation = [self _updateMagnifier:mag];
    CGPoint center = [self ar_convertPoint:mag.hostPopoverCenter fromViewOrWindow:mag.hostView];
    if (mag.type == ARTextMagnifierTypeCaret) {
        CGPoint newCenter = CGPointMake(0, -mag.fitSize.height / 2);
        newCenter = CGPointApplyAffineTransform(newCenter, CGAffineTransformMakeRotation(rotation));
        newCenter.x += center.x;
        newCenter.y += center.y;
        mag.center = [self _correctedCenter:newCenter forMagnifier:mag rotation:rotation];
    } else {
        mag.center = [self _correctedCenter:center forMagnifier:mag rotation:rotation];
    }
    mag.transform = CGAffineTransformMakeRotation(rotation);
}

- (void)hideMagnifier:(ARTextMagnifier *)mag {
    if (!mag) return;
    if (mag.superview != self) return;
    CGFloat rotation = [self _updateMagnifier:mag];
    CGPoint center = [self ar_convertPoint:mag.hostPopoverCenter fromViewOrWindow:mag.hostView];
    NSTimeInterval time = mag.type == ARTextMagnifierTypeCaret ? 0.20 : 0.15;
    [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        CGAffineTransform trans = CGAffineTransformMakeRotation(rotation);
        trans = CGAffineTransformScale(trans, 0.01, 0.01);
        mag.transform = trans;
        
        if (mag.type == ARTextMagnifierTypeCaret) {
            CGPoint newCenter = CGPointMake(0, -mag.fitSize.height / 2);
            newCenter = CGPointApplyAffineTransform(newCenter, CGAffineTransformMakeRotation(rotation));
            newCenter.x += center.x;
            newCenter.y += center.y;
            mag.center = [self _correctedCenter:newCenter forMagnifier:mag rotation:rotation];
        } else {
            mag.center = [self _correctedCenter:center forMagnifier:mag rotation:rotation];
            mag.alpha = 0;
        }
        
    } completion:^(BOOL finished) {
        if (finished) {
            [mag removeFromSuperview];
            mag.transform = CGAffineTransformIdentity;
            mag.alpha = 1;
        }
    }];
}

@end
