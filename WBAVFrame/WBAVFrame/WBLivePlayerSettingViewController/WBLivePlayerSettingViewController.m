//
//  WBLivePlayerSettingViewController.m
//  WBAVFrame
//
//  Created by WangBo on 2017/6/27.
//  Copyright © 2017年 WangBo. All rights reserved.
//

#import "WBLivePlayerSettingViewController.h"
#import "WBIJKPlayerViewController.h"

@interface WBLivePlayerSettingViewController ()

@property (nonatomic, strong) UIButton *ijkLivePlayerButton;

@end

@implementation WBLivePlayerSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setSubView];
}

- (void)setSubView
{
    //nativeLiveRecorderButtons
    self.ijkLivePlayerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.ijkLivePlayerButton.backgroundColor = [UIColor clearColor];
    self.ijkLivePlayerButton.tag = 1;
    [self.ijkLivePlayerButton setImage:[UIImage imageNamed:@"wbIJKPlayer"] forState:UIControlStateNormal];
    [self.ijkLivePlayerButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    self.ijkLivePlayerButton.titleLabel.font = [UIFont systemFontOfSize:18*WBDeviceScale6];
    [self.ijkLivePlayerButton setTitleColor:[UIColor colorWithHexString:@"9FD395"] forState:UIControlStateNormal];
    [self.ijkLivePlayerButton setTitle:@"IJK播放" forState:UIControlStateNormal];
    self.ijkLivePlayerButton.frame = CGRectMake(112.5*WBDeviceScale6, 100*WBDeviceScale6, 150*WBDeviceScale6, 200*WBDeviceScale6);
    self.ijkLivePlayerButton.layer.borderWidth = 4*WBDeviceScale6;
    self.ijkLivePlayerButton.layer.borderColor = [UIColor colorWithHexString:@"9FD395"].CGColor;
    self.ijkLivePlayerButton.layer.cornerRadius = 8*WBDeviceScale6;
    [self.ijkLivePlayerButton addTarget:self action:@selector(recorderButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self setButtonVerticalLayout:_ijkLivePlayerButton];
    [self.view addSubview:_ijkLivePlayerButton];

}

- (void)recorderButtonClickedHandler:(UIButton *)recorderButton
{
    WBIJKPlayerViewController *ijkPlayerVC = [[WBIJKPlayerViewController alloc] init];
    [self.navigationController pushViewController:ijkPlayerVC animated:YES];
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
