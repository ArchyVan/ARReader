//
//  ARPageParser.h
//  LearnCoreText
//
//  Created by Objective-C on 2017/1/14.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARPageData.h"

/**
 页面解析组件
 */
@interface ARPageParser : NSObject
/**
 解析页面尺寸
 */
@property (nonatomic, assign) CGSize                        pageSize;
/**
 解析字体大小
 */
@property (nonatomic, assign) CGFloat                       fontSize;
/**
 解析首行缩进样式
 */
@property (nonatomic, assign, getter=isIndent) BOOL         indent;
/**
 解析行间距
 */
@property (nonatomic, assign) CGFloat                       lineSpacing;
/**
 解析对齐样式
 */
@property (nonatomic, assign) NSTextAlignment               textAlignment;
/**
 （可选）标题长度
 */
@property (nonatomic, assign) NSUInteger                    titleLength;
/**
 （可选）自定义参数
 */
@property (nonatomic, copy) NSDictionary                    *customAttributes;
/**
 单例方法
 
 @return 页面解析单例
 */
+ (instancetype)sharedInstance;
/**
 解析内容
 
 @param content 内容
 @return 页面数据组
 */
- (NSArray *)parseContent:(NSString *)content;
/**
 解析内容

 @param content content 内容
 @param cacheEnabled 是否缓存生成图片
 @return 页面数据组
 */
- (NSArray *)parseContent:(NSString *)content cacheEnabled:(BOOL)cacheEnabled;
/**
 解析内容
 
 @param content 内容
 @return 单个大页面
 */
- (ARPageData *)parseWholeContent:(NSString *)content;

@end
