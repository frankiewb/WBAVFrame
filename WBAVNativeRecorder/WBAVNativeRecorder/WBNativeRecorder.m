//
//  WBNativeRecorder.m
//  WBAVNAtiveRecorder
//
//  Created by 王博 on 2017/8/10.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBNativeRecorder.h"
#import "WBNativeVideoWriter.h"

@interface WBNativeRecorder () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate,
WBAACEncoderDelegate,
WBH264EncoderDelegate,
WBRtmpHandlerDelegate,
WBNativeVideoWtiterDelegate>


#pragma mark 通用属性
//播放器类型:直播 or 本地录像
@property (nonatomic, assign) WBNativeRecorderType recorderType;
//直播状态
@property (nonatomic, assign) WBNativeLiveRecorderStatusType liveRecordStatus;
//录像状态
@property (nonatomic, assign) WBNativeVideoRecorderStatusType videoRecordStatus;
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
//视频采集输出数据处理队列
@property (nonatomic, strong) dispatch_queue_t videoProcessingQueue;
//音频采集输出数据处理队列
@property (nonatomic, strong) dispatch_queue_t audioProcessingQueue;
//预渲染界面
@property (nonatomic, weak) UIView *livePreViewLayer;
//预采集界面
#ifdef IMAGE_FILTER_ENABLE
@property (nonatomic, strong) WBNativeRecorderBeautyPreView *videoPreViewLayer;
@property (nonatomic, strong) NSMutableDictionary *videoImageFilterValueDic;//视频图像滤镜参数
#else
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreViewLayer;
#endif


#pragma mark 直播模式属性
//视频编码器
@property (nonatomic, strong) WBH264Encoder *videoEncoder;
//音频编码器
@property (nonatomic, strong) WBAACEncoder *audioEncoder;
//RTMP连接器
@property (nonatomic, strong) WBRtmpHandler *rtmpHandler;
//时间戳
@property (nonatomic, assign) uint64_t timeStamp;
//是否是第一帧
@property (nonatomic, assign) BOOL isFirstFrame;
//是否RTMP连接
@property (nonatomic, assign) BOOL isConnecting;
//是否开始直播
@property (nonatomic, assign) BOOL isStartingLive;
#pragma mark 录像模式属性
@property (nonatomic, strong) WBNativeVideoWriter *recordWriter;

@end


@implementation WBNativeRecorder

#pragma mark 构造相关函数
- (instancetype)initWithLivePreViewLayer:(UIView *)preViewLayer recorderType:(WBNativeRecorderType)recorderType
{
    self = [super init];
    if (self)
    {
        self.recorderType = recorderType;
        self.livePreViewLayer = preViewLayer;
        [self initVariousData];
        [self checkAVDeviceAuthorization];
    }
    
    return self;
}

- (void)destroy
{
    //[self stopRecord];
    [self.videoOutput setSampleBufferDelegate:nil queue:dispatch_get_main_queue()];
    [self.videoOutput setSampleBufferDelegate:nil queue:dispatch_get_main_queue()];
}


- (void)dealloc
{
    [self destroy];
    LOG_METHOD;
}

#pragma mark 代理函数处理

- (void)updateLiveRecordStatus:(WBNativeLiveRecorderStatusType)liveStatus
{
    self.liveRecordStatus = liveStatus;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(liveRecord:liveStatus:)])
    {
        [self.delegate liveRecord:self liveStatus:liveStatus];
    }
}

- (void)updateVideoRecordStatus:(WBNativeVideoRecorderStatusType)videoStatus
{
    self.videoRecordStatus = videoStatus;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoRecord:videoStatus:)])
    {
        [self.delegate videoRecord:self videoStatus:videoStatus];
    }
}

#pragma mark 初始化相关函数

- (void)initVariousData
{
    [self initNormalVariousData];
    [self initLiveVariousData];
    [self initRecordVariousData];
}


//初始化通用基本数据
- (void)initNormalVariousData
{
    self.videoProcessingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    self.audioProcessingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

//初始化直播相关实例
- (void)initLiveVariousData
{
    self.videoEncoder = [[WBH264Encoder alloc] init];
    self.videoEncoder.delegate = self;
    self.audioEncoder = [[WBAACEncoder alloc] init];
    self.audioEncoder.delegate = self;
    self.isStartingLive = NO;
    self.isConnecting = NO;
    self.isFirstFrame = NO;
    self.timeStamp = 0;
}

//初始化录播相关实例
- (void)initRecordVariousData
{
    //关于录制视频格式这里没有暴露接口，具体上层业务逻辑定夺吧，这里默认为4X3
    self.recordWriter = [[WBNativeVideoWriter alloc] initWithVideoStoreURL:[self getRecordVideoFilePath] VideoAspectRationType:WBNativeVideoAspectRatioType4X3];
    self.recordWriter.delegate = self;
}


//检查音视频设备使用权限
- (void)checkAVDeviceAuthorization
{
    AVAuthorizationStatus avDeviceStatusType = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (avDeviceStatusType)
    {
        case AVAuthorizationStatusAuthorized:
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
    [self initAVSessionResolution];
    //2.设置合适的摄像头，iOS一共有前后俩个，考虑直播场景优先使用前置摄像头
    [self initVideoDevice];
    //3.初始化视频输入输出
    [self initVideoInputAndOutput];
    //4.设置音频麦克风采集器
    [self initAudioDevice];
    //5.初始化音频输入输出
    [self initAudioInputAndOutput];
    //6.结束配置AVSession
    [self.avSession commitConfiguration];
    //7.初始化预览界面
    [self initPreViewLayer];
    //8.开启预览图
    if (![self.avSession isRunning])
    {
        [self.avSession startRunning];
    }
    //9.更新状态
    [self updateLiveRecordStatus:WBNativeLiveRecorderStatusTypeInit];
    [self updateVideoRecordStatus:WBNativeVideoRecorderStatusTypeInit];
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
        //self.avSession.sessionPreset = AVCaptureSessionPreset640x480;
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
            
            [self changeCaptureDeviceWithType:AVMediaTypeVideo CaptureProperty:^(AVCaptureDevice *captureDevice)
            {
                //开启视频HDR (高动态范围图像)
                captureDevice.automaticallyAdjustsVideoHDREnabled = YES;
                //设置最大,最小帧率
                captureDevice.activeVideoMinFrameDuration = CMTimeMake(1, 30);
            }];
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
#ifndef GPUIMAGE_FILTER  //如果不是采用GPUImage美颜则可以采用YUV格式进行采集
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
#endif //如果采用GPUImage美颜则必须采用RBG格式进行采集
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
    
    [self initAVCaputureConnetctionWithVideoOutput:_videoOutput];
    
}


- (void)initAVCaputureConnetctionWithVideoOutput:(AVCaptureVideoDataOutput *)outPut
{
    //设置视频输出显示方向
    AVCaptureConnection *connetction = [outPut connectionWithMediaType:AVMediaTypeVideo];
    connetction.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    //控制镜像采集与否
    connetction.videoMirrored = YES;
    
    //视频稳定设置
    if ([connetction isVideoStabilizationSupported])
    {
        connetction.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    connetction.videoScaleAndCropFactor = connetction.videoMaxScaleAndCropFactor;
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

//初始化preViewlayer
- (void)initPreViewLayer
{
    if (!self.avSession)
    {
        return;
    }
#ifdef IMAGE_FILTER_ENABLE
    if (!self.videoPreViewLayer)
    {
        self.videoPreViewLayer = [[WBNativeRecorderBeautyPreView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    [self.livePreViewLayer addSubview:_videoPreViewLayer];
#else
    if (!self.videoPreViewLayer)
    {
        [self.livePreViewLayer layoutIfNeeded];
        //初始化对象
        self.videoPreViewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_avSession];
        self.videoPreViewLayer.connection.videoOrientation = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation;
        self.videoPreViewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.videoPreViewLayer.frame = self.livePreViewLayer.layer.frame;
        self.videoPreViewLayer.position = CGPointMake(self.livePreViewLayer.frame.size.width *0.5, self.livePreViewLayer.frame.size.height*0.5);
    }
    [self.livePreViewLayer.layer addSublayer:_videoPreViewLayer];
#endif
    
    
}



#pragma mark 录像器操作相关函数

- (void)startRecord
{
    //开启预览图
    if (![self.avSession isRunning])
    {
        [self.avSession startRunning];
    }
    
    if (self.recorderType == WBNativeRecorderTypeLive)
    {
        if (!self.isStartingLive)
        {
            self.isStartingLive = YES;
        }
        //开始推流
        [self startRTMPSocketHandler];
    }
    else if (self.recorderType == WBNativeRecorderTypeVideo)
    {
        [self.recordWriter startWriter];
    }
}

- (void)stopRecord
{
    //关闭预览图
    if ([self.avSession isRunning])
    {
        [self.avSession stopRunning];
    }
    
    if (self.recorderType == WBNativeRecorderTypeLive)
    {
        if (self.isStartingLive)
        {
            self.isStartingLive = NO;
        }
        //停止推流
        [self destroyRTMPSocketHandler];
    }
    else if (self.recorderType == WBNativeRecorderTypeVideo)
    {
        [self.recordWriter stopWriter];
    }
}

- (void)turnCamera
{
    //1.找寻待切换摄像头
    AVCaptureDevicePosition nowPosition = self.videoDevice.position;
    AVCaptureDevicePosition targetPosition;
    (nowPosition == AVCaptureDevicePositionFront) ? (targetPosition = AVCaptureDevicePositionBack) : (targetPosition = AVCaptureDevicePositionFront);
    self.videoDevice = [self getCameraDeviceWithPosition:targetPosition];
    
    
    //2.设置待切换摄像头属性
    [self changeCaptureDeviceWithType:AVMediaTypeVideo CaptureProperty:^(AVCaptureDevice *captureDevice)
     {
         //开启视频HDR (高动态范围图像)
         captureDevice.automaticallyAdjustsVideoHDREnabled = YES;
         //设置最大,最小帧率
         captureDevice.activeVideoMinFrameDuration = CMTimeMake(1, 30);
     }];
    NSError *videoInputError;
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:&videoInputError];
    if (videoInputError)
    {
        [MBProgressHUD showError:[NSString stringWithFormat:@"手机摄像设备输入错误：%@",videoInputError]];
        return;
    }
    
    //3. 将待切换摄像头加入AVCaptureSession，并更新AVCaputureConnetction
    [self.avSession beginConfiguration];
    [self.avSession removeInput:_videoInput];
    if ([self.avSession canAddInput:newVideoInput])
    {
        [self.avSession addInput:newVideoInput];
    }
    self.videoInput = newVideoInput;
    [self initAVCaputureConnetctionWithVideoOutput:_videoOutput];
    [self.avSession commitConfiguration];
}

-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position
{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras)
    {
        if ([camera position] == position)
        {
            return camera;
        }
    }
    return nil;
}

- (void)turnTorchModeStatus
{
    if ([self.videoDevice hasTorch])
    {
       [self changeCaptureDeviceWithType:AVMediaTypeVideo CaptureProperty:^(AVCaptureDevice *captureDevice)
        {
            if (captureDevice.torchMode == AVCaptureTorchModeOff)
            {
                captureDevice.torchMode = AVCaptureTorchModeOn;
            }
            else if (captureDevice.torchMode == AVCaptureTorchModeOn)
            {
                captureDevice.torchMode = AVCaptureTorchModeOff;
            }
       }];
    }
    else
    {
        [MBProgressHUD showError:@"前置摄像头不支持手电" toView:_videoPreViewLayer];
    }
}

//设置当前采集设备聚焦点及对应聚焦点的聚焦模式及曝光模式
- (void)setFocusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atScreenPoint:(CGPoint)point
{
#warning WB_WARNING 遗留问题，自定义采集预览页面如何正确转换坐标？？
    //此处传来的坐标是屏幕坐标需要调整为合适的摄像头采集坐标
    // point 需要转换为正确的CGPoint
    
    
    [self changeCaptureDeviceWithType:AVMediaTypeVideo CaptureProperty:^(AVCaptureDevice *captureDevice)
    {
        if ([captureDevice isFocusModeSupported:focusMode])
        {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported])
        {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode])
        {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported])
        {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

//更新音频或视频采集设备属性
- (void)changeCaptureDeviceWithType:(NSString *)mediaType CaptureProperty:(void(^)(AVCaptureDevice *captureDevice))propertyChange
{
    AVCaptureDevice *captureDevice = nil;
    
    if (mediaType == AVMediaTypeVideo)
    {
        captureDevice = self.videoDevice;
    }
    else if (mediaType == AVMediaTypeAudio)
    {
        captureDevice = self.audioDevice;
    }
    
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if (captureDevice)
    {
        if ([captureDevice lockForConfiguration:&error])
        {
            propertyChange(captureDevice);
            [captureDevice unlockForConfiguration];
        }
        else
        {
            NSLog(@"WBRecord: 设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
        }
    }
    else
    {
        NSLog(@"WBRecord: captureDeviceType 错误，无法找到对应的采集设备");
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



#pragma mark 音视频采集后输出处理代理

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    //视频buffer帧处理
    if (captureOutput == _videoOutput)
    {
#ifdef IMAGE_FILTER_ENABLE
        //视频前处理滤镜渲染
        [self processCIFilterWithSampleBuffer:sampleBuffer];
#endif
    
        if (self.recorderType == WBNativeRecorderTypeLive)
        {
            //视频硬编码
            [self.videoEncoder encodeWithSampleBuffer:sampleBuffer timeStamp:[self getCurrentTimeStamp]];
        }
        else if (self.recorderType == WBNativeRecorderTypeVideo)
        {
            [self.recordWriter writeWithSampleBuffer:sampleBuffer MediaType:AVMediaTypeVideo];
        }
    }
    else //音频buffer帧处理
    {
        if (self.recorderType == WBNativeRecorderTypeLive)
        {
            //音频硬编码
            [self.audioEncoder encodeWithSampleBuffer:sampleBuffer timeStamp:[self getCurrentTimeStamp]];
        }
        else if (self.recorderType == WBNativeRecorderTypeVideo)
        {
            [self.recordWriter writeWithSampleBuffer:sampleBuffer MediaType:AVMediaTypeAudio];
        }
    }
}

#pragma mark 视频前处理: 滤镜 + 人脸识别 + 贴纸
#ifdef IMAGE_FILTER_ENABLE
- (void)setVideoImageFilterValueInfoDic:(NSMutableDictionary *)valueDic
{
    self.videoImageFilterValueDic = valueDic;
    
#ifdef CIIMAGE_FILTER
    //设置相关渲染参数
    //shadowValue 阴影 : [-1 1]0~1之间较亮
    //gammaValue 灰度 : [0.25 4] 1~0.25之间较亮 默认 0.75
    //exposureValue 曝光 [-10 10] 默认 0.5
    //saturation 饱和 [0,2] 默认为1
    //contrastValue 对比度 [0,2] 默认为1
    //brightnessValue 亮度 [-1,1] 默认为0
    //gaussianBlurValue 高斯模糊 默认为10 [0,20]
#else
    //美颜滤镜 beautifyFilterEnable
    //锐化滤镜 sharpenFilterEnbale
    //素描滤镜 sketchFilterEnable
    //像素化滤镜 pixellateFilterEnbale
    
#endif
    
}

- (void)processCIFilterWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if (!self.videoImageFilterValueDic)
    {
        self.videoImageFilterValueDic = [[NSMutableDictionary alloc] init];
    }
    
    CIImage *renderedImage = nil;
#ifdef CIIMAGE_FILTER
    renderedImage = [WBNativeRecorderBeautyFilter getNativeBeautyFilterImageWithSmapleBuffer:sampleBuffer valueDic:_videoImageFilterValueDic];
#endif
#ifdef GPUIMAGE_FILTER
    renderedImage = [WBNativeRecorderGPUImageFilter getNativeGPUImageFilterWithSmapleBuffer:sampleBuffer valueDic:_videoImageFilterValueDic];
#endif
#ifdef FACE_DETECTOR
    renderedImage = [WBNativeRecorderFaceDetector getNativeFaceDetectorRenderImageWithSmapleBuffer:sampleBuffer valueDic:nil];
#endif
    [self.videoPreViewLayer displayPreViewWithUpdatedImage:renderedImage];
}
#endif

#pragma mark 直播模式相关函数
//WBH264Encoder代理
- (void)wbH264EncoderDidFinishEncodeWithWBVideoFrame:(WBVideoFrame *)videoFrame
{
    
    if(self.isStartingLive)
    {
        //视频编码处理后准备推流
        //NSLog(@"视频编码上传");
        if (self.isConnecting)
        {   //相关RTMP_SOCKET推流准备工作
            [self.rtmpHandler sendWBFrame:videoFrame];
        }
    }
}

//WBAACEncoder代理
- (void)wbAACEncoderDidFinishEncodeWithWBAudioFrame:(WBAudioFrame *)audioFrame
{
    if(self.isStartingLive)
    {
        //音频编码处理后准备推流
        //NSLog(@"音频编码上传");
        //相关RTMP_SOCKET推流准备工作
        [self.rtmpHandler sendWBFrame:audioFrame];
    }
}

//RTMPHandler代理
- (void)socketStatus:(WBRtmpHandler *)rtmpHandler status:(WBLiveStateType)status
{
    switch (status)
    {
        case WBLiveStateTypeReady:
            NSLog(@"RecordLive: RTMP准备");
            [self updateLiveRecordStatus:WBNativeLiveRecorderStatusTypeReady];
            break;
        case WBLiveStateTypeConnecting:
            NSLog(@"RecordLive: RTMP连接中");
            [self updateLiveRecordStatus:WBNativeLiveRecorderStatusTypeConnecting];
            break;
        case WBLiveStateTypeConnected:
        {
            NSLog(@"RecordLive: RTMP已连接");
            [self updateLiveRecordStatus:WBNativeLiveRecorderStatusTypeConnected];
            if (!self.isConnecting)
            {
                self.isFirstFrame = YES;
                self.timeStamp = 0;
                self.isConnecting = YES;
            }
            
        }
            break;
        case WBLiveStateTypeStop:
            [self updateLiveRecordStatus:WBNativeLiveRecorderStatusTypeStop];
            NSLog(@"RecordLive: RTMP已断开");
            break;
        case WBLiveStateTypeError:
        {
            [self updateLiveRecordStatus:WBNativeLiveRecorderStatusTypeError];
            NSLog(@"RecordLive: RTMP连接错误");
            self.isConnecting = NO;
            self.isFirstFrame = NO;
        }
            break;
    }
}

//开始推流
- (void)startRTMPSocketHandler
{
    [self destroyRTMPSocketHandler];
    if (!self.rtmpHandler)
    {
        self.rtmpHandler = [[WBRtmpHandler alloc] initWithPushStreamURL:DEFAULT_PUSH_RTMP_STREAM];
        self.rtmpHandler.delegate = self;
        [self.rtmpHandler start];
    }
}

//销毁推流实例
- (void)destroyRTMPSocketHandler
{
    if (self.rtmpHandler)
    {
        [self.rtmpHandler stop];
        self.rtmpHandler = nil;
    }
}

- (uint64_t)getCurrentTimeStamp
{
    @synchronized (self)
    {
        uint64_t currentTimeStamp = 0;
        if (self.isFirstFrame)
        {
            self.timeStamp = NOW;
            self.isFirstFrame = NO;
        }
        else
        {
            currentTimeStamp = NOW - _timeStamp;
        }        
        return currentTimeStamp;
    }
}

#pragma mark 录像模式相关函数

//recordWriter 状态代理
- (void)videoWriterStatus:(WBNativeVideoWriter *)videoWriter status:(WBNativeVideoWriterType)status
{
    switch (status)
    {
        case WBNativeVideoWriterTypeReady:
            [self updateVideoRecordStatus:WBNativeVideoRecorderStatusTypeReady];
            NSLog(@"RecordWriter: 准备写入本地");
            break;
        case WBNativeVideoWriterTypeWriting:
            [self updateVideoRecordStatus:WBNativeVideoRecorderStatusTypeWriting];
            NSLog(@"RecordWriter: 正在写入本地");
            break;
        case WBNativeVideoWriterTypeStop:
            [self updateVideoRecordStatus:WBNativeVideoRecorderStatusTypeStop];
            NSLog(@"RecordWriter: 停止写入本地");
            break;
        case WBNativeVideoWriterTypeComplete:
            [self updateVideoRecordStatus:WBNativeVideoRecorderStatusTypeComplete];
            NSLog(@"RecordWriter: 完成写入本地");
            break;
        case WBNativeVideoWriterTypeError:
            [self updateVideoRecordStatus:WBNativeVideoRecorderStatusTypeError];
            NSLog(@"RecordWriter: 写入本地错误");
            break;
        case WBNativeVideoWriterTypeNone:
            NSLog(@"RecordWriter: 如果你看到这个状态就见鬼了");
            break;
    }
}

- (NSString *)getRecordVideoFilePath
{
    //获取文件名
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmm"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    NSString *videoName = [NSString stringWithFormat:@"WBRecord%@.mp4",dateStr];

    
    //获取文件夹路径,直接存入Documents中，录像完成后需要删除
    NSString *fileDir = [WBFileManager cachesDir];
    NSString *fullRecordFolderDir = [fileDir stringByAppendingPathComponent:DEFAULT_VIDEO_STORE_FOLDER];

    if (![WBFileManager isExistsAtPath:fullRecordFolderDir])
    {
        [WBFileManager createDirectoryAtPath:fullRecordFolderDir];
    }
    
    //全文件路径 + 文件名 = 全路径
    NSString *fullRecordStoreDir = [fullRecordFolderDir stringByAppendingPathComponent:videoName];

    return fullRecordStoreDir;
}

@end
