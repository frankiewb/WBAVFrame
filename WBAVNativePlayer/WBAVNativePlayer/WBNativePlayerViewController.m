//
//  WBNativePlayerViewController.m
//  WBAVNativePlayer
//
//  Created by WangBo on 2017/6/28.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBNativePlayerViewController.h"

@interface WBNativePlayerViewController ()

@end

@implementation WBNativePlayerViewController


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
    desLabel.text = @"原生播放页面";
    desLabel.font = [UIFont systemFontOfSize:30];
    desLabel.textColor = [UIColor blackColor];
    [self.view addSubview:desLabel];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}



@end
