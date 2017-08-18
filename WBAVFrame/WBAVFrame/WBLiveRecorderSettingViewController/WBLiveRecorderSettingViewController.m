//
//  WBLiveRecorderSettingViewController.m
//  WBAVFrame
//
//  Created by 王博 on 2017/6/27.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBLiveRecorderSettingViewController.h"
#import "WBRecorderViewController.h"
#import "WBBeautyLiveRecorderViewController.h"


@interface WBLiveRecorderSettingViewController ()

@property (nonatomic, strong) UIButton *nativeLiveRecorderButton;

@property (nonatomic, strong) UIButton *beautyLiveRecorderButton;

@end

@implementation WBLiveRecorderSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setSubView];
}



- (void)setSubView
{
    //nativeLiveRecorderButtons
    self.nativeLiveRecorderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nativeLiveRecorderButton.backgroundColor = [UIColor clearColor];
    self.nativeLiveRecorderButton.tag = 1;
    [self.nativeLiveRecorderButton setImage:[UIImage imageNamed:@"wbNativeRecorder"] forState:UIControlStateNormal];
    [self.nativeLiveRecorderButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    self.nativeLiveRecorderButton.titleLabel.font = [UIFont systemFontOfSize:18*WBDeviceScale6];
    [self.nativeLiveRecorderButton setTitleColor:[UIColor colorWithHexString:@"9FD395"] forState:UIControlStateNormal];
    [self.nativeLiveRecorderButton setTitle:@"原生直播" forState:UIControlStateNormal];
    self.nativeLiveRecorderButton.frame = CGRectMake(25*WBDeviceScale6, 100*WBDeviceScale6, 150*WBDeviceScale6, 200*WBDeviceScale6);
    self.nativeLiveRecorderButton.layer.borderWidth = 4*WBDeviceScale6;
    self.nativeLiveRecorderButton.layer.borderColor = [UIColor colorWithHexString:@"9FD395"].CGColor;
    self.nativeLiveRecorderButton.layer.cornerRadius = 8*WBDeviceScale6;
    [self.nativeLiveRecorderButton addTarget:self action:@selector(recorderButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self setButtonVerticalLayout:_nativeLiveRecorderButton];
    [self.view addSubview:_nativeLiveRecorderButton];
    
    
    //beautyLiveRecorderButton
    self.beautyLiveRecorderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.beautyLiveRecorderButton.backgroundColor = [UIColor clearColor];
    self.beautyLiveRecorderButton.tag = 2;
    [self.beautyLiveRecorderButton setImage:[UIImage imageNamed:@"wbLiveBeatutyRecorder"] forState:UIControlStateNormal];
    [self.beautyLiveRecorderButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    self.beautyLiveRecorderButton.titleLabel.font = [UIFont systemFontOfSize:17*WBDeviceScale6];
    [self.beautyLiveRecorderButton setTitleColor:[UIColor colorWithHexString:@"9FD395"] forState:UIControlStateNormal];
    [self.beautyLiveRecorderButton setTitle:@"GPUImage\n直播" forState:UIControlStateNormal];
    self.beautyLiveRecorderButton.titleLabel.lineBreakMode = 0;
    [self.beautyLiveRecorderButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    self.beautyLiveRecorderButton.frame = CGRectMake(200*WBDeviceScale6, 100*WBDeviceScale6, 150*WBDeviceScale6, 200*WBDeviceScale6);
    self.beautyLiveRecorderButton.layer.borderWidth = 4*WBDeviceScale6;
    self.beautyLiveRecorderButton.layer.borderColor = [UIColor colorWithHexString:@"9FD395"].CGColor;
    self.beautyLiveRecorderButton.layer.cornerRadius = 8*WBDeviceScale6;
    [self.beautyLiveRecorderButton addTarget:self action:@selector(recorderButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self setButtonVerticalLayout:_beautyLiveRecorderButton];
    [self.view addSubview:_beautyLiveRecorderButton];
}

- (void)recorderButtonClickedHandler:(UIButton *)recorderButton
{
    if (recorderButton.tag == 1)
    {
        WBRecorderViewController *nativeRecorderVC = [[WBRecorderViewController alloc] initWithRecorderType:WBNativeRecorderTypeLive];
        [self.navigationController pushViewController:nativeRecorderVC animated:YES];
    }
    else if (recorderButton.tag == 2)
    {
        WBBeautyLiveRecorderViewController *beautyRecorderVC = [[WBBeautyLiveRecorderViewController alloc] init];
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
