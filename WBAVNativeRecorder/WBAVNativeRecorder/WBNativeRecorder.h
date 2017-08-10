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

- (instancetype)initWithLivePreViewLayer:(UIView *)preViewLayer recorderType:(WBNativeRecorderType) recorderType;

//开始直播
- (void)startRecord;

//停止直播
- (void)stopRecord;

//反转摄像头
- (void)turnCamera;

//切换手电状态
- (void)turnTorchModeStatus;

//设置滤镜渲染参数
- (void)setVideoImageFilterValueInfoDic:(NSMutableDictionary *)valueDic;




@end
