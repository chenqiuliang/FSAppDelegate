//
//  main.m
//  FSAppDelegate
//
//  Created by ChenQiuLiang on 2021/1/19.
//

#import <UIKit/UIKit.h>
#import "FSAppBaseDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([FSAppBaseDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
