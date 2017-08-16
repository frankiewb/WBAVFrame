//
//  UIImage+Utils.h
//  WBUtils
//
//  Created by 王博 on 2017/8/16.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)

/**
 调整图片方向
 */
+ (UIImage *)fixOrientation:(UIImage *)aImage;

/**
 获取图片压缩的目标尺寸
 */
+(CGSize) retriveScaleDstSize:(CGSize) srcSize;

/**
 修改图片尺寸
 
 @param newSize 新的尺寸
 
 */
- (UIImage*)resizeImageWithNewSize:(CGSize)newSize;

- (UIImage*)scaleImageWithMaxWidth:(CGFloat)maxWidth;


@end
