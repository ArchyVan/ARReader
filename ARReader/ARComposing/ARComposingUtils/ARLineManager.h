//
//  ARLineManager.h
//  ARReader
//
//  Created by Objective-C on 2017/1/27.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ARLineManager : NSObject

@property (nonatomic, strong, nullable) NSArray *lineArray;
- (nullable NSArray *)addLineWithRange:(NSRange)range;
- (nullable NSArray *)removeLineWithRange:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
