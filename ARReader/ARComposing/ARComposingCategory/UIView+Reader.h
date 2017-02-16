//
//  UIView+ComposingKit.h
//  ComposingKit
//
//  Created by Objective-C on 16/8/26.
//  Copyright © 2016年 Objective-C. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Reader)

#pragma mark - Convenience frame api
/**
 * view.frame.origin.x
 */
@property (nonatomic, assign) CGFloat ar_originX;

/**
 * view.frame.origin.y
 */
@property (nonatomic, assign) CGFloat ar_originY;

/**
 * view.frame.origin
 */
@property (nonatomic, assign) CGPoint ar_origin;

/**
 * view.center.x
 */
@property (nonatomic, assign) CGFloat ar_centerX;

/**
 * view.center.y
 */
@property (nonatomic, assign) CGFloat ar_centerY;

/**
 * view.center
 */
@property (nonatomic, assign) CGPoint ar_center;

/**
 * view.frame.size.width
 */
@property (nonatomic, assign) CGFloat ar_width;

/**
 * view.frame.size.height
 */
@property (nonatomic, assign) CGFloat ar_height;

/**
 * view.frame.size
 */
@property (nonatomic, assign) CGSize  ar_size;

/**
 *  view.frame.origin.x
 */
@property (nonatomic, assign) CGFloat ar_left;

/**
 *  view.frame.origin.y
 */
@property (nonatomic, assign) CGFloat ar_top;

/**
 *  view.frame.origin.x + view.frame.size.width
 */
@property (nonatomic, assign) CGFloat ar_right;

/**
 *  view.frame.origin.y + view.frame.size.height
 */
@property (nonatomic, assign) CGFloat ar_bottom;

@property (nullable, nonatomic, readonly) UIViewController *ar_viewController;

@property (nonatomic, readonly) CGFloat ar_visibleAlpha;

- (CGPoint)ar_convertPoint:(CGPoint)point toViewOrWindow:(UIView *)view;

- (CGPoint)ar_convertPoint:(CGPoint)point fromViewOrWindow:(UIView *)view;

- (CGRect)ar_convertRect:(CGRect)rect toViewOrWindow:(UIView *)view;

- (CGRect)ar_convertRect:(CGRect)rect fromViewOrWindow:(UIView *)view;

@end

/**
 UIView 渲染主线程检测
 */
@interface UIView (MainThread)

@end


NS_ASSUME_NONNULL_END
