//
//  ARTransaction.h
//  ARReader
//
//  Created by Objective-C on 2017/1/26.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARTransaction : NSObject

+ (ARTransaction *)transactionWithTarget:(id)target selector:(SEL)selector;

- (void)commit;

@end

NS_ASSUME_NONNULL_END
