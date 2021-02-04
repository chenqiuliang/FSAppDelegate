//
//  FSAppDelegateUIService.m
//  FSAppDelegate
//
//  Created by ChenQiuLiang on 2021/2/4.
//

#import "FSAppDelegateUIService.h"
#import "ViewController.h"

@implementation FSAppDelegateUIService

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //启动时不处于竖屏状态，设置为竖屏（修复横屏开播时杀掉进程立即重启进入app界面错乱问题）
    if (application.statusBarOrientation != UIInterfaceOrientationPortrait) {
        application.statusBarOrientation = UIInterfaceOrientationPortrait;
    }
    
    // iOS11 UI适配
    [self ios11Compatibility];
    
    [self setHomePage:launchOptions];
    
    //创建应用图标上的3D touch快捷选项
    [self creat3DTouchShortcutItemWithOptions:launchOptions];

    return YES;
}

//如果APP没被杀死，还存在后台，点开Touch会调用该代理方法
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    if (shortcutItem) {
        [self handle3DTouchItemClick:shortcutItem isFirstStartApp:NO];
    }
}

- (void)ios11Compatibility
{
    if(@available(iOS 11.0, *)){
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        [[UITableView appearance] setEstimatedRowHeight:0];
        [[UITableView appearance] setEstimatedSectionFooterHeight:0];
        [[UITableView appearance] setEstimatedSectionHeaderHeight:0];
    }
}

#pragma mark - 3D Touch
//创建应用图标上的3D touch快捷选项
- (void)creat3DTouchShortcutItemWithOptions:(NSDictionary *)launchOptions
{
    //一键开播
    //    UIApplicationShortcutIcon *oneKeyOpenLiveIcon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeCaptureVideo];
    BOOL canSet3DTouch = [[UIApplication sharedApplication] respondsToSelector:@selector(setShortcutItems:)];
    if(canSet3DTouch){
        UIApplicationShortcutIcon *oneKeyOpenLiveIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"app3DTouch_onekeyOpenLive"];
        UIApplicationShortcutItem *oneKeyOpenLiveItem = [[UIApplicationShortcutItem alloc] initWithType:@"fansheng://?type=200"
                                                                                         localizedTitle:@"一键开播"
                                                                                      localizedSubtitle:@""
                                                                                                   icon:oneKeyOpenLiveIcon
                                                                                               userInfo:nil];
        //分享
        UIApplicationShortcutIcon *attentionIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"app3DTouch_attention"];
        UIApplicationShortcutItem *attentionItem = [[UIApplicationShortcutItem alloc] initWithType:@"fansheng://?type=201"
                                                                                    localizedTitle:@"关注的主播"
                                                                                 localizedSubtitle:@""
                                                                                              icon:attentionIcon
                                                                                          userInfo:nil];
        //签到
        UIApplicationShortcutIcon *checkInIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"app3DTouch_checkin"];
        UIApplicationShortcutItem *checkInItem = [[UIApplicationShortcutItem alloc] initWithType:@"fansheng://?type=202"
                                                                                  localizedTitle:@"签到"
                                                                               localizedSubtitle:@""
                                                                                            icon:checkInIcon
                                                                                        userInfo:nil];
        
        //添加到快捷选项数组
        [UIApplication sharedApplication].shortcutItems = @[checkInItem,attentionItem,oneKeyOpenLiveItem];
    }
}

- (void)handle3DTouchItemClick:(UIApplicationShortcutItem *)shortcutItem isFirstStartApp:(BOOL)isFirstStartApp
{
    if ([shortcutItem isKindOfClass:[UIApplicationShortcutItem class]]) {
        if ([shortcutItem.type isEqualToString:@"fansheng://?type=200"]) {
            // 一键开播
        } else if ([shortcutItem.type isEqualToString:@"fansheng://?type=201"]) {
            // 关注的主播
        }else if ([shortcutItem.type isEqualToString:@"fansheng://?type=202"]) {
            // 签到
        }
    }
}

#pragma mark - Utils

- (void)setHomePage:(NSDictionary *)launchOptions
{
    // 启动图、引导图和广告逻辑
    [UIApplication sharedApplication].delegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    ViewController *controller = [[ViewController alloc] init];
    [UIApplication sharedApplication].delegate.window.rootViewController = controller;
    [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
}

@end

FSAppDelegateServiceRegister(FSAppDelegateUIService, FSAppDelegateServicePriorityUI)
