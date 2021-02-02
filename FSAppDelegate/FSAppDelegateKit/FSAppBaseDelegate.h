//
//  FSAppBaseDelegate.h
//  FSAppDelegate
//
//  Created by ChenQiuLiang on 2021/1/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSAppBaseDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)setSupportedInterfaceOrientation:(UIInterfaceOrientationMask)orientation;

@end

NS_ASSUME_NONNULL_END
