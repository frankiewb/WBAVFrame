//
//  WBSettingMacros.h
//  WBUtils
//
//  Created by 王博 on 2017/7/4.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>

//默认推流路径
#define DEFAULT_PUSH_RTMP_STREAM @"rtmp://push.ksyun.kuwo.cn/voicelive/251495263?opstr=publish&tm=1502362911&uid=251495263&roomid=251495263&Md5=154d5930ab36a73b0b30e835e034a822"
//默认拉流路径
#define DEFAULT_GET_RTMP_STREAM @""
//默认视频存储路径
#define DEFAULT_VIDEO_STORE_PATH @""
//默认视频播放路径
#define DEFAULT_VIDEO_PLAY_PATH @""



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







