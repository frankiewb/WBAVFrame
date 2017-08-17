//
//  WBPhotoManagerEnumeration.h
//  WBUtils
//
//  Created by 王博 on 2017/8/16.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef WBPHOTOMANAGERENUMERATION_H
#define WBPHOTOMANAGERENUMERATION_H

typedef NS_ENUM(NSUInteger, WBImagePickerAccessType) {
    WBImagePickerAccessTypePhotosWithoutAlbums,        //无相册界面，但直接进入相册胶卷
    WBImagePickerAccessTypePhotosWithAlbums,           //有相册界面，但直接进入相册胶卷
    WBImagePickerAccessTypeAlbums                      //直接进入相册界面
};

typedef NS_ENUM(NSUInteger, WBImagePickerSourceType) {
    WBImagePickerSourceTypePhoto,              //图片
    WBImagePickerSourceTypeCamera,             //相机
    WBImagePickerSourceTypeSound               //声音
};

typedef NS_ENUM(NSUInteger, WBAuthorizationStatus) {
    WBAuthorizationStatusNotDetermined,        //未知
    WBAuthorizationStatusRestricted,           //受限制
    WBAuthorizationStatusDenied,               //拒绝
    WBAuthorizationStatusAuthorized            //授权
};

typedef NS_ENUM(NSUInteger, WBImageMomentGroupType) {
    WBImageMomentGroupTypeNone,          //无分组
    WBImageMomentGroupTypeYear,          //年
    WBImageMomentGroupTypeMonth,         //月
    WBImageMomentGroupTypeDay            //日
};

typedef NS_ENUM(NSUInteger, WBImagePickerStyle) {
    WBImagePickerStyleLight,       //浅色
    WBImagePickerStyleDark         //深色
};



#endif
