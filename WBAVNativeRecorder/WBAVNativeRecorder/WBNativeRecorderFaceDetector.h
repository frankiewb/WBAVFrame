//
//  WBNativeRecorderFaceDetector.h
//  WBAVNAtiveRecorder
//
//  Created by 王博 on 2017/8/8.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>


//人脸及五官识别：直播贴纸功能实现的先决条件

@interface WBNativeRecorderFaceDetector : NSObject

SingletonH(WBNativeRecorderFaceDetector)

#pragma mark 原生面部识别兼贴纸渲染入口
+ (CIImage *)getNativeFaceDetectorRenderImageWithSmapleBuffer:(CMSampleBufferRef)sampleBuffer valueDic:(NSMutableDictionary *)dic;


@end
