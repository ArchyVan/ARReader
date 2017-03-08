//
//  UIView+Quick.h
//  ARReader
//
//  Created by Objective-C on 2017/2/16.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Quick)
/**
 The block function addSubview
 
 @result self
 */
- (UIView *(^)(UIView *view))addSubview;

/**
 The block function sendSubviewToBack
 
 @result self
 */
- (UIView *(^)(UIView *view))sendSubviewToBack;
/**
 The block function bringSubviewToFront
 
 @result self
 */
- (UIView *(^)(UIView *view))bringSubviewToFront;
/**
 The block function insertSubView:AtIndex:
 
 @result self
 */
- (UIView *(^)(UIView *view,NSInteger index))insertSubViewAtIndex;
/**
 The block function insertSubView:AboveSubview:
 
 @result self
 */
- (UIView *(^)(UIView *view,UIView *siblingSubview))insertSubViewAboveSubview;
/**
 The block function insertSubview:BelowSubview:
 
 @result self
 */
- (UIView *(^)(UIView *view,UIView *siblingSubview))insertSubviewBelowSubview;
/**
 The block function removeAllSubviews
 
 @result self
 */
- (UIView *(^)())removeAllSubviews;
/**
 The block function reAddSubview
 
 First remove all subviews, then add the view;
 
 @result self
 */
- (UIView *(^)(UIView *view))reAddSubview;
/**
 The block function subviewAtIndex
 
 @result subview
 */
- (UIView *(^)(NSInteger index))subviewAtIndex;

@end
