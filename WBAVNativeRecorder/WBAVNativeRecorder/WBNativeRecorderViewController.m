//
//  WBNativeRecorderViewController.m
//  WBAVNAtiveRecorder
//
//  Created by 王博 on 2017/8/10.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBNativeRecorderViewController.h"


@interface WBNativeRecorderViewController ()

@property (nonatomic, assign) WBNativeRecorderType recorderType;//播放器类型

@property (nonatomic, strong) WBNativeRecorder *nativeRecorder;//播放器

@property (nonatomic, strong) UIButton *backButton;//返回按钮

@property (nonatomic, strong) UIButton *turnCameraButton;//切换摄像头按钮

@property (nonatomic, strong) UIButton *torchButton;//开启关闭闪光灯按钮

@property (nonatomic, strong) UIButton *startButton;//开始录制

@property (nonatomic, strong) UIImageView *onLiveImageView;//直播中图标

@property (nonatomic, strong) NSMutableDictionary *videoImageFilterValueDic;//滤镜参数设置集合数组

#ifdef CIIMAGE_FILTER
//美颜相关控件
@property (nonatomic, strong) UILabel *saturationLabel;//饱和度
@property (nonatomic, strong) UILabel *brightnessLabel;//亮度
@property (nonatomic, strong) UILabel *contrastLabel;//对比度
@property (nonatomic, strong) UILabel *gaussianBlurLabel;//高斯模糊

@property (nonatomic, strong) UISlider *saturationSlider;
@property (nonatomic, strong) UISlider *brightnessSlider;
@property (nonatomic, strong) UISlider *contrastSlider;
@property (nonatomic, strong) UISlider *gaussianBlurSlider;
#endif

#ifdef GPUIMAGE_FILTER
@property (nonatomic, strong) UILabel *beautifyLabel;//美颜
@property (nonatomic, strong) UILabel *toonLabel;//卡通
@property (nonatomic, strong) UILabel *sketchLabel;//素描
@property (nonatomic, strong) UILabel *pixellateLabel;//像素化

@property (nonatomic, strong) UISwitch *beautifySwitch;
@property (nonatomic, strong) UISwitch *toonSwitch;
@property (nonatomic, strong) UISwitch *sketchSWitch;
@property (nonatomic, strong) UISwitch *pixellateSwitch;

#endif

@end

@implementation WBNativeRecorderViewController


- (instancetype)initWithRecorderType:(WBNativeRecorderType)type
{
    self = [super init];
    if (self)
    {
        self.recorderType = type;
    }
    
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setFilterVarious];
    [self setLiveRecorder];
    [self setSubview];
}

- (void)setFilterVarious
{
    self.videoImageFilterValueDic = [[NSMutableDictionary alloc] init];
#ifdef CIIMAGE_FILTER
    [self.videoImageFilterValueDic setObject:@(1) forKey:@"saturationValue"];
    [self.videoImageFilterValueDic setObject:@(0) forKey:@"brightnessValue"];
    [self.videoImageFilterValueDic setObject:@(1) forKey:@"contrastValue"];
    [self.videoImageFilterValueDic setObject:@(0) forKey:@"gaussianBlurValue"];
#endif
#ifdef GPUIMAGE_FILTER
    [self.videoImageFilterValueDic setObject:@(0) forKey:@"beautifyFilterEnable"];
    [self.videoImageFilterValueDic setObject:@(0) forKey:@"toonFilterEnbale"];
    [self.videoImageFilterValueDic setObject:@(0) forKey:@"sketchFilterEnable"];
    [self.videoImageFilterValueDic setObject:@(0) forKey:@"pixellateFilterEnbale"];
#endif
    
    
}

- (void)setLiveRecorder
{
    self.nativeRecorder = [[WBNativeRecorder alloc] initWithLivePreViewLayer:self.view recorderType:_recorderType];
#ifdef IMAGE_FILTER_ENABLE
    [self.nativeRecorder setVideoImageFilterValueInfoDic:_videoImageFilterValueDic];
#endif
}


- (void)setSubview
{
    //backButton
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"backLive"] forState:UIControlStateNormal];
    self.backButton.frame = CGRectMake(15*WBDeviceScale6, 10*WBDeviceScale6, 30*WBDeviceScale6, 30*WBDeviceScale6);
    [self.backButton addTarget:self action:@selector(backToParent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    
    //turnCameraButton
    self.turnCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.turnCameraButton setBackgroundImage:[UIImage imageNamed:@"turnCamera"] forState:UIControlStateNormal];
    self.turnCameraButton.frame = CGRectMake(WBScreenWidth - 45*WBDeviceScale6, 10*WBDeviceScale6, 30*WBDeviceScale6, 30*WBDeviceScale6);
    [self.turnCameraButton addTarget:self action:@selector(turnCameraHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_turnCameraButton];
    
    //torchButton
    self.torchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.torchButton setBackgroundImage:[UIImage imageNamed:@"torch"] forState:UIControlStateNormal];
    self.torchButton.frame = CGRectMake(WBScreenWidth/2 - 15*WBDeviceScale6, 10*WBDeviceScale6, 30*WBDeviceScale6, 30*WBDeviceScale6);
    [self.torchButton addTarget:self action:@selector(turnTorchModeStatus) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_torchButton];
    
    //startLiveButton
    self.startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startButton setBackgroundImage:[UIImage imageNamed:@"beginRecord"] forState:UIControlStateNormal];
    self.startButton.frame = CGRectMake(WBScreenWidth/2 - 30*WBDeviceScale6, WBScreenHeight - 90*WBDeviceScale6, 60*WBDeviceScale6, 60*WBDeviceScale6);
    [self.startButton addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startButton];
    
    //onLiveImageView
    self.onLiveImageView = [[UIImageView alloc] init];
    if (self.recorderType == WBNativeRecorderTypeLive)
    {
        [self.onLiveImageView setImage:[UIImage imageNamed:@"onLive"]];
    }
    else if (self.recorderType == WBNativeRecorderTypeVideo)
    {
        [self.onLiveImageView setImage:[UIImage imageNamed:@"onRecord"]];
    }
    
    self.onLiveImageView.frame = CGRectMake(15*WBDeviceScale6, 80*WBDeviceScale6, 60*WBDeviceScale6, 30*WBDeviceScale6);
    self.onLiveImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_onLiveImageView];
    self.onLiveImageView.hidden = YES;
    
    
    
#ifdef CIIMAGE_FILTER
    //饱和度设置 滑动条
    self.saturationLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*WBDeviceScale6, 60*WBDeviceScale6, 60*WBDeviceScale6, 30*WBDeviceScale6)];
    self.saturationLabel.text = @"饱和度";
    self.saturationLabel.font = [UIFont systemFontOfSize:18*WBDeviceScale6];
    [self.view addSubview:_saturationLabel];
    self.saturationSlider = [[UISlider alloc] initWithFrame:CGRectMake(85*WBDeviceScale6, 60*WBDeviceScale6, 230*WBDeviceScale6, 30*WBDeviceScale6)];
    self.saturationSlider.minimumValue = 0;
    self.saturationSlider.maximumValue = 2;
    self.saturationSlider.value = 1;
    [self.saturationSlider addTarget:self action:@selector(changeSaturation:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_saturationSlider];
    
    //明亮度设置 滑动条
    self.brightnessLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*WBDeviceScale6, 110*WBDeviceScale6, 60*WBDeviceScale6, 30*WBDeviceScale6)];
    self.brightnessLabel.text = @"明亮度";
    self.brightnessLabel.font = [UIFont systemFontOfSize:18*WBDeviceScale6];
    [self.view addSubview:_brightnessLabel];
    self.brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(85*WBDeviceScale6, 110*WBDeviceScale6, 230*WBDeviceScale6, 30*WBDeviceScale6)];
    self.brightnessSlider.minimumValue = -1;
    self.brightnessSlider.maximumValue = 1;
    self.brightnessSlider.value = 0;
    [self.brightnessSlider addTarget:self action:@selector(changeBrightness:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_brightnessSlider];
    
    //对比度设置 滑动条
    self.contrastLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*WBDeviceScale6, 160*WBDeviceScale6, 60*WBDeviceScale6, 30*WBDeviceScale6)];
    self.contrastLabel.text = @"对比度";
    self.contrastLabel.font = [UIFont systemFontOfSize:18*WBDeviceScale6];
    [self.view addSubview:_contrastLabel];
    self.contrastSlider = [[UISlider alloc] initWithFrame:CGRectMake(85*WBDeviceScale6, 160*WBDeviceScale6, 230*WBDeviceScale6, 30*WBDeviceScale6)];
    self.contrastSlider.minimumValue = 0;
    self.contrastSlider.maximumValue = 2;
    self.contrastSlider.value = 1;
    [self.contrastSlider addTarget:self action:@selector(changeContrast:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_contrastSlider];
    
    //高斯模糊设置 滑动条
    self.gaussianBlurLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*WBDeviceScale6, 210*WBDeviceScale6, 60*WBDeviceScale6, 30*WBDeviceScale6)];
    self.gaussianBlurLabel.text = @"模糊度";
    self.gaussianBlurLabel.font = [UIFont systemFontOfSize:18*WBDeviceScale6];
    [self.view addSubview:_gaussianBlurLabel];
    self.gaussianBlurSlider = [[UISlider alloc] initWithFrame:CGRectMake(85*WBDeviceScale6, 210*WBDeviceScale6, 230*WBDeviceScale6, 30*WBDeviceScale6)];
    self.gaussianBlurSlider.minimumValue = 0;
    self.gaussianBlurSlider.maximumValue = 3;
    self.gaussianBlurSlider.value = 0;
    [self.gaussianBlurSlider addTarget:self action:@selector(changeGaussianBlur:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_gaussianBlurSlider];
#endif
    
    
    
#ifdef GPUIMAGE_FILTER
    
    //美颜设置 开关
    self.beautifyLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*WBDeviceScale6, 60*WBDeviceScale6, 60*WBDeviceScale6, 30*WBDeviceScale6)];
    self.beautifyLabel.text = @"美颜";
    self.beautifyLabel.font = [UIFont systemFontOfSize:18*WBDeviceScale6];
    [self.view addSubview:_beautifyLabel];
    self.beautifySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(85*WBDeviceScale6, 60*WBDeviceScale6, 50*WBDeviceScale6, 30*WBDeviceScale6)];
    self.beautifySwitch.on = NO;
    [self.beautifySwitch addTarget:self action:@selector(beautySwitchAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_beautifySwitch];
    
    //锐化设置 开关
    self.toonLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*WBDeviceScale6, 110*WBDeviceScale6, 60*WBDeviceScale6, 30*WBDeviceScale6)];
    self.toonLabel.text = @"卡通";
    self.toonLabel.font = [UIFont systemFontOfSize:18*WBDeviceScale6];
    [self.view addSubview:_toonLabel];
    self.toonSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(85*WBDeviceScale6, 110*WBDeviceScale6, 50*WBDeviceScale6, 30*WBDeviceScale6)];
    self.toonSwitch.on = NO;
    [self.toonSwitch addTarget:self action:@selector(toonSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_toonSwitch];
    
    //素描设置 开关
    self.sketchLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*WBDeviceScale6, 160*WBDeviceScale6, 60*WBDeviceScale6, 30*WBDeviceScale6)];
    self.sketchLabel.text = @"素描";
    self.sketchLabel.font = [UIFont systemFontOfSize:18*WBDeviceScale6];
    [self.view addSubview:_sketchLabel];
    self.sketchSWitch = [[UISwitch alloc] initWithFrame:CGRectMake(85*WBDeviceScale6, 160*WBDeviceScale6, 50*WBDeviceScale6, 30*WBDeviceScale6)];
    self.sketchSWitch.on = NO;
    [self.sketchSWitch addTarget:self action:@selector(sketchSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_sketchSWitch];
    
    //像素化 开关
    self.pixellateLabel = [[UILabel alloc] initWithFrame:CGRectMake(15*WBDeviceScale6, 210*WBDeviceScale6, 60*WBDeviceScale6, 30*WBDeviceScale6)];
    self.pixellateLabel.text = @"像素";
    self.pixellateLabel.font = [UIFont systemFontOfSize:18*WBDeviceScale6];
    [self.view addSubview:_pixellateLabel];
    self.pixellateSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(85*WBDeviceScale6, 210*WBDeviceScale6, 50*WBDeviceScale6, 30*WBDeviceScale6)];
    self.pixellateSwitch.on = NO;
    [self.pixellateSwitch addTarget:self action:@selector(pixellateSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_pixellateSwitch];
    
#endif
    
}

- (void)backToParent
{
    [self stopRecord];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)turnCameraHandler
{
    if (self.nativeRecorder)
    {
        [self.nativeRecorder turnCamera];
    }
}

- (void)turnTorchModeStatus
{
    if (self.nativeRecorder)
    {
        [self.nativeRecorder turnTorchModeStatus];
    }
}

- (void)startRecord
{
    if (self.nativeRecorder)
    {
        [self.nativeRecorder startRecord];
    }
    
    self.startButton.hidden = YES;
    self.onLiveImageView.hidden = NO;

#ifdef CIIMAGE_FILTER
    self.saturationLabel.hidden = YES;
    self.brightnessLabel.hidden = YES;
    self.contrastLabel.hidden = YES;
    self.gaussianBlurLabel.hidden = YES;
    self.saturationSlider.hidden = YES;
    self.brightnessSlider.hidden = YES;
    self.contrastSlider.hidden = YES;
    self.gaussianBlurSlider.hidden = YES;
#endif
    
#ifdef GPUIMAGE_FILTER
    self.beautifyLabel.hidden = YES;
    self.beautifySwitch.hidden = YES;
    self.toonLabel.hidden = YES;
    self.toonSwitch.hidden = YES;
    self.sketchLabel.hidden = YES;
    self.sketchSWitch.hidden = YES;
    self.pixellateLabel.hidden = YES;
    self.pixellateSwitch.hidden = YES;
#endif
    
    
}

- (void)stopRecord
{
    if (self.nativeRecorder)
    {
        [self.nativeRecorder stopRecord];
    }
}


#ifdef CIIMAGE_FILTER
- (void)changeSaturation:(UISlider *)slider
{
    //NSLog(@"饱和度数值变化: %f",slider.value);
    @synchronized (self)
    {
        [self.videoImageFilterValueDic setObject:@(slider.value) forKey:@"saturationValue"];
        [self.nativeRecorder setVideoImageFilterValueInfoDic:_videoImageFilterValueDic];
    }
    
}

- (void)changeBrightness:(UISlider *)slider
{
    //NSLog(@"明亮度数值变化: %f",slider.value);
    @synchronized (self)
    {
        [self.videoImageFilterValueDic setObject:@(slider.value) forKey:@"brightnessValue"];
        [self.nativeRecorder setVideoImageFilterValueInfoDic:_videoImageFilterValueDic];
    }
}

- (void)changeContrast:(UISlider *)slider
{
    //NSLog(@"对比度数值变化: %f",slider.value);
    @synchronized (self)
    {
        [self.videoImageFilterValueDic setObject:@(slider.value) forKey:@"contrastValue"];
        [self.nativeRecorder setVideoImageFilterValueInfoDic:_videoImageFilterValueDic];
    }
}

- (void)changeGaussianBlur:(UISlider *)slider
{
    NSLog(@"高斯模糊数值变化: %f",slider.value);
    @synchronized (self)
    {
        [self.videoImageFilterValueDic setObject:@(slider.value) forKey:@"gaussianBlurValue"];
        [self.nativeRecorder setVideoImageFilterValueInfoDic:_videoImageFilterValueDic];
    }
}
#endif


#ifdef GPUIMAGE_FILTER

- (void)beautySwitchAction:(UISwitch *)switchButton
{
    BOOL isFilterOn = [switchButton isOn];
    NSNumber *filterValue = @(0);
    if (isFilterOn)
    {
        filterValue = @(1);
    }
    
    [self.videoImageFilterValueDic setObject:filterValue forKey:@"beautifyFilterEnable"];
    [self.nativeRecorder setVideoImageFilterValueInfoDic:_videoImageFilterValueDic];
}


- (void)toonSwitchAction:(UISwitch *)switchButton
{
    BOOL isFilterOn = [switchButton isOn];
    NSNumber *filterValue = @(0);
    if (isFilterOn)
    {
        filterValue = @(1);
    }
    
    [self.videoImageFilterValueDic setObject:filterValue forKey:@"toonFilterEnbale"];
    [self.nativeRecorder setVideoImageFilterValueInfoDic:_videoImageFilterValueDic];
}



- (void)sketchSwitchAction:(UISwitch *)switchButton
{
    BOOL isFilterOn = [switchButton isOn];
    NSNumber *filterValue = @(0);
    if (isFilterOn)
    {
        filterValue = @(1);
    }
    
    [self.videoImageFilterValueDic setObject:filterValue forKey:@"sketchFilterEnable"];
    [self.nativeRecorder setVideoImageFilterValueInfoDic:_videoImageFilterValueDic];
}

- (void)pixellateSwitchAction:(UISwitch *)switchButton
{
    BOOL isFilterOn = [switchButton isOn];
    NSNumber *filterValue = @(0);
    if (isFilterOn)
    {
        filterValue = @(1);
    }
    
    [self.videoImageFilterValueDic setObject:filterValue forKey:@"pixellateFilterEnbale"];
    [self.nativeRecorder setVideoImageFilterValueInfoDic:_videoImageFilterValueDic];
}

#endif



@end
