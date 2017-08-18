//
//  WBRecorderCIFilter.h
//  WBNAtiveRecorder
//
//  Created by 王博 on 2017/8/1.
//  Copyright © 2017年 王博. All rights reserved.
//


//原生视频渲染滤镜

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface WBRecorderCIFilter : NSObject

SingletonH(WBRecorderCIFilter)


@property (nonatomic, strong) CIContext *filterImageRenderingContext;//滤镜优化后渲染工作上下文

#pragma mark 子渲染入口，适用于单个渲染滤镜
//指定待渲染图片，待渲染滤镜名称（iOS自带滤镜），参数不指定采用系统默认渲染参数
+(CIImage *)getAdjustFilterImageWithCIImage:(CIImage *)image FilterName:(NSString *)filterName;

//指定待渲染图片,待渲染滤镜名称（iOS自带滤镜），待渲染参数
+ (CIImage *)getAdjustFilterImageWithCIImage:(CIImage *)image FilterName:(NSString *)filterName  FilterValueName:(NSString *)filterValueName FilterValue:(CGFloat)value;


#pragma mark 总渲染入口,集成指定渲染滤镜集合
+ (CIImage *)getRecorderCIFilterImageWithSmapleBuffer:(CMSampleBufferRef)sampleBuffer valueDic:(NSMutableDictionary *)dic;

#pragma mark 需要单独设置的渲染滤镜
//亮度+饱和度+对比度调整
+ (CIImage *)getColorControlsAdjustFilterImageWithCIImage:(CIImage *)image saturationValue:(CGFloat)value brightnessValue:(CGFloat)value contrastValue:(CGFloat)value;


@end
