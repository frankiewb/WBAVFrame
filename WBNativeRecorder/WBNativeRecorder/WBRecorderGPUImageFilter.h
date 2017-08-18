//
//  WBRecorderGPUImageFilter.h
//  WBNAtiveRecorder
//
//  Created by 王博 on 2017/8/7.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBRecorderGPUImageFilter : NSObject

SingletonH(WBRecorderGPUImageFilter)

@property (nonatomic, strong) CIContext *filterImageRenderingContext;//滤镜优化后渲染工作上下文

#pragma mark 总渲染入口,集成指定渲染滤镜集合
+ (CIImage *)getRecorderGPUImageFilterWithSmapleBuffer:(CMSampleBufferRef)sampleBuffer valueDic:(NSMutableDictionary *)dic;


@end
