//
//  ARBookIndicator.h
//  ARReader
//
//  Created by Objective-C on 2017/2/27.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,ARBookIndicatorStyle) {
    ARBookIndicatorStyleNormal,
    ARBookIndicatorStyleSmall
};

@interface ARBookIndicator : UIView

@property (nonatomic, assign, readonly) ARBookIndicatorStyle style;
@property (nonatomic, assign) BOOL hidesWhenStopped;

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

- (instancetype)initWithStyle:(ARBookIndicatorStyle)style;

- (void)manualAnimationWithCurrentOffsetY:(CGFloat)currentOffsetY
                  distanceForStartRefresh:(CGFloat)distanceForStartRefresh
             distanceForCompleteAnimation:(CGFloat)distanceForCompleteAnimation;
@end
