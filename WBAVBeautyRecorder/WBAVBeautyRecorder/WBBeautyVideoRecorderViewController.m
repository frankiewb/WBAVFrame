//
//  WBBeautyVideoRecorderViewController.m
//  WBAVBeautyRecorder
//
//  Created by WangBo on 2017/6/28.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBBeautyVideoRecorderViewController.h"

@interface WBBeautyVideoRecorderViewController ()

@end

@implementation WBBeautyVideoRecorderViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *desLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 200, 100)];
    desLabel.text = @"GPUImage视频页面";
    desLabel.font = [UIFont systemFontOfSize:20];
    desLabel.textColor = [UIColor blackColor];
    [self.view addSubview:desLabel];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}



@end
