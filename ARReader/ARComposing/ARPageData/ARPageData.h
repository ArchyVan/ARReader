//
//  ARPageData.h
//  LearnCoreText
//
//  Created by Objective-C on 2017/1/13.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 基础页面数据
 */
@interface ARPageData : NSObject
/*页面基础参数*/
/**
 页面包含可裁剪内容
 */
@property (strong, nonatomic) NSString           *pageContent;

/**
 页面实际内容
 */
@property (strong, nonatomic) NSString           *pageDisplayContent;
/**
 页面起点
 */
@property (assign, nonatomic) NSInteger           pageStart;
/**
 页面终点
 */
@property (assign, nonatomic) NSInteger           pageEnd;
/**
 页面首行缩进起点
 */
@property (assign, nonatomic) NSInteger           pageIndentLocation;
/**
 页码
 */
@property (assign, nonatomic) NSInteger           pageIndex;
/**
 页面对应高度
 */
@property (assign, nonatomic) CGFloat             pageHeight;
/**
 页面中标题长度
 */
@property (assign, nonatomic) CGFloat             pageTitleLength;
/**
 将页面数据转换成字典方便本地

 @return 页面字典
 */
- (nullable NSDictionary *)convertToDictionary;
/**
 将页面字典转换成数据

 @param dictionary 字典
 @return 数据
 */
+ (nullable ARPageData *)pageDataWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
