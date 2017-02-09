//
//  ARTextEffectWindow.h
//  ARReader
//
//  Created by Objective-C on 2017/1/23.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARTextMagnifier.h"

NS_ASSUME_NONNULL_BEGIN

/**
 参照YYText
 */
@interface ARTextEffectWindow : UIWindow

+ (nullable instancetype)sharedWindow;

- (void)showMagnifier:(ARTextMagnifier *)mag;
- (void)moveMagnifier:(ARTextMagnifier *)mag;
- (void)hideMagnifier:(ARTextMagnifier *)mag;

@end

NS_ASSUME_NONNULL_END
