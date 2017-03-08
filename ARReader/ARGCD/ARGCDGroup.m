//
//  ARGCDGroup.m
//  ARReader
//
//  Created by Objective-C on 2017/2/22.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARGCDGroup.h"

@interface ARGCDGroup ()

@property (nonatomic, strong) dispatch_group_t executeGroup;

@end

@implementation ARGCDGroup

- (instancetype)init {
    if (self = [super init]) {
        self.executeGroup = dispatch_group_create();
    }
    return self;
}

- (void)wait {
    dispatch_group_wait(self.executeGroup, DISPATCH_TIME_FOREVER);
}

- (void)enter {
    dispatch_group_enter(self.executeGroup);
}

- (void)leave {
    dispatch_group_leave(self.executeGroup);
}

- (BOOL)wait:(NSTimeInterval)delay {
    return dispatch_group_wait(self.executeGroup, delay * NSEC_PER_SEC) == 0;
}

@end
