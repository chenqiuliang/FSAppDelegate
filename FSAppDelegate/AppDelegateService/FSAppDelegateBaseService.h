//
//  FSAppDelegateBaseService.h
//  FSAppDelegate
//
//  Created by ChenQiuLiang on 2021/2/4.
//

#import <Foundation/Foundation.h>
#import "FSAppDelegateServiceManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 工程基础服务, 如: 日志、性能监控
 */
@interface FSAppDelegateBaseService : NSObject <FSAppDelegateService>

@end

NS_ASSUME_NONNULL_END
