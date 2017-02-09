//
//  ARTextCursor.h
//  LearnCoreText
//
//  Created by Objective-C on 2017/1/14.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ARTextCursorType) {
    ARTextCursorTop, //大头针朝上
    ARTextCursorBottom //大头针朝下
};

@protocol ARCursorViewPanDelegate;
/**
 自定义光标视图
 */
@interface ARTextCursor : UIView <UIGestureRecognizerDelegate>
/**
 移动事件代理
 */
@property (nonatomic, weak) id <ARCursorViewPanDelegate>    panDelegate;
/**
 光标类型
 */
@property (nonatomic, assign) ARTextCursorType              cursorType;
/**
 光标高度
 */
@property (nonatomic, assign) CGFloat                       cursorHeight;
/**
 光标颜色
 */
@property (nonatomic, strong) UIColor                       *cursorColor;

/**
 初始化方法

 @param height 高度
 @return 光标视图
 */
- (instancetype)initWithHeight:(CGFloat)height;

@end
/**
 大头针移动事件代理
 */
@protocol ARCursorViewPanDelegate <NSObject>
/**
 手势开始

 @param cursorView 光标视图
 @param panGesture 手势
 */
- (void)cursorView:(ARTextCursor *)cursorView didBeginPan:(UIGestureRecognizer *)panGesture;
/**
 手势移动
 
 @param cursorView 光标视图
 @param panGesture 手势
 */
- (void)cursorView:(ARTextCursor *)cursorView didChangePan:(UIGestureRecognizer *)panGesture;
/**
 手势结束
 
 @param cursorView 光标视图
 @param panGesture 手势
 */
- (void)cursorView:(ARTextCursor *)cursorView didEndPan:(UIGestureRecognizer *)panGesture;
/**
 手势取消
 
 @param cursorView 光标视图
 @param panGesture 手势
 */
- (void)cursorView:(ARTextCursor *)cursorView didCancelPan:(UIGestureRecognizer *)panGesture;

@end

