//
//  ARGCDCenter.m
//  ARReader
//
//  Created by Objective-C on 2017/2/23.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARGCDCenter.h"
#import "ARGCD.h"

@interface ARGCDCenter ()

@property (nonatomic, strong) ARGCDTimer *asyncTimer;
@property (nonatomic, strong) ARGCDTimer *syncTimer;

@end

@implementation ARGCDCenter

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Lazy Init

- (ARGCDTimer *)asyncTimer
{
    if (!_asyncTimer) {
        _asyncTimer = [[ARGCDTimer alloc] init];
        [_asyncTimer execute:^{
            NSLog(@"\nAsync %@",[NSThread currentThread]);
        } interval:1];
    }
    return _asyncTimer;
}

- (ARGCDTimer *)syncTimer
{
    if (!_syncTimer) {
        _syncTimer = [[ARGCDTimer alloc] initWithExecuteQueue:[ARGCDQueue mainQueue]];
        [_syncTimer execute:^{
            NSLog(@"\nSync %@",[NSThread currentThread]);
        } interval:1];
    }
    return _syncTimer;
}

@end
