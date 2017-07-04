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
    [self setLiveRecorder];
    [self setSubview];
}

- (void)setLiveRecorder
{
    self.liveRecorder = [[WBNativeLiveRecorder alloc] initWithLivePreViewLayer:self.view];
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
}

- (void)stopLiveRecord
{
    if (self.liveRecorder)
    {
        [self.liveRecorder stopLiveRecord];
    }
}







@end
