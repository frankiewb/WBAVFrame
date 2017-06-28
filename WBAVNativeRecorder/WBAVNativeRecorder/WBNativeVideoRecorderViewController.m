//
//  WBNativeVideoRecorderViewController.m
//  WBAVNativeRecorder
//
//  Created by 王博 on 2017/6/28.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBNativeVideoRecorderViewController.h"

@interface WBNativeVideoRecorderViewController ()

@end

@implementation WBNativeVideoRecorderViewController


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
    desLabel.text = @"原生视频录制页面";
    desLabel.font = [UIFont systemFontOfSize:20];
    desLabel.textColor = [UIColor blackColor];
    [self.view addSubview:desLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}



@end
