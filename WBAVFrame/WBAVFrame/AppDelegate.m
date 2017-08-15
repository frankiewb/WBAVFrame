//
//  AppDelegate.m
//  WBAVFrame
//
//  Created by WangBo on 2017/6/27.
//  Copyright © 2017年 WangBo. All rights reserved.
//

#import "AppDelegate.h"
#import "WBAVRootViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "MBProgressHUD+Utils.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window =  [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[WBAVRootViewController alloc] init]];
    [self.window makeKeyAndVisible];
    [self requestAVAuthorization];
    return YES;
}



//请求摄像头，麦克风以及用户相册使用权限
- (void)requestAVAuthorization
{
    //请求摄像头使用授权
    AVAuthorizationStatus avVideoStatusType = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (avVideoStatusType)
    {
        case AVAuthorizationStatusAuthorized:
            NSLog(@"已获得摄像头使用授权");
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusNotDetermined:
        case AVAuthorizationStatusDenied:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted)
                {
                    [MBProgressHUD showSuccess:@"已授权使用摄像头"];
                }
                else
                {
                    [MBProgressHUD showMessage:@"用户拒绝授权摄像头的使用, 返回上一页, 请打开--> 设置 -- > 隐私 --> 通用等权限设置"];
                }
            }];
        }
    }
    
    //请求麦克风使用授权
    AVAuthorizationStatus avAudioStatusType = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (avAudioStatusType)
    {
        case AVAuthorizationStatusAuthorized:
            NSLog(@"已获得麦克风使用授权");
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusNotDetermined:
        case AVAuthorizationStatusDenied:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (granted)
                {
                    [MBProgressHUD showSuccess:@"已授权使用麦克风"];
                }
                else
                {
                    [MBProgressHUD showMessage:@"用户拒绝授权麦克风的使用, 返回上一页, 请打开--> 设置 -- > 隐私 --> 通用等权限设置"];
                }
            }];
        }
    }
    
    //请求相册使用授权
    PHAuthorizationStatus photoAuthStatus = [PHPhotoLibrary authorizationStatus];
    switch (photoAuthStatus) {
        case PHAuthorizationStatusAuthorized:
            NSLog(@"已获得相册使用授权");
            break;
        case PHAuthorizationStatusNotDetermined:
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
                if (status == PHAuthorizationStatusAuthorized)
                {
                    [MBProgressHUD showSuccess:@"已授权使用相册"];
                }
                else
                {
                    [MBProgressHUD showMessage:@"用户拒绝授权相册的使用, 返回上一页, 请打开--> 设置 -- > 隐私 --> 通用等权限设置"];
                }
            }];
        }
    }
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
