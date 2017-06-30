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
//预采集界面
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreViewLayer;

//视频采集输出数据处理队列
@property (nonatomic, strong) dispatch_queue_t videoProcessingQueue;
//音频采集输出数据处理队列
@property (nonatomic, strong) dispatch_queue_t audioProcessingQueue;


@end

@implementation WBNativeLiveRecorder


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initVariousData];
        [self checkAVDeviceAuthorization];
        [self initPreViewLayer];
    }
    
    return self;
}

//初始化基本数据
- (void)initVariousData
{
    self.videoProcessingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    self.audioProcessingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}



//检查音视频设备使用权限
- (void)checkAVDeviceAuthorization
{
    AVAuthorizationStatus avDeviceStatusType = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (avDeviceStatusType)
    {
        case AVAuthorizationStatusAuthorized:
            [MBProgressHUD showSuccess:@"已授权"];
            [self initAVCaptureSession];
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted)
                {
                    [MBProgressHUD showSuccess:@"已授权"];
                    [self initAVCaptureSession];
                }
                else
                {
                    [MBProgressHUD showMessage:@"用户拒绝授权摄像头的使用, 返回上一页, 请打开--> 设置 -- > 隐私 --> 通用等权限设置"];
                }
            }];

        }
            break;
        default:
            [MBProgressHUD showError:@"用户尚未授权使用摄像头"];
            break;
    }
    
    
}


//初始化AVCaptureSession
- (void)initAVCaptureSession
{
    self.avSession = [[AVCaptureSession alloc] init];
    //开始配置AVSession
    [self.avSession beginConfiguration];
    //1.设置分辨率
    [self initAVCaptureSession];
    //2.设置合适的摄像头，iOS一共有前后俩个，考虑直播场景优先使用前置摄像头
    [self initVideoDevice];
    //3.初始化视频输入输出
    [self initVideoInputAndOutput];
    //4.设置音频麦克风采集器
    [self initAudioDevice];
    //5.初始化音频输入输出
    [self initAudioInputAndOutput];
    //结束配置AVSession
    [self.avSession commitConfiguration];
}


//初始化分辨率设置，从1280，640, Low三档分辨率中优先选择最高的
- (void)initAVSessionResolution
{
    if (!self.avSession)
    {
        return;
    }
    
    if ([self.avSession canSetSessionPreset:AVCaptureSessionPreset1280x720])
    {
        self.avSession.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    else if ([self.avSession canSetSessionPreset:AVCaptureSessionPreset640x480])
    {
        self.avSession.sessionPreset = AVCaptureSessionPreset640x480;
    }
    else
    {
        self.avSession.sessionPreset = AVCaptureSessionPresetLow;
    }
}

//设置合适的摄像头，iOS一共有前后俩个，考虑直播场景优先使用前置摄像头
- (void)initVideoDevice
{
    if (!self.avSession)
    {
        return;
    }
    
    //设置默认摄像头为前置摄像头
    NSArray *videoDeviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *videoDevice in videoDeviceArray)
    {
        if (videoDevice.position == AVCaptureDevicePositionFront)
        {
            self.videoDevice = videoDevice;
        }
    }
}

//初始化音频采集设备-麦克风
- (void)initAudioDevice
{
    self.audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
}


//初始化视频输入输出
- (void)initVideoInputAndOutput
{
    if (!self.avSession)
    {
        return;
    }
    
    if (!self.videoDevice)
    {
        [MBProgressHUD showError:@"手机摄像设备未取得"];
        return;
    }
    NSError *videoInputError;
    
    
    //处理视频输入
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:&videoInputError];
    if (videoInputError)
    {
        [MBProgressHUD showError:[NSString stringWithFormat:@"手机摄像设备输入错误：%@",videoInputError]];
        return;
    }
    if ([self.avSession canAddInput:_videoInput])
    {
        [self.avSession addInput:_videoInput];
    }
    
    //处理视频输出
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    //是否允许丢帧
    self.videoOutput.alwaysDiscardsLateVideoFrames = YES;
    //是否支持YUV输出
    BOOL isSupportsFullYUVRange = NO;
    //获取输出对象支持的像素格式
    NSArray *supportedPixelFormats = self.videoOutput.availableVideoCVPixelFormatTypes;
    for (NSNumber *currentPixelFormat in supportedPixelFormats)
    {
        if ([currentPixelFormat intValue] == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
        {
            isSupportsFullYUVRange = YES;
        }
    }
    
    //根据是否支持YUV来设置输出对象的视频像素压缩格式
    if ([self supportsFastTextureUpload])
    {
        if (isSupportsFullYUVRange)
        {
             [self.videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        }
        else
        {
            [self.videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        }
    }
    else
    {
            [self.videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    }
    
    //设置视频输出代理
    [self.videoOutput setSampleBufferDelegate:self queue:_videoProcessingQueue];
    //为avSession添加视频输出
    if ([self.avSession canAddOutput:_videoOutput])
    {
        [self.avSession addOutput:_videoOutput];
    }
    //设置视频输出显示方向
    AVCaptureConnection *connetction = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    connetction.videoOrientation = AVCaptureVideoOrientationPortrait;
    //视频稳定设置
    if ([connetction isVideoStabilizationSupported])
    {
        connetction.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    connetction.videoScaleAndCropFactor = connetction.videoMaxScaleAndCropFactor;
    //镜像设置
    connetction.automaticallyAdjustsVideoMirroring = YES;
    
}

//初始化音频输入输出
- (void)initAudioInputAndOutput
{
    if (!self.avSession)
    {
        return;
    }
    
    //音频输入设备
     NSError *audioInputError;
    self.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.audioDevice error:&audioInputError];
    if (audioInputError)
    {
        [MBProgressHUD showError:[NSString stringWithFormat:@"手机音频设备输入错误：%@",audioInputError]];
        return;
    }
    
    //添加音频输入对象
    if ([self.avSession canAddInput:_audioInput])
    {
        [self.avSession addInput:_audioInput];
    }
    //添加音频输出对象
    self.audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    //添加输出对象
    if ([self.avSession canAddOutput:_audioOutput])
    {
        [self.avSession addOutput:_audioOutput];
    }
    
    //设置代理
    [self.audioOutput setSampleBufferDelegate:self queue:_audioProcessingQueue];

}

//初始化preViewlayer并绑定对应的session
- (void)initPreViewLayer
{
    if (!self.avSession)
    {
        return;
    }
}


// 是否支持快速纹理更新
- (BOOL)supportsFastTextureUpload;
{
#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wtautological-pointer-compare"
    return (CVOpenGLESTextureCacheCreate != NULL);
#pragma clang diagnostic pop
    
#endif
}







@end
