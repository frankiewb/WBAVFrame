//
//  MBProgressHUD+Utils.m
//  WBUtils
//
//  Created by WangBo on 2017/6/27.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "MBProgressHUD+Utils.h"

@implementation MBProgressHUD (Utils)
#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hideAnimated:YES afterDelay:0.7];
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success.png" view:view];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
#warning 忽略特定警告方法
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    // YES代表需要蒙版效果
    hud.dimBackground = YES;
#pragma clang diagnostic pop
    
        return hud;
}

+ (void)showSuccess:(NSString *)success
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showSuccess:success toView:nil];
    });
    
}

+ (void)showError:(NSString *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showError:error toView:nil];
    });
    
    
}

+ (MBProgressHUD *)showMessage:(NSString *)message
{
    return [self showMessage:message toView:nil];
}

+ (void)hideHUDForView:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD
{
    [self hideHUDForView:nil];
}

+ (void)showMsgWithView:(UIView *)uiview  isTransForm:(BOOL)isTransForm  text:(NSString *)labelText showTime:(CGFloat)time
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:uiview];
    if (isTransForm) {
        hud.transform = CGAffineTransformMakeRotation(-M_PI/2);;
    }
    hud.mode = MBProgressHUDModeText;
    hud.label.text = labelText;
    hud.removeFromSuperViewOnHide = YES;
    [hud showAnimated:YES];
    [uiview addSubview:hud];
    [hud hideAnimated:YES afterDelay:time];
}

+ (void)showMsgWithView:(UIView *)uiview  text:(NSString *)labelText showTime:(CGFloat)time
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:uiview];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = labelText;
    hud.removeFromSuperViewOnHide = YES;
    [hud showAnimated:YES];
    [uiview addSubview:hud];
    [hud hideAnimated:YES afterDelay:time];
}


+ (void)showMsg:(NSString *)labelText showTime:(CGFloat)time
{
    UIView * view = [UIApplication sharedApplication].windows.lastObject;
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = labelText;
    hud.removeFromSuperViewOnHide = YES;
    [hud showAnimated:YES];
    [view addSubview:hud];
    [hud hideAnimated:YES afterDelay:time];
}
@end
