//
//  WBVideoPlayerSettingViewController.m
//  WBAVFrame
//
//  Created by WangBo on 2017/6/27.
//  Copyright © 2017年 WangBo. All rights reserved.
//

#import "WBVideoPlayerSettingViewController.h"
#import "WBIJKPlayerViewController.h"
#import "WBNativePlayerViewController.h"

@interface WBVideoPlayerSettingViewController ()

@property (nonatomic, strong) UIButton *ijkVideoPlayerButton;

@property (nonatomic, strong) UIButton *nativeVideoPlayerButton;

@end

@implementation WBVideoPlayerSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setSubView];
}

- (void)setSubView
{
    //nativeLiveRecorderButtons
    self.ijkVideoPlayerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.ijkVideoPlayerButton.backgroundColor = [UIColor clearColor];
    self.ijkVideoPlayerButton.tag = 1;
    [self.ijkVideoPlayerButton setImage:[UIImage imageNamed:@"wbIJKPlayer"] forState:UIControlStateNormal];
    [self.ijkVideoPlayerButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    self.ijkVideoPlayerButton.titleLabel.font = [UIFont systemFontOfSize:18*WBDeviceScale6];
    [self.ijkVideoPlayerButton setTitleColor:[UIColor colorWithHexString:@"9FD395"] forState:UIControlStateNormal];
    [self.ijkVideoPlayerButton setTitle:@"IJK播放" forState:UIControlStateNormal];
    self.ijkVideoPlayerButton.frame = CGRectMake(25*WBDeviceScale6, 100*WBDeviceScale6, 150*WBDeviceScale6, 200*WBDeviceScale6);
    self.ijkVideoPlayerButton.layer.borderWidth = 4*WBDeviceScale6;
    self.ijkVideoPlayerButton.layer.borderColor = [UIColor colorWithHexString:@"9FD395"].CGColor;
    self.ijkVideoPlayerButton.layer.cornerRadius = 8*WBDeviceScale6;
    [self.ijkVideoPlayerButton addTarget:self action:@selector(recorderButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self setButtonVerticalLayout:_ijkVideoPlayerButton];
    [self.view addSubview:_ijkVideoPlayerButton];
    
    
    //beautyLiveRecorderButton
    self.nativeVideoPlayerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nativeVideoPlayerButton.backgroundColor = [UIColor clearColor];
    self.nativeVideoPlayerButton.tag = 2;
    [self.nativeVideoPlayerButton setImage:[UIImage imageNamed:@"wbNativePlayer"] forState:UIControlStateNormal];
    [self.nativeVideoPlayerButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    self.nativeVideoPlayerButton.titleLabel.font = [UIFont systemFontOfSize:18*WBDeviceScale6];
    [self.nativeVideoPlayerButton setTitleColor:[UIColor colorWithHexString:@"9FD395"] forState:UIControlStateNormal];
    [self.nativeVideoPlayerButton setTitle:@"原生播放" forState:UIControlStateNormal];
    self.nativeVideoPlayerButton.frame = CGRectMake(200*WBDeviceScale6, 100*WBDeviceScale6, 150*WBDeviceScale6, 200*WBDeviceScale6);
    self.nativeVideoPlayerButton.layer.borderWidth = 4*WBDeviceScale6;
    self.nativeVideoPlayerButton.layer.borderColor = [UIColor colorWithHexString:@"9FD395"].CGColor;
    self.nativeVideoPlayerButton.layer.cornerRadius = 8*WBDeviceScale6;
    [self.nativeVideoPlayerButton addTarget:self action:@selector(recorderButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self setButtonVerticalLayout:_nativeVideoPlayerButton];
    [self.view addSubview:_nativeVideoPlayerButton];
}

- (void)recorderButtonClickedHandler:(UIButton *)recorderButton
{
    if (recorderButton.tag == 1)
    {
        WBIJKPlayerViewController *ijkPlayerVC = [[WBIJKPlayerViewController alloc] init];
        [self.navigationController pushViewController:ijkPlayerVC animated:YES];
    }
    else if (recorderButton.tag == 2)
    {
        WBNativePlayerViewController *nativePlayerVC = [[WBNativePlayerViewController alloc] init];
        [self.navigationController pushViewController:nativePlayerVC animated:YES];
    }
}

- (void)setButtonVerticalLayout:(UIButton *)button
{
    
    CGFloat imageWidth  = button.imageView.frame.size.width;
    CGFloat imageHeight = button.imageView.frame.size.height;
    CGFloat labelWidth  = button.titleLabel.frame.size.width;
    CGFloat labelHeight = button.titleLabel.frame.size.height;
    
    //Image中心位置向右移动
    CGFloat imageOffsetX = (imageWidth + labelWidth) / 2 - imageWidth/2;
    //Image中心位置向上移动
    CGFloat imageOffsetY = imageHeight / 2;
    //ImageEdgeInsets
    button.imageEdgeInsets = UIEdgeInsetsMake(-imageOffsetY + 10, imageOffsetX, imageOffsetY, -imageOffsetX);
    
    //Label中心位置向左移动
    CGFloat labelOffsetX = (imageWidth + labelWidth / 2) - (imageWidth + labelWidth) / 2;
    //Label中心位置向下移动
    CGFloat labelOffsetY = labelHeight / 2 + 20;
    //LabelEdgeInsets
    button.titleEdgeInsets = UIEdgeInsetsMake(labelOffsetY, -labelOffsetX, -labelOffsetY - 10, labelOffsetX);
}



@end
