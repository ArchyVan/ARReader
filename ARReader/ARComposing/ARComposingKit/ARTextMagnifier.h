//
//  ARTextMagnifier.h
//  ARReader
//
//  Created by Objective-C on 2017/1/23.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ARTextMagnifierType) {
    ARTextMagnifierTypeCaret,
    ARTextMagnifierTypeRanged,
};

/**
 参照YYText
 */
@interface ARTextMagnifier : UIView

+ (id)magnifierWithType:(ARTextMagnifierType)type;

@property (nonatomic, readonly) ARTextMagnifierType type;
@property (nonatomic, readonly) CGSize              fitSize;
@property (nonatomic, readonly) CGSize              snapshotSize;
@property (nullable, nonatomic, strong) UIImage    *snapshot;

@property (nullable, nonatomic, weak) UIView       *hostView;
@property (nonatomic) CGPoint                       hostCaptureCenter;
@property (nonatomic) CGPoint                       hostPopoverCenter;
@property (nonatomic) BOOL                          captureDisabled;
@property (nonatomic) BOOL                          captureFadeAnimation;

@end

NS_ASSUME_NONNULL_END
