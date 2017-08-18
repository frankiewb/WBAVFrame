//
//  WBRecorderPreView.m
//  WBAVNAtiveRecorder
//
//  Created by 王博 on 2017/8/1.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBRecorderPreView.h"


@interface WBRecorderPreView ()

@property (nonatomic, strong) CIContext *preViewImageRenderingContext;//滤镜优化后渲染工作上下文

@property (nonatomic, strong) CIImage *currentRenderImage;//当前滤镜渲染图片

@end



@implementation WBRecorderPreView

- (instancetype)initWithFrame:(CGRect)frame
{
    EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self = [super initWithFrame:frame context:eaglContext];
    if (self)
    {
        self.preViewImageRenderingContext = [CIContext contextWithEAGLContext:eaglContext];
        self.clipsToBounds = YES;
        self.enableSetNeedsDisplay = NO;
    }
    
    return self;
}


- (void)displayPreViewWithUpdatedImage:(CIImage *)filteredImage
{
    self.currentRenderImage = filteredImage;
    [self display];
}


//确保输出图片按比例平铺预览渲染展示页面
- (void)drawRect:(CGRect)rect
{
    // 以像素为单位 Plus的点宽度x密度 ！= 像素
    CGFloat scale = [[UIScreen mainScreen]scale];
    if (scale == 3)
    {
        scale = 1080 / [UIScreen mainScreen].bounds.size.width;
    }
    CGRect destRect = CGRectApplyAffineTransform(self.bounds, CGAffineTransformMakeScale(scale, scale));
    CGRect fromRect = self.currentRenderImage.extent;
    CGFloat dest_w  = destRect.size.width;
    CGFloat dest_h  = destRect.size.height;
    
    
    // 确保渲染到的View 宽高比和原始比例一致
    CGFloat ratio = fromRect.size.width / fromRect.size.height;
    if (dest_w / dest_h > ratio)
    { // 渲染的宽度超出比例 高度也要增加
        CGFloat increase_h = dest_w / ratio - dest_h;
        destRect = CGRectMake(0, -increase_h, dest_w, dest_w / ratio); // 顶端对齐
    }
    else
    { // 渲染的高度超出比例 宽度也要增加
        CGFloat increase_w = dest_h * ratio - dest_w;
        destRect = CGRectMake(0 - increase_w * 0.5, 0, dest_h * ratio, dest_h);
    }
    
    // 以左下角为(0,0) 向上y增加 向右x增加
    [self.preViewImageRenderingContext drawImage:self.currentRenderImage inRect:destRect fromRect:fromRect];
}


@end
