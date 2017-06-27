//
//  WBAVRootViewController.m
//  WBAVFrame
//
//  Created by 王博 on 2017/6/27.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBAVRootViewController.h"
#import "WBVideoPlayerSettingViewController.h"
#import "WBVideoRecorderSettingViewController.h"
#import "WBLivePlayerSettingViewController.h"
#import "WBLiveRecorderSettingViewController.h"
#import "WBAVRootBottomButtonView.h"

@interface WBAVRootViewController ()

@property (nonatomic, strong) WBAVRootBottomButtonView *rootBottomButtonView;

@property (nonatomic, strong) UIScrollView *mainScrollBGView;

@property (nonatomic, strong) WBLiveRecorderSettingViewController *liveRecorderSettingVC;//直播录播模块

@property (nonatomic, strong) WBLivePlayerSettingViewController *livePlayerSettingVC;//直播播放模块

@property (nonatomic, strong) WBVideoRecorderSettingViewController *videoRecorderSettingVC;//视频录制模块

@property (nonatomic, strong) WBVideoPlayerSettingViewController *videoPlayerSettingVC;//视频播放模块

@end

@implementation WBAVRootViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setAVFrameScrollBGView];
    [self setLiveRecorderSettingViewController];
    [self setRootBottomButtonView];
    
}


#pragma mark 主内容展示背景
- (void)setAVFrameScrollBGView
{
    self.mainScrollBGView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WBScreenWidth, WBScreenHeight - 50*WBDeviceScale6)];
    
    self.mainScrollBGView.backgroundColor = [UIColor clearColor];
    self.mainScrollBGView.showsHorizontalScrollIndicator = NO;
    self.mainScrollBGView.showsVerticalScrollIndicator = NO;
    self.mainScrollBGView.contentSize = CGSizeMake(WBScreenWidth*4, self.mainScrollBGView.frame.size.height);
    self.mainScrollBGView.bounces = NO;
    self.mainScrollBGView.scrollEnabled = NO;
    [self.view addSubview:_mainScrollBGView];
}

#pragma mark 直播录播模块
- (void)setLiveRecorderSettingViewController
{
    if (!self.liveRecorderSettingVC)
    {
        self.liveRecorderSettingVC = [[WBLiveRecorderSettingViewController alloc] init];
        self.liveRecorderSettingVC.view.frame = CGRectMake(0, 0, self.mainScrollBGView.frame.size.width, self.mainScrollBGView.frame.size.height);
        [self.mainScrollBGView addSubview:_liveRecorderSettingVC.view];
        [self addChildViewController:_liveRecorderSettingVC];
    }
}

#pragma mark 直播播放模块
- (void)setLivePlayerSettingViewController
{
    if (!self.livePlayerSettingVC)
    {
        self.livePlayerSettingVC = [[WBLivePlayerSettingViewController alloc] init];
        self.livePlayerSettingVC.view.frame = CGRectMake(0 + WBScreenWidth*1, 0, self.mainScrollBGView.frame.size.width, self.mainScrollBGView.frame.size.height);
        [self.mainScrollBGView addSubview:_livePlayerSettingVC.view];
        [self addChildViewController:_livePlayerSettingVC];
    }
}

#pragma mark 视频录制模块
- (void)setVideoRecorderSettingViewController
{
    if (!self.videoRecorderSettingVC)
    {
        self.videoRecorderSettingVC = [[WBVideoRecorderSettingViewController alloc] init];
        self.videoRecorderSettingVC.view.frame = CGRectMake(0 + WBScreenWidth*2, 0, self.mainScrollBGView.frame.size.width, self.mainScrollBGView.frame.size.height);
        [self.mainScrollBGView addSubview:_videoRecorderSettingVC.view];
        [self addChildViewController:_videoRecorderSettingVC];
    }
}

#pragma mark 视频播放模块
- (void)setVideoPlayerSettingViewController
{
    if (!self.videoPlayerSettingVC)
    {
        self.videoPlayerSettingVC = [[WBVideoPlayerSettingViewController alloc] init];
        self.videoPlayerSettingVC.view.frame = CGRectMake(0 + WBScreenWidth*3, 0, self.mainScrollBGView.frame.size.width, self.mainScrollBGView.frame.size.height);
        [self.mainScrollBGView addSubview:_videoPlayerSettingVC.view];
        [self addChildViewController:_videoPlayerSettingVC];
    }
}

#pragma mark 底部选择按钮模块
- (void)setRootBottomButtonView
{
    self.rootBottomButtonView = [[WBAVRootBottomButtonView alloc] initWithFrame:CGRectMake(0, WBScreenHeight - 50*WBDeviceScale6, WBScreenWidth, 50*WBDeviceScale6)];
    [self.view addSubview:_rootBottomButtonView];
    self.rootBottomButtonView.backgroundColor = [UIColor greenColor];
    
    WEAK_SELF;
    self.rootBottomButtonView.wbAVRootBottomButtonClickHandler = ^(WBAVType type)
    {
        NSInteger buttonIndex = 0;
        (type > 2) ? (buttonIndex = type - 1) : (buttonIndex = type);
        switch (type) {
            case WBAVTypeLiveRecorder:
                [weakSelf setLiveRecorderSettingViewController];
                break;
            case WBAVTypeLivePlayer:
                [weakSelf setLivePlayerSettingViewController];
                break;
            case WBAVTypeVideoRecorder:
                [weakSelf setVideoRecorderSettingViewController];
                break;
            case WBAVTypeVideoPlayer:
                [weakSelf setVideoPlayerSettingViewController];
                break;
            case WBAVTypeRecorderButton:
                //do something
                return;
        }
        
        [weakSelf.mainScrollBGView setContentOffset:CGPointMake(WBScreenWidth *buttonIndex, 0) animated:NO];
    };
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



@end
