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

#pragma mark - AppDelegate单个服务项

@implementation FSAppDelegateServiceItem

@end

#pragma mark - 由数据段读取 服务列表

void dyld_callback(const struct mach_header *mhp, intptr_t vmaddr_slide)
{
    unsigned long size = 0;
#ifndef __LP64__
    uint32_t *memory = (uint32_t*)getsectiondata(mhp, "__DATA", FSADServicesSectionName, &size);
#else /* defined(__LP64__) */
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *)mhp;
    uint64_t *memory = (uint64_t*)getsectiondata(mhp64, "__DATA", FSADServicesSectionName, &size);
#endif /* defined(__LP64__) */
    
    unsigned long count = size / sizeof(struct FSAppDelegateServiceMetaInfo);
    struct FSAppDelegateServiceMetaInfo *infos = (struct FSAppDelegateServiceMetaInfo *)memory;
    
    for(int index = 0; index < count; index++){
        struct FSAppDelegateServiceMetaInfo info = infos[index];
        NSString *classStr = [NSString stringWithUTF8String:info.className];
        NSInteger priority = info.priority;
        if (!classStr || !classStr.length) {
            continue;
        }
        FSAppDelegateServiceItem *item = [[FSAppDelegateServiceItem alloc] init];
        Class class = NSClassFromString(classStr);
        if (class) {
            item.service = [class new];
            item.priority = priority;
            [[FSAppDelegateServiceManager sharedManager]
                registerService:item];
        }
    }
}

__attribute__((constructor)) void initProphet()
{
    _dyld_register_func_for_add_image(dyld_callback);
}

#pragma mark - appdelegate服务管理者

@interface FSAppDelegateServiceManager ()

@property (nonatomic, strong)
    NSMutableArray<FSAppDelegateServiceItem *> *services;
@property (nonatomic, strong) dispatch_queue_t launchHandlerQueue;

@end

@implementation FSAppDelegateServiceManager

+ (instancetype)sharedManager
{
    static FSAppDelegateServiceManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[FSAppDelegateServiceManager alloc] init];
    });

    return _sharedManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _services = [[NSMutableArray alloc] init];
        _launchHandlerQueue = dispatch_queue_create("com.fansheng.launchHandlerQueue", DISPATCH_QUEUE_SERIAL);
    }

    return self;
}

/// 预加载加载顺序
- (void)setup
{
    NSArray *sortedArray = [_services sortedArrayUsingComparator:^NSComparisonResult(FSAppDelegateServiceItem *obj1, FSAppDelegateServiceItem *obj2) {
        if (obj1.priority > obj2.priority)
            return NSOrderedDescending;

        return NSOrderedAscending;
    }];
    _services = [sortedArray mutableCopy];
}

/// 注册服务
/// @param service 单个服务
- (void)registerService:(FSAppDelegateServiceItem *)service
{
    if (service) {
        [_services addObject:service];
    }
}

#pragma mark - Proxy
- (BOOL)proxyCanResponseToSelector:(SEL)aSelector
{
    __block IMP imp = NULL;
    [self.services enumerateObjectsUsingBlock:^(FSAppDelegateServiceItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id<FSAppDelegateService> service = obj.service;
        if ([service respondsToSelector:aSelector]) {
            imp = [(id)service methodForSelector:aSelector];
            *stop = YES;
        }
    }];

    return imp != NULL && imp != _objc_msgForward;
}

- (NSString *)objcTypesFromSignature:(NSMethodSignature *)signature
{
    NSMutableString *types = [NSMutableString
        stringWithFormat:@"%s", signature.methodReturnType ?: "v"];
    for (NSUInteger i = 0; i < signature.numberOfArguments; i++) {
        [types appendFormat:@"%s", [signature getArgumentTypeAtIndex:i]];
    }
    return [types copy];
}

- (void)proxyForwardInvocation:(NSInvocation *)anInvocation
{
    NSMethodSignature *signature = anInvocation.methodSignature;
    NSUInteger argCount = signature.numberOfArguments;
    __block BOOL returnValue = NO;
    NSUInteger returnLength = signature.methodReturnLength;
    void *returnValueBytes = NULL;
    if (returnLength > 0) {
        returnValueBytes = alloca(returnLength);
    }

    [self.services enumerateObjectsUsingBlock:^(FSAppDelegateServiceItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id<FSAppDelegateService> service = obj.service;
        if (![service respondsToSelector:anInvocation.selector]) {
            return;
        }
        
        // check the signature
        NSAssert(([[self objcTypesFromSignature:signature] isEqualToString:[self objcTypesFromSignature:[(id)service methodSignatureForSelector:anInvocation.selector]]]), @"Method signature for selector (%@) on `%@` is invalid. \
                 Please check the return value type and arguments type.", NSStringFromSelector(anInvocation.selector), service);
        
        // copy the invokation
        NSInvocation *invok =
            [NSInvocation invocationWithMethodSignature:signature];
        invok.selector = anInvocation.selector;
        // copy arguments
        for (NSUInteger i = 0; i < argCount; i++) {
            const char *argType = [signature getArgumentTypeAtIndex:i];
            NSUInteger argSize = 0;
            NSGetSizeAndAlignment(argType, &argSize, NULL);

            void *argValue = alloca(argSize);
            [anInvocation getArgument:&argValue atIndex:i];
            [invok setArgument:&argValue atIndex:i];
        }
        // reset the target
        invok.target = service;
        // invoke
        [invok invoke];

        // get the return value
        if (returnValueBytes) {
            [invok getReturnValue:returnValueBytes];
            if (strcmp(signature.methodReturnType, @encode(BOOL)) == 0) {
                returnValue = returnValue || *((BOOL *)returnValueBytes);
            } else {
                returnValue = returnValue;
            }
        }
    }];

    // set return value
    if (returnValueBytes) {
        [anInvocation setReturnValue:returnValueBytes];
    }
}

@end

@implementation FSAppDelegateServiceManager (Convenience)

- (void)executeInLaunchQueue:(dispatch_block_t)block
{
    if (!block) {
        return;
    }
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(self.launchHandlerQueue)) {
        block();
    }
    else {
        dispatch_async(self.launchHandlerQueue, block);
    }
}

@end
