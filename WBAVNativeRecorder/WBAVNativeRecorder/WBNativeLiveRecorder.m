//
//  WBNativeLiveRecorder.m
//  WBAVNativeRecorder
//
//  Created by 王博 on 2017/6/28.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBNativeLiveRecorder.h"
#import <AVFoundation/AVFoundation.h>




@interface WBNativeLiveRecorder () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>


//音视频输入输出设备及数据管理器
@property (nonatomic, strong) AVCaptureSession *avSession;
//视频管理器：前后摄像头，闪光灯，聚焦，摄像头切换
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
//音频管理器
@property (nonatomic, strong) AVCaptureDevice *audioDevice;
//视频输入管理器
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
//音频输入管理器
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
//视频输出管理器
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
//音频输出管理器
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;


@end

@implementation WBNativeLiveRecorder


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    
    return self;
}



//检查音视频设备使用权限
- (void)checkAVDeviceAuthorization
{
    AVAuthorizationStatus avDeviceStatusType = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (avDeviceStatusType)
    {
        case AVAuthorizationStatusAuthorized:
            
            break;
        case AVAuthorizationStatusNotDetermined:
            
        default:
        {
            
        }
            break;
    }
    
    
}






@end
