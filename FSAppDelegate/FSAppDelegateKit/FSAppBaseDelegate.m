//
//  FSAppBaseDelegate.m
//  FSAppDelegate
//
//  Created by ChenQiuLiang on 2021/1/19.
//

#import "FSAppBaseDelegate.h"
#import "FSAppDelegateServiceManager.h"
#import <objc/message.h>
#import <objc/runtime.h>

@interface FSAppBaseDelegate ()

@property (nonatomic, copy) NSArray<NSString *> *appDelegateMethods;
@property (nonatomic, assign) UIInterfaceOrientationMask interfaceOrientation; // 默认值 UIInterfaceOrientationMaskPortrait

@end

@implementation FSAppBaseDelegate

/// 初始化 并设置加载顺序
- (instancetype)init
{
    if (self = [super init]) {
        [[FSAppDelegateServiceManager sharedManager] setup];
        _appDelegateMethods = [self getAppDelegateMethods];
        _interfaceOrientation = UIInterfaceOrientationMaskPortrait;
    }
    return self;
}

/// 是否可以作为第一响应者
- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - 消息转发

/**
 * 获取UIApplicationDelegate代理的方法名列表
 * @return  方法名列表
 */
- (NSArray<NSString *> *)getAppDelegateMethods
{
    static NSMutableArray *methods = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        unsigned int methodCount = 0;
        struct objc_method_description *methodList =
            protocol_copyMethodDescriptionList(@protocol(UIApplicationDelegate),
                                               NO, YES, &methodCount);
        methods = [NSMutableArray arrayWithCapacity:methodCount];
        for (int i = 0; i < methodCount; i++) {
            struct objc_method_description md = methodList[i];
            [methods addObject:NSStringFromSelector(md.name)];
        }
        free(methodList);
    });
    return methods;
}
/**
 * 判断是否实现了某个方法
 * @param aSelector 方法
 * @return 是否可以响应
 */
- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL canResponse = [self methodForSelector:aSelector] != nil &&
                       [self methodForSelector:aSelector] != _objc_msgForward;
    if (!canResponse && [self.appDelegateMethods
                            containsObject:NSStringFromSelector(aSelector)]) {
        canResponse = [[FSAppDelegateServiceManager sharedManager]
            proxyCanResponseToSelector:aSelector];
    }
    return canResponse;
}
/**
* 通过消息转发 交给DYAppDelegateServiceManager处理
* @param anInvocation 消息转发
*/
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [[FSAppDelegateServiceManager sharedManager]
        proxyForwardInvocation:anInvocation];
}

#pragma mark - 屏幕方向

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window
{
    return self.interfaceOrientation;
}

- (void)setSupportedInterfaceOrientation:(UIInterfaceOrientationMask)orientation
{
    self.interfaceOrientation = orientation;
}

@end
