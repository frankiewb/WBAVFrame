//
//  WBRecorderGPUImageFilter.m
//  WBNAtiveRecorder
//
//  Created by 王博 on 2017/8/7.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBRecorderGPUImageFilter.h"

@interface WBRecorderGPUImageFilter ()

//美颜滤镜
@property (nonatomic, strong) GPUImageBeautifyFilter *beautyFilter;
//卡通滤镜
@property (nonatomic, strong) GPUImageToonFilter *toonFilter;
//素描滤镜
@property (nonatomic, strong) GPUImageSketchFilter *sketchFilter;
//像素化滤镜
@property (nonatomic, strong) GPUImagePixellateFilter *pixellateFilter;

@end


@implementation WBRecorderGPUImageFilter

SingletonM(WBRecorderGPUImageFilter)


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        self.filterImageRenderingContext = [CIContext contextWithEAGLContext:eaglContext];
        
        //初始化滤镜
        self.beautyFilter = [[GPUImageBeautifyFilter alloc] init];
        self.toonFilter = [[GPUImageToonFilter alloc] init];
        self.sketchFilter = [[GPUImageSketchFilter alloc] init];
        self.pixellateFilter = [[GPUImagePixellateFilter alloc] init];
    }
    
    return self;
}



+ (CIImage *)getRecorderGPUImageFilterWithSmapleBuffer:(CMSampleBufferRef)sampleBuffer valueDic:(NSMutableDictionary *)dic
{
    WBRecorderGPUImageFilter *gpuImageFilter = [WBRecorderGPUImageFilter sharedWBRecorderGPUImageFilter];
    
    //美颜滤镜 beautifyFilterEnable
    NSNumber *beautifyFilterEnable = [dic valueForKey:@"beautifyFilterEnable"];
    //卡通滤镜 toonFilterEnbale
    NSNumber *toonFilterEnbale = [dic valueForKey:@"toonFilterEnbale"];
    //素描滤镜 sketchFilterEnable
    NSNumber *sketchFilterEnable = [dic valueForKey:@"sketchFilterEnable"];
    //像素化滤镜 pixellateFilterEnbale
    NSNumber *pixellateFilterEnbale = [dic valueForKey:@"pixellateFilterEnbale"];
    
    CVImageBufferRef imageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    //任何滤镜都没设置则直接不走滤镜
    if ([beautifyFilterEnable isEqual:@(0)] &&
        [toonFilterEnbale isEqual:@(0)] &&
        [sketchFilterEnable isEqual:@(0)] &&
        [pixellateFilterEnbale isEqual:@(0)])
    {
        CIImage *finalFilterImage = [CIImage imageWithCVPixelBuffer:(CVPixelBufferRef)imageBufferRef];
        return finalFilterImage;
    }
    
    //CMSampleBuffer转换为GPUImagePicture
    CGImageRef imageBuffer = [WBRecorderGPUImageFilter cgImageRefConverterWithCVImageBufferRef:imageBufferRef];
    GPUImagePicture *imagePic = [[GPUImagePicture alloc] initWithCGImage:imageBuffer];
    GPUImageOutput *finalFilter = nil;
    
    //添加滤镜
    //此处没有设置多重滤镜叠加，如加入需要设置filterGroup，现行逻辑不支持滤镜叠加
    if ([beautifyFilterEnable isEqual:@(1)])
    {
        [imagePic addTarget:gpuImageFilter.beautyFilter];
        finalFilter = gpuImageFilter.beautyFilter;
    }
    if ([toonFilterEnbale isEqual:@(1)])
    {
        [imagePic addTarget:gpuImageFilter.toonFilter];
        finalFilter = gpuImageFilter.toonFilter;
    }
    if ([sketchFilterEnable isEqual:@(1)])
    {
        [imagePic addTarget:gpuImageFilter.sketchFilter];
        finalFilter = gpuImageFilter.sketchFilter;
    }
    if ([pixellateFilterEnbale isEqual:@(1)])
    {
        [imagePic addTarget:gpuImageFilter.pixellateFilter];
        finalFilter = gpuImageFilter.pixellateFilter;
    }
    
    //渲染滤镜，注意useNetFrame函数的调用顺序，如果放置在processImage后容易渲染不出UIImage图像出来
    // If you're trying to use these methods, remember that you need to set -useNextFrameForImageCapture before running -processImage or running video and calling any of these methods, or you will get a nil image
    [finalFilter useNextFrameForImageCapture];
    [imagePic processImage];
    
    
    //GPUImagePicture 转换为CIImage
    UIImage *filteredUIImage = [ finalFilter imageFromCurrentFramebuffer];
    CIImage *filteredCIImage = [[CIImage alloc] initWithImage:filteredUIImage];
    CIContext *filterImageContext = [WBRecorderGPUImageFilter sharedWBRecorderGPUImageFilter].filterImageRenderingContext;
    [filterImageContext render:filteredCIImage toCVPixelBuffer:imageBufferRef];
    CFRelease(imageBuffer);
    return filteredCIImage;
    
}


+ (CGImageRef)cgImageRefConverterWithCVImageBufferRef:(CVImageBufferRef)imageBuffer
{
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return quartzImage;
    
}




@end
