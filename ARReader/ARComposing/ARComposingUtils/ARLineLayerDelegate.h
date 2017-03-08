//
//  ARLineLayerDelegate.h
//  ARReader
//
//  Created by Objective-C on 2017/1/17.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "ARTextLayout.h"

typedef NS_OPTIONS(NSInteger, ARUnderLineStyle) {
    // style pattern (bitmask:0xF00)
    ARUnderLineStylePatternSolid      = 0x000, ///< (────────) Draw a solid line (Default).
    ARUnderLineStylePatternDot        = 0x100, ///< (‑ ‑ ‑ ‑ ‑ ‑) Draw a line of dots.
    ARUnderLineStylePatternDash       = 0x200, ///< (— — — —) Draw a line of dashes.
    ARUnderLineStylePatternDashDot    = 0x300, ///< (— ‑ — ‑ — ‑) Draw a line of alternating dashes and dots.
    ARUnderLineStylePatternDashDotDot = 0x400, ///< (— ‑ ‑ — ‑ ‑) Draw a line of alternating dashes and two dots.
    ARUnderLineStylePatternCircleDot  = 0x900, ///< (••••••••••••) Draw a line of small circle dots.
};
/**
 划线图层代理(将图层重绘方法抽离)，划线可单独用另一个图层实现
 */
@interface ARLineLayerDelegate : NSObject <CALayerDelegate>
/**
 下滑线样式
 */
@property (nonatomic, assign) ARUnderLineStyle underLineStyle;
/**
 下划线颜色
 */
@property (nonatomic, strong) UIColor         *underLineColor;
/**
 下划线与文字间距
 */
@property (nonatomic, assign) CGFloat          underLineSpacing;
/**
 下划线宽度
 */
@property (nonatomic, assign) CGFloat          underLineWidth;
/**
 下划线数据
 */
@property (nonatomic, strong) NSArray<NSValue *> *underLineArray;
/**
 页面内容
 */
@property (nonatomic, strong) NSString        *pageContent;

@property (nonatomic, strong) ARTextLayout    *pageLayout;
@end
