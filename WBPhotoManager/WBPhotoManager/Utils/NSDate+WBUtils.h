//
//  NSDate+WBUtils.h
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/18.
//  Copyright © 2016年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBPhotoConfiguration.h"

@interface NSDate (WBUtils)

/**
 根据分组方式，生成对应字符串
 
 @param type 分组方式
 
 */
- (NSString *)stringByPhotosMomentsType:(WBImageMomentGroupType)type;

@end
