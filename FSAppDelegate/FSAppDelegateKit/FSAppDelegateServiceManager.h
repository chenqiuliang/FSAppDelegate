//
//  FSAppDelegateServiceManager.h
//  FSAppDelegate
//
//  Created by ChenQiuLiang on 2021/1/19.
//

#import <Foundation/Foundation.h>
#import "FSAppDelegateServiceMetaInfo.h"
#import "FSAppDelegateServicePriority.h"
#import "FSAppDelegateService.h"

NS_ASSUME_NONNULL_BEGIN

#define ExecuteInLaunchQueue(block) [[DYAppDelegateServiceManager sharedManager] executeInLaunchQueue:block]

#ifndef FSADServicesSectionName
#define FSADServicesSectionName "__FSADServices"
#endif

/// 动态注册服务，FSAppDelegateServiceRegister(FSAppDelegateBaseService, 6)
/// @param _className_ 类名（如 FSAppDelegateBaseService）
/// @param _priority_ 加载优先级（如 FSAppDelegateServicePriority 定义在枚举中）
#define FSAppDelegateServiceRegister(_className_, _priority_)                      \
__attribute__(                                                             \
    (used)) static struct FSAppDelegateServiceMetaInfo FSADModule##_class_        \
    __attribute((used, section("__DATA, __FSADServices"))) = {               \
        .className = #_className_, .priority = _priority_,                     \
};

@interface FSAppDelegateServiceItem : NSObject
@property (nonatomic, strong) id<FSAppDelegateService> service;
@property (nonatomic, assign) NSUInteger priority; // 优先级
@end


@interface FSAppDelegateServiceManager : NSObject

/**
 * 单例
 */
+ (instancetype)sharedManager;

/**
 注册service

 @param service 服务
 */
- (void)registerService:(FSAppDelegateServiceItem *)service;

/**
 * 加载顺序预处理
 */
- (void)setup;

/// 转发消息到实现了方法的服务方
/// @param aSelector 方法
- (BOOL)proxyCanResponseToSelector:(SEL)aSelector;

/// 转发消息到实现了方法的服务方
/// @param anInvocation NSInvocation对象
- (void)proxyForwardInvocation:(NSInvocation *)anInvocation;

@end
/**
* appdelegate服务管理者 分类
*/
@interface FSAppDelegateServiceManager (Convenience)

/// 在LaunchQueue执行某个操作
/// @param block 某个操作
- (void)executeInLaunchQueue:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
