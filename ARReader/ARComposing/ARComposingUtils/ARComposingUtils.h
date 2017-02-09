//
//  ARComposingUtils.h
//  LearnCoreText
//
//  Created by Objective-C on 2017/1/14.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "ARPageData.h"

NS_ASSUME_NONNULL_BEGIN

@interface ARComposingUtils : NSObject

+ (instancetype)sharedInstance;
/**
 点击划线对应位置
 
 @param view 点击视图
 @param point 点击位置
 @param data 点击页面数据
 @return 划线数据
 */

- (nullable NSValue *)touchLineInView:(UIView *)view atPoint:(CGPoint)point lineArray:(NSArray<NSValue *> *)lineArray data:(ARPageData *)data textFrame:(CTFrameRef)textFrame;
/**
 点击位置对应Location

 @param view 点击视图
 @param point 点击位置
 @param data 点击页面数据
 @return 点击Location
 */
- (CFIndex)touchContentOffsetInView:(UIView *)view atPoint:(CGPoint)point data:(ARPageData *)data textFrame:(CTFrameRef)textFrame;
/**
 根据Location反向计算选中范围

 @param view 视图
 @param startPosition 开始位置
 @param endPosition 结束位置
 @param data 页面数据
 @return 选中范围
 */
- (CGRect)selectContentRectInView:(UIView *)view fromStartPosition:(NSInteger)startPosition toEndPosition:(NSInteger)endPosition data:(ARPageData *)data textFrame:(CTFrameRef)textFrame;


- (CGRect)selectContentRectInView:(UIView *)view withRange:(NSRange)range data:(ARPageData *)data textFrame:(CTFrameRef)textFrame;
/**
 双击或者长按或者点击光标位置所在段落范围

 @param view 视图
 @param point 双击位置
 @param data 页面数据
 @return 段落范围
 */
- (NSRange)touchRangeInView:(UIView *)view atPoint:(CGPoint)point data:(ARPageData *)data textFrame:(CTFrameRef)textFrame;
/**
 位置包含判断

 @param position 位置
 @param range 范围
 @return YES or NO
 */
- (BOOL)isPosition:(NSInteger)position inRange:(CFRange)range;

@end

NS_ASSUME_NONNULL_END
