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
    [self observer];
}

- (void)observer {
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        switch (activity) {
            case kCFRunLoopEntry:
                NSLog(@"即将被唤醒");
                break;
            case kCFRunLoopBeforeTimers:
                NSLog(@"即将处理定时器事件");
                break;
            case kCFRunLoopBeforeSources:
                NSLog(@"即将处理输入源事件");
                break;
            case kCFRunLoopBeforeWaiting:
                NSLog(@"即将进入休眠");
                break;
            case kCFRunLoopAfterWaiting:
                NSLog(@"休眠结束");
                break;
            case kCFRunLoopExit:
                NSLog(@"运行循环退出");
                break;
            default:
                break;
        }
    });
    CFRunLoopAddObserver(CFRunLoopGetCurrent(),observer, kCFRunLoopDefaultMode);
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
