//
//  ARTextView.h
//  LearnCoreText
//
//  Created by Objective-C on 2017/1/14.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARPageData.h"

@protocol ARTextViewDelegte;
/**
 页面展示组件
 */
@interface ARTextView : UIView
/**
 ARTextView页面数据
 */
@property (nonatomic, strong) ARPageData            *pageData;
/**
 ARTextView文本颜色
 */
@property (nonatomic, strong) UIColor               *textColor;
/**
 ARTextView文本字体
 */
@property (nonatomic, strong) UIFont                *font;
/**
 ARTextView标题字体
 */
@property (nonatomic, strong) UIFont                *titleFont;
/**
 ARTextView是否首行缩进
 */
@property (nonatomic, assign, getter=isIndent) BOOL indent;
/**
 ARTextView行间距
 */
@property (nonatomic, assign) CGFloat               lineSpacing;
/**
 ARTextView对齐样式
 */
@property (nonatomic, assign) NSTextAlignment       textAlignment;
/**
 ARTextView是否可编辑
 */
@property (nonatomic, assign, getter=isEditable) BOOL editable;
/**
 ARTextView对应代理
 */
@property (nonatomic, weak) id <ARTextViewDelegte>  delegate;
/**
 摘录数组
 */
@property (nonatomic, strong) NSArray               *excerptArray;

@end

@protocol ARTextViewDelegte <NSObject>
/**
 页面开始选择文本

 @param textView 页面
 */
- (void)textViewDidSelectBegin:(ARTextView *)textView;
/**
 页面结束选择文本
 
 @param textView 页面
 */
- (void)textViewDidSelectEnd:(ARTextView *)textView;
/**
 页面取消选择文本
 
 @param textView 页面
 */
- (void)textViewDidSelectCancel:(ARTextView *)textView;
@optional
- (void)textView:(ARTextView *)textView didDrawUnderline:(NSRange)range;

- (void)textView:(ARTextView *)textView didRemoveUnderline:(NSRange)range;

@end
