//
//  WBNativePlayerViewController.m
//  WBNativePlayer
//
//  Created by 王博 on 2017/8/23.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBNativePlayerViewController.h"
#import "ZFPlayerView.h"

@interface WBNativePlayerViewController ()<ZFPlayerDelegate>

@property (nonatomic, strong) ZFPlayerView *nativePlayerView;
@property (nonatomic, strong) ZFPlayerModel *nativePlayerModel;

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) NSString *videoTitle;

@end

@implementation WBNativePlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setPlayer];
    [self play];
}

- (void)play
{
    [self updatePlayerModel];
    [self.nativePlayerView resetToPlayNewVideo:_nativePlayerModel];
}


- (void)updatePlayerModel
{
    self.nativePlayerModel.videoURL = _videoURL;
    self.nativePlayerModel.placeholderImage = _placeholderImage;
    self.nativePlayerModel.title = _videoTitle;
}


- (void)setPlayer
{
    if (!self.nativePlayerModel)
    {
        self.nativePlayerModel = [[ZFPlayerModel alloc] init];
        self.nativePlayerModel.fatherView = self.view;
    }
    
    if (!self.nativePlayerView)
    {
        self.nativePlayerView = [[ZFPlayerView alloc] init];
        /*****************************************************************************************
         *   // 指定控制层(可自定义)
         *   // ZFPlayerControlView *controlView = [[ZFPlayerControlView alloc] init];
         *   // 设置控制层和播放模型
         *   // 控制层传nil，默认使用ZFPlayerControlView(如自定义可传自定义的控制层)
         *   // 等效于 [_playerView playerModel:self.playerModel];
         ******************************************************************************************/
        [self.nativePlayerView playerControlView:nil playerModel:_nativePlayerModel];
        // 设置代理
        self.nativePlayerView .delegate = self;
        //（可选设置）可以设置视频的填充模式，内部设置默认（ZFPlayerLayerGravityResizeAspect：等比例填充，直到一个维度到达区域边界）
        // _playerView.playerLayerGravity = ZFPlayerLayerGravityResize;
        // 打开下载功能（默认没有这个功能）
        self.nativePlayerView .hasDownload    = NO;
        // 打开预览图
        self.nativePlayerView.hasPreviewView = YES;
        // 开启自动播放
        self.nativePlayerView.playerPushedOrPresented = YES;
        [self.nativePlayerView autoPlayTheVideo];
    }
}


- (void)setVideoViewURL:(NSURL *)videoURL
{
    self.videoURL = videoURL;
}

- (void)setVideoViewPlaceholder:(UIImage *)placeholderImage
{
    self.placeholderImage = placeholderImage;
}

- (void)setVideoViewTitle:(NSString *)videoTitle
{
    self.videoTitle = videoTitle;
}


#pragma mark ZFPlayerDelegate
/** 返回按钮事件 */
- (void)zf_playerBackAction
{
    [self.navigationController popViewControllerAnimated:YES];
}
/** 下载视频 */
- (void)zf_playerDownload:(NSString *)url
{
    //Nothing to do
}
/** 控制层即将显示 */
- (void)zf_playerControlViewWillShow:(UIView *)controlView isFullscreen:(BOOL)fullscreen
{
    //Nothing to do
}
/** 控制层即将隐藏 */
- (void)zf_playerControlViewWillHidden:(UIView *)controlView isFullscreen:(BOOL)fullscreen
{
    //Nothing to do
}


@end
