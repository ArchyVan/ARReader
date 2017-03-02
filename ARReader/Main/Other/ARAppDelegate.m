//
//  ARAppDelegate.m
//  ARReader
//
//  Created by Objective-C on 2017/2/9.
//  Copyright © 2017年 Archy Van. All rights reserved.
//

#import "ARAppDelegate.h"
#import "ARReaderCenter.h"
#import "ARGCDCenter.h"


@interface ARAppDelegate ()

@end

@implementation ARAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    ARReaderCenter *center = [[ARReaderCenter alloc] init];
    self.window.rootViewController = center;
    [self.window makeKeyAndVisible];
    return YES;
}


@end
