//
//  FSAppDelegateServicePriority.h
//  FSAppDelegate
//
//  Created by ChenQiuLiang on 2021/1/28.
//

#ifndef FSAppDelegateServicePriority_h
#define FSAppDelegateServicePriority_h

typedef NS_ENUM(NSUInteger, FSAppDelegateServicePriority) {
    FSAppDelegateServicePriorityBase,   // 基础业务
    FSAppDelegateServicePriorityUI,   // UI业务
    FSAppDelegateServicePriorityLogin,   // 登陆业务
    FSAppDelegateServicePriorityOthers,
};


#endif /* FSAppDelegateServicePriority_h */
