//
//  WBNativeRecorder.h
//  WBNAtiveRecorder
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


//直播模式状态
typedef NS_ENUM(NSInteger,WBNativeLiveRecorderStatusType)
{
    WBNativeLiveRecorderStatusTypeInit = 1,
    WBNativeLiveRecorderStatusTypeReady,
    WBNativeLiveRecorderStatusTypePrepareConnect,
    WBNativeLiveRecorderStatusTypeConnecting,
    WBNativeLiveRecorderStatusTypeConnected,
    WBNativeLiveRecorderStatusTypeStop,
    WBNativeLiveRecorderStatusTypeError,
};

//录播模式状态
typedef NS_ENUM(NSInteger,WBNativeVideoRecorderStatusType)
{
    WBNativeVideoRecorderStatusTypeInit = 1,
    WBNativeVideoRecorderStatusTypeReady,
    WBNativeVideoRecorderStatusTypePrepareWrite,
    WBNativeVideoRecorderStatusTypeWriting,
    WBNativeVideoRecorderStatusTypeComplete,
    WBNativeVideoRecorderStatusTypeStop,
    WBNativeVideoRecorderStatusTypeError,
};

@class WBNativeRecorder;

@protocol WBNativeRecorderDelegate <NSObject>

//录像器直播模式状态代理
- (void)liveRecord:(WBNativeRecorder *)recorder liveStatus:(WBNativeLiveRecorderStatusType)liveStatusType;

//录像器录像模式状态代理
- (void)videoRecord:(WBNativeRecorder *)recorder videoStatus:(WBNativeVideoRecorderStatusType)videoStatusType;

@end

@interface WBNativeRecorder : NSObject

@property (nonatomic,weak) id<WBNativeRecorderDelegate> delegate;

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
