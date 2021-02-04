//
//  FSAppDelegateBaseService.m
//  FSAppDelegate
//
//  Created by ChenQiuLiang on 2021/2/4.
//

#import "FSAppDelegateBaseService.h"


@implementation FSAppDelegateBaseService

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // do something
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // do something
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // do something
}

- (void)applicationWillEnterForeground:(UIApplication *)application NS_AVAILABLE_IOS(4_0)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // upload log
    });
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // do something
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // stop NetworkReachability Monitoring
    // save userInfo
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    // do something
    return NO;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler
{
    // do something
    return NO;
}

@end

FSAppDelegateServiceRegister(FSAppDelegateBaseService, FSAppDelegateServicePriorityBase)
