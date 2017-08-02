//
//  WBNativeLiveRecorderViewController.m
//  WBAVNativeRecorder
//
//  Created by 王博 on 2017/6/28.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBNativeLiveRecorderViewController.h"
#import "WBNativeLiveRecorder.h"

@interface WBNativeLiveRecorderViewController ()

@property (nonatomic, strong) WBNativeLiveRecorder *liveRecorder;

@property (nonatomic, strong) UIButton *backButton;//返回按钮

@property (nonatomic, strong) UIButton *turnCameraButton;//切换摄像头按钮

@property (nonatomic, strong) UIButton *torchButton;//开启关闭闪光灯按钮

@property (nonatomic, strong) UIButton *startLiveButton;//开始直播

@property (nonatomic, strong) UIImageView *onLiveImageView;//直播中图标


//可设置美颜参数
@property (nonatomic, strong) NSMutableDictionary *videoImageFilterValueDic;//滤镜参数设置集合数组
//美颜相关控件
@property (nonatomic, strong) UILabel *saturationLabel;//饱和度
@property (nonatomic, strong) UILabel *brightnessLabel;//亮度
@property (nonatomic, strong) UILabel *contrastLabel;//对比度
@property (nonatomic, strong) UILabel *gaussianBlurLabel;//高斯模糊

@property (nonatomic, strong) UISlider *saturationSlider;
@property (nonatomic, strong) UISlider *brightnessSlider;
@property (nonatomic, strong) UISlider *contrastSlider;
@property (nonatomic, strong) UISlider *gaussianBlurSlider;



@end

@implementation WBNativeLiveRecorderViewController


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
#ifdef CIIMAGE_FILTER
    self.videoImageFilterValueDic = [[NSMutableDictionary alloc] init];
    [self.videoImageFilterValueDic setObject:@(1) forKey:@"saturationValue"];
    [self.videoImageFilterValueDic setObject:@(0) forKey:@"brightnessValue"];
    [self.videoImageFilterValueDic setObject:@(1) forKey:@"contrastValue"];
    [self.videoImageFilterValueDic setObject:@(0) forKey:@"gaussianBlurValue"];
#endif
}

- (void)setLiveRecorder
{
    self.liveRecorder = [[WBNativeLiveRecorder alloc] initWithLivePreViewLayer:self.view];
#ifdef CIIMAGE_FILTER
    [self.liveRecorder setVideoImageFilterValueInfoDic:_videoImageFilterValueDic];
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
    self.startLiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.startLiveButton setBackgroundImage:[UIImage imageNamed:@"beginRecord"] forState:UIControlStateNormal];
    self.startLiveButton.frame = CGRectMake(WBScreenWidth/2 - 30*WBDeviceScale6, WBScreenHeight - 90*WBDeviceScale6, 60*WBDeviceScale6, 60*WBDeviceScale6);
    [self.startLiveButton addTarget:self action:@selector(startLiveRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startLiveButton];
    
    //onLiveImageView
    self.onLiveImageView = [[UIImageView alloc] init];
    [self.onLiveImageView setImage:[UIImage imageNamed:@"onLive"]];
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
    
}

- (void)backToParent
{
    [self stopLiveRecord];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)turnCameraHandler
{
    if (self.liveRecorder)
    {
        [self.liveRecorder turnCamera];
    }
}

- (void)turnTorchModeStatus
{
    if (self.liveRecorder)
    {
        [self.liveRecorder turnTorchModeStatus];
    }
}

- (void)startLiveRecord
{
    if (self.liveRecorder)
    {
        [self.liveRecorder startLiveRecord];
    }

    self.startLiveButton.hidden = YES;
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
}

- (void)stopLiveRecord
{
    if (self.liveRecorder)
    {
        [self.liveRecorder stopLiveRecord];
    }
}


#ifdef CIIMAGE_FILTER
- (void)changeSaturation:(UISlider *)slider
{
    //NSLog(@"饱和度数值变化: %f",slider.value);
    @synchronized (self)
    {
        [self.videoImageFilterValueDic setObject:@(slider.value) forKey:@"saturationValue"];
        [self.liveRecorder setVideoImageFilterValueInfoDic:_videoImageFilterValueDic];
    }
    
}

- (void)changeBrightness:(UISlider *)slider
{
    //NSLog(@"明亮度数值变化: %f",slider.value);
    @synchronized (self)
    {
        [self.videoImageFilterValueDic setObject:@(slider.value) forKey:@"brightnessValue"];
        [self.liveRecorder setVideoImageFilterValueInfoDic:_videoImageFilterValueDic];
    }
}

- (void)changeContrast:(UISlider *)slider
{
    //NSLog(@"对比度数值变化: %f",slider.value);
    @synchronized (self)
    {
        [self.videoImageFilterValueDic setObject:@(slider.value) forKey:@"contrastValue"];
        [self.liveRecorder setVideoImageFilterValueInfoDic:_videoImageFilterValueDic];
    }
}

- (void)changeGaussianBlur:(UISlider *)slider
{
    NSLog(@"高斯模糊数值变化: %f",slider.value);
    @synchronized (self)
    {
        [self.videoImageFilterValueDic setObject:@(slider.value) forKey:@"gaussianBlurValue"];
        [self.liveRecorder setVideoImageFilterValueInfoDic:_videoImageFilterValueDic];
    }
}
#endif









@end
