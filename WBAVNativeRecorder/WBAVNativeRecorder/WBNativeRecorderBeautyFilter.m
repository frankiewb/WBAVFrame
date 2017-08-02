//
//  WBNativeRecorderBeautyFilter.m
//  WBAVNAtiveRecorder
//
//  Created by 王博 on 2017/8/1.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBNativeRecorderBeautyFilter.h"


#pragma mark 常用的自动滤镜
//CIRedEyeCorrection：修复因相机的闪光灯导致的各种红眼
//CIFaceBalance：调整肤色
//CIVibrance：在不影响肤色的情况下，改善图像的饱和度
//CIToneCurve：改善图像的对比度
//CIHighlightShadowAdjust：改善阴影细节


@implementation WBNativeRecorderBeautyFilter

SingletonM(WBNativeRecorderBeautyFilter)


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        self.filterImageRenderingContext = [CIContext contextWithEAGLContext:eaglContext];
    }
    
    return self;
}

+ (CIImage *)getAdjustFilterImageWithCIImage:(CIImage *)image FilterName:(NSString *)filterName FilterValueName:(NSString *)filterValueName FilterValue:(CGFloat)value
{
    //依据滤镜名获取滤镜
    CIFilter *filter = [CIFilter filterWithName:filterName];
    //设置待渲染图片
    [filter setValue:image forKey:kCIInputImageKey];
    //设置滤镜修改参数名称及参数值
    if(filterValueName || value != 9999)
    {
        [filter setValue:@(value) forKey:filterValueName];
    }
    
    return filter.outputImage;
}

+(CIImage *)getAdjustFilterImageWithCIImage:(CIImage *)image FilterName:(NSString *)filterName
{
    return [WBNativeRecorderBeautyFilter getAdjustFilterImageWithCIImage:image FilterName:filterName FilterValueName:nil FilterValue:9999];
}


//亮度+饱和度+对比度调整
+ (CIImage *)getColorControlsAdjustFilterImageWithCIImage:(CIImage *)image saturationValue:(CGFloat)saturationValue brightnessValue:(CGFloat)brightnessValue contrastValue:(CGFloat)contrastValue
{
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:image forKey:kCIInputImageKey];
    
    //饱和度调节
    [filter setValue:@(saturationValue) forKey:@"inputSaturation"];
    //对比度调节
    [filter setValue:@(contrastValue) forKey:@"inputContrast"];
    //亮度调节
    [filter setValue:@(brightnessValue) forKey:@"inputBrightness"];
    
    return [filter outputImage];
}





+ (CIImage *)getNativeBeautyFilterImageWithSmapleBuffer:(CMSampleBufferRef)sampleBuffer valueDic:(NSMutableDictionary *)dic
{
    //获取滤镜参数
    NSNumber * saturationValue = [dic valueForKey:@"saturationValue"];
    if (!saturationValue)
    {
        saturationValue = @(1);
    }
    NSNumber * contrastValue = [dic valueForKey:@"contrastValue"];
    if (!contrastValue)
    {
        contrastValue = @(1);
    }
    NSNumber * brightnessValue = [dic valueForKey:@"brightnessValue"];
    if (!brightnessValue)
    {
        brightnessValue = @(0);
    }
    NSNumber *gaussianBlurValue = [dic valueForKey:@"gaussianBlurValue"];
    if (!gaussianBlurValue)
    {
        gaussianBlurValue = @(0);
    }
    
    //从SampleBuffer中提取CIImage
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *finalFilterImage = [CIImage imageWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer];
    
    //依次进行滤镜组过滤
    //阴影过滤
    finalFilterImage = [WBNativeRecorderBeautyFilter getAdjustFilterImageWithCIImage:finalFilterImage
                                                                          FilterName:@"CIHighlightShadowAdjust"
                                                                     FilterValueName:@"inputShadowAmount"
                                                                         FilterValue:-1];
    
    //灰度过滤
    finalFilterImage = [WBNativeRecorderBeautyFilter getAdjustFilterImageWithCIImage:finalFilterImage
                                                                          FilterName:@"CIGammaAdjust"
                                                                     FilterValueName:@"inputPower"
                                                                         FilterValue:1.2];
    
    //白平衡
    finalFilterImage = [WBNativeRecorderBeautyFilter getAdjustFilterImageWithCIImage:finalFilterImage
                                                                          FilterName:@"CIWhitePointAdjust"];
    
    //曝光
    finalFilterImage = [WBNativeRecorderBeautyFilter getAdjustFilterImageWithCIImage:finalFilterImage
                                                                          FilterName:@"CIExposureAdjust"
                                                                     FilterValueName:@"inputEV"
                                                                         FilterValue:0.5];
    
    //高斯模糊
    finalFilterImage = [WBNativeRecorderBeautyFilter getAdjustFilterImageWithCIImage:finalFilterImage
                                                                          FilterName:@"CIGaussianBlur"
                                                                     FilterValueName:@"inputRadius"
                                                                         FilterValue:gaussianBlurValue.floatValue];
    
    //亮度+饱和度+对比度调整
    finalFilterImage = [WBNativeRecorderBeautyFilter getColorControlsAdjustFilterImageWithCIImage:finalFilterImage
                                                                                  saturationValue:saturationValue.floatValue
                                                                                  brightnessValue:brightnessValue.floatValue
                                                                                    contrastValue:contrastValue.floatValue];
    
    CIContext *filterImageContext = [WBNativeRecorderBeautyFilter sharedWBNativeRecorderBeautyFilter].filterImageRenderingContext;
    [filterImageContext render:finalFilterImage toCVPixelBuffer:imageBuffer];

    return finalFilterImage;
}





@end
