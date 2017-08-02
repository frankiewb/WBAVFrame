//
//  WBNativeLiveRecorder.h
//  WBAVNativeRecorder
//
//  Created by 王博 on 2017/6/28.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface WBNativeLiveRecorder : NSObject

- (instancetype)initWithLivePreViewLayer:(UIView *)preViewLayer;

//开始直播
- (void)startLiveRecord;

//停止直播
- (void)stopLiveRecord;

//反转摄像头
- (void)turnCamera;

//切换手电状态
- (void)turnTorchModeStatus;

//设置滤镜渲染参数
- (void)setVideoImageFilterValueInfoDic:(NSMutableDictionary *)valueDic;


@end
