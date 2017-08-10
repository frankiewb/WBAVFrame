//
//  WBVideoRecorderSettingViewController.m
//  WBAVFrame
//
//  Created by WangBo on 2017/6/27.
//  Copyright © 2017年 WangBo. All rights reserved.
//

#import "WBVideoRecorderSettingViewController.h"
#import "WBNativeRecorderViewController.h"
#import "WBBeautyVideoRecorderViewController.h"

@interface WBVideoRecorderSettingViewController ()

@property (nonatomic, strong) UIButton *nativeVideoRecorderButton;

@property (nonatomic, strong) UIButton *beautyVideoRecorderButton;

@end

@implementation WBVideoRecorderSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setSubView];
}

- (void)setSubView
{
    //nativeLiveRecorderButtons
    self.nativeVideoRecorderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nativeVideoRecorderButton.backgroundColor = [UIColor clearColor];
    self.nativeVideoRecorderButton.tag = 1;
    [self.nativeVideoRecorderButton setImage:[UIImage imageNamed:@"wbVideoNativeRecorder"] forState:UIControlStateNormal];
    [self.nativeVideoRecorderButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    self.nativeVideoRecorderButton.titleLabel.font = [UIFont systemFontOfSize:18*WBDeviceScale6];
    [self.nativeVideoRecorderButton setTitleColor:[UIColor colorWithHexString:@"9FD395"] forState:UIControlStateNormal];
    [self.nativeVideoRecorderButton setTitle:@"原生录制" forState:UIControlStateNormal];
    self.nativeVideoRecorderButton.frame = CGRectMake(25*WBDeviceScale6, 100*WBDeviceScale6, 150*WBDeviceScale6, 200*WBDeviceScale6);
    self.nativeVideoRecorderButton.layer.borderWidth = 4*WBDeviceScale6;
    self.nativeVideoRecorderButton.layer.borderColor = [UIColor colorWithHexString:@"9FD395"].CGColor;
    self.nativeVideoRecorderButton.layer.cornerRadius = 8*WBDeviceScale6;
    [self.nativeVideoRecorderButton addTarget:self action:@selector(recorderButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self setButtonVerticalLayout:_nativeVideoRecorderButton];
    [self.view addSubview:_nativeVideoRecorderButton];
    
    
    //beautyLiveRecorderButton
    self.beautyVideoRecorderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.beautyVideoRecorderButton.backgroundColor = [UIColor clearColor];
    self.beautyVideoRecorderButton.tag = 2;
    [self.beautyVideoRecorderButton setImage:[UIImage imageNamed:@"wbVideoBeautiRecorder"] forState:UIControlStateNormal];
    [self.beautyVideoRecorderButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    self.beautyVideoRecorderButton.titleLabel.font = [UIFont systemFontOfSize:17*WBDeviceScale6];
    [self.beautyVideoRecorderButton setTitleColor:[UIColor colorWithHexString:@"9FD395"] forState:UIControlStateNormal];
    [self.beautyVideoRecorderButton setTitle:@"GPUImage\n录制" forState:UIControlStateNormal];
    self.beautyVideoRecorderButton.titleLabel.lineBreakMode = 0;
    [self.beautyVideoRecorderButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    self.beautyVideoRecorderButton.frame = CGRectMake(200*WBDeviceScale6, 100*WBDeviceScale6, 150*WBDeviceScale6, 200*WBDeviceScale6);
    self.beautyVideoRecorderButton.layer.borderWidth = 4*WBDeviceScale6;
    self.beautyVideoRecorderButton.layer.borderColor = [UIColor colorWithHexString:@"9FD395"].CGColor;
    self.beautyVideoRecorderButton.layer.cornerRadius = 8*WBDeviceScale6;
    [self.beautyVideoRecorderButton addTarget:self action:@selector(recorderButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self setButtonVerticalLayout:_beautyVideoRecorderButton];
    [self.view addSubview:_beautyVideoRecorderButton];
}

- (void)recorderButtonClickedHandler:(UIButton *)recorderButton
{
    if (recorderButton.tag == 1)
    {
        WBNativeRecorderViewController *nativeRecorderVC = [[WBNativeRecorderViewController alloc] initWithRecorderType:WBNativeRecorderTypeVideo];
        [self.navigationController pushViewController:nativeRecorderVC animated:YES];
    }
    else if (recorderButton.tag == 2)
    {
        WBBeautyVideoRecorderViewController *beautyRecorderVC = [[WBBeautyVideoRecorderViewController alloc] init];
        [self.navigationController pushViewController:beautyRecorderVC animated:YES];
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
