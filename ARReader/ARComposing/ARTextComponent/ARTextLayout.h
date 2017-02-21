//
//  ARTextLayout.h
//  ARReader
//
//  Created by Objective-C on 2017/2/13.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "ARTextLine.h"

NS_ASSUME_NONNULL_BEGIN

@interface ARTextLayout : NSObject

+ (instancetype)layoutWithCTFrame:(CTFrameRef)CTFrame size:(CGSize)size fontSize:(CGFloat)fontSize;

@property (nonatomic, readonly) CTFrameRef CTFrame;
@property (nonatomic, readonly) NSString   *content;
@property (nonatomic, readonly) NSUInteger  rowCount;
@property (nonatomic, readonly) NSUInteger  wordCount;
@property (nonatomic, readonly) CGFloat     fontSize;
@property (nonatomic, readonly) CGSize      layoutSize;
@property (nonatomic, readonly, strong) NSArray<ARTextLine *> *lines;

@end

NS_ASSUME_NONNULL_END


