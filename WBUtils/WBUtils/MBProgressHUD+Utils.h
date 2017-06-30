//
//  MBProgressHUD+Utils.h
//  WBUtils
//
//  Created by WangBo on 2017/6/27.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (Utils)
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;
+ (void)showMsgWithView:(UIView *)uiview isTransForm:(BOOL)isTransForm text:(NSString *)labelText showTime:(CGFloat)time;
+ (void)showMsgWithView:(UIView *)uiview  text:(NSString *)labelText showTime:(CGFloat)time;


+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;

+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view;


+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;

+ (MBProgressHUD *)showMessage:(NSString *)message;

+ (void)showMsg:(NSString *)labelText showTime:(CGFloat)time;

+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;

@end
