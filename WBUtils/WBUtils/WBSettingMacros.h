//
//  WBSettingMacros.h
//  WBUtils
//
//  Created by 王博 on 2017/7/4.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark 通用宏定义

//默认推流路径
#define DEFAULT_PUSH_RTMP_STREAM @"rtmp://push.ksyun.kuwo.cn/voicelive/251495263?opstr=publish&tm=1502761235&uid=251495263&roomid=251495263&Md5=a9a5c56f2859ff16f1e72d8f72c4ec8e"
//默认拉流路径
#define DEFAULT_GET_RTMP_STREAM @""
//默认视频存储文件夹 (默认存入APPDocument路径下)
#define DEFAULT_VIDEO_STORE_FOLDER @"videoFolder"
//默认视频播放路径
#define DEFAULT_VIDEO_PLAY_FOLDER @""

//计时器刷新频率
#define RECORD_TIMER_INTERVAL 0.05
//单次录像最大时长
#define RECORD_MAX_TIME 10

//视频保存相册名称
#define VIDEO_FOLDER_NAME @"WBRecord视频相册"


#pragma mark 原生录像器宏定义

//启用人脸检测
#define FACE_DETECTOR_ENABLE

//启用GPUImage美颜
#define GPUIMAGE_BEAUTY_ENABLE

//启用点击对焦自动调整对焦点白平衡功能
#define FOCUS_EXPOSURE_AUTO_ADJUST_ENABLE

//启用CIImage美颜
//#define CIIMAGE_BEAUTY_ENABLE

//是否开启原生采集CIIMAGE美颜功能
#ifdef CIIMAGE_BEAUTY_ENABLE
    //启用美颜
    #define IMAGE_FILTER_ENABLE
    //启用CIImage美颜
    #define CIIMAGE_FILTER
#endif

//是否开启GPUIMAGE美颜功能
#ifdef GPUIMAGE_BEAUTY_ENABLE
    //启用美颜
    #define IMAGE_FILTER_ENABLE
    //启用GPUImage美颜
    #define GPUIMAGE_FILTER
#endif


//是否开启人脸检测功能
#ifdef FACE_DETECTOR_ENABLE
    //启用美颜
    #define IMAGE_FILTER_ENABLE
    //启用人脸检测
    #define FACE_DETECTOR
#endif

#pragma mark GPUImage录像器宏定义







