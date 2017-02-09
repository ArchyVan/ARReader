//
//  ARAsyncLayer.h
//  ARReader
//
//  Created by Objective-C on 2017/1/19.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@class ARAsyncLayerDisplayTask;

@interface ARAsyncLayer : CALayer

@property BOOL displaysAsynchronously;

@end

@protocol ARAsyncLayerDelegate <NSObject>

@required
- (ARAsyncLayerDisplayTask *)newAsyncDisplayTask;

@end

@interface ARAsyncLayerDisplayTask : NSObject

@property (nullable, nonatomic, copy) void (^willDisplay)(CALayer *layer);

@property (nullable, nonatomic, copy) void (^display)(CGContextRef context, CGSize size, BOOL(^isCancelled)(void));

@property (nullable, nonatomic, copy) void (^didDisplay)(CALayer *layer, BOOL finished);

@end

NS_ASSUME_NONNULL_END
