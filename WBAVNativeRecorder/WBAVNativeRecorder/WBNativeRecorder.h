//
//  WBNativeRecorder.h
//  WBAVNAtiveRecorder
//
//  Created by 王博 on 2017/8/10.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


typedef NS_ENUM(NSInteger,WBNativeRecorderType)
{
    WBNativeRecorderTypeLive = 1,//直播模式 = 采集 + 前处理 + 编码（软硬）+ 推流
    WBNativeRecorderTypeVideo = 2,//录像模式 = 采集 + 前处理 + 音频视频合成到指定位置存储
};

@interface WBNativeRecorder : NSObject

//初始化函数
- (instancetype)initWithLivePreViewLayer:(UIView *)preViewLayer recorderType:(WBNativeRecorderType) recorderType;

//销毁函数
- (void)destroy;

//开始录播
- (void)startRecord;

//停止录播
- (void)stopRecord;

//反转摄像头
- (void)turnCamera;

//切换闪光灯状态
- (void)turnTorchModeStatus;

//设置当前采集设备聚焦点及对应聚焦点的聚焦模式及曝光模式
- (void)setFocusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atScreenPoint:(CGPoint)point;

//设置录像器前处理滤镜渲染参数
- (void)setVideoImageFilterValueInfoDic:(NSMutableDictionary *)valueDic;







@end
