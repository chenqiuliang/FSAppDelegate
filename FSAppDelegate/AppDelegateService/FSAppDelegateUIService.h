//
//  FSAppDelegateUIService.h
//  FSAppDelegate
//
//  Created by ChenQiuLiang on 2021/2/4.
//

#import <Foundation/Foundation.h>
#import "FSAppDelegateServiceManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 工程UI启动处理,设置rootVC,广告、检查版本、appStore好评等
 */
@interface FSAppDelegateUIService : NSObject <FSAppDelegateService>

@end

NS_ASSUME_NONNULL_END
