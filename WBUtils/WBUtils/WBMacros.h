//
//  WBMacros.h
//  WBUtils
//
//  Created by WangBo on 2017/6/27.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>


#define WBScreenWidth     MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define WBScreenHeight    MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)


// 比例系数 按照屏幕iPhone6适配
#define WBDeviceScale6     ([UIScreen mainScreen].bounds.size.width / 375.f)


#define WEAK_SELF __weak typeof(self)weakSelf = self
#define STRONG_SELF typeof(self) strongSelf = weakSelf;

#define LOG_METHOD NSLog(@"%s", __func__);
