//
//  FSAppDelegateServiceManager.m
//  FSAppDelegate
//
//  Created by ChenQiuLiang on 2021/1/19.
//

#import "FSAppDelegateServiceManager.h"
#import <objc/runtime.h>
#import <objc/message.h>
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#include <mach-o/ldsyms.h>

void ReadDataFromSection(const char *sectionName)
{
    Dl_info info;
    dladdr(ReadDataFromSection, &info);
    
#ifndef __LP64__
    const struct mach_header *mhp = (struct mach_header*)info.dli_fbase;
    unsigned long size = 0;
    uint32_t *memory = (uint32_t*)getsectiondata(mhp, "__DATA", sectionName, & size);
#else /* defined(__LP64__) */
    const struct mach_header_64 *mhp = (struct mach_header_64*)info.dli_fbase;
    unsigned long size = 0;
    uint64_t *memory = (uint64_t*)getsectiondata(mhp, "__DATA", sectionName, & size);
#endif /* defined(__LP64__) */
    
    unsigned long count = size / sizeof(struct FSAppDelegateServiceMetaInfo);
    struct FSAppDelegateServiceMetaInfo *infos = (struct FSAppDelegateServiceMetaInfo *)memory;
    
    for(int idx = 0; idx < count; idx++){
        struct FSAppDelegateServiceMetaInfo info = infos[idx];
        [FSAppDelegateServiceManager registerPRBox:info];
    }
}

__attribute__((constructor)) void initProphet()
{
    _dyld_register_func_for_add_image(ReadDataFromSection(FSADServicesSectionName));
}

static NSMutableDictionary *_registeredBoxes = nil;

@implementation FSAppDelegateServiceManager

+ (instancetype)sharedManager
{
    static DYAppDelegateServiceManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[DYAppDelegateServiceManager alloc] init];
    });

    return _sharedManager;
}

- (void)

+ (void)registerPRBox:(struct DYPRBoxRegisterMetaInfo)metaInfo
{
    NSString *boxName = [[NSString alloc] initWithUTF8String:metaInfo.boxName];
    long code = metaInfo.code;
    
    if (!_registeredBoxes) {
        _registeredBoxes = [NSMutableDictionary dictionary];
    }
    
    if (boxName) {
        [_registeredBoxes setObject:@(code) forKey:boxName];
    }
}

+ (NSDictionary<NSString *, NSNumber *> *)registeredBoxes
{
    return [_registeredBoxes copy];
}

@end
