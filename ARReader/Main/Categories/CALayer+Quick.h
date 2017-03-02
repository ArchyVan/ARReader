//
//  CALayer+Quick.h
//  ARReader
//
//  Created by Objective-C on 2017/2/23.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (Quick)

- (CALayer *(^)(CALayer *layer))addSublayer;

@end
