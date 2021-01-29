//
//  FSAppDelegateServiceMetaInfo.h
//  FSAppDelegate
//
//  Created by ChenQiuLiang on 2021/1/19.
//

#ifndef FSAppDelegateServiceMetaInfo_h
#define FSAppDelegateServiceMetaInfo_h

/// 结构体，用于编译期注册
struct FSAppDelegateServiceMetaInfo {
    char *className;
    long priority;
};

#endif /* FSAppDelegateServiceMetaInfo_h */
