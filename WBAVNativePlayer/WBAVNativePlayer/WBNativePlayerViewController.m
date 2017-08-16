//
//  WBNativePlayerViewController.m
//  WBAVNativePlayer
//
//  Created by 王博 on 2017/6/28.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBNativePlayerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "WBSettingMacros.h"

@interface WBNativePlayerViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *videoSourceShowController;//本机视频展示页面

@end

@implementation WBNativePlayerViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.view.backgroundColor = [UIColor whiteColor];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //设置本机视频展示页面
    [self setVideoSourceShowVC];

}


- (void)setVideoSourceShowVC
{
    //判断当前的SourceType是否可用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        // 实例化UIImagePickerController控制器
        UIImagePickerController * imagePickerVC = [[UIImagePickerController alloc] init];
        // 设置资源来源（相册、相机、图库之一）
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 设置可用的媒体类型、默认只包含kUTTypeImage，如果想选择视频，请添加kUTTypeMovie
        imagePickerVC.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
        // 如果选择的是视屏，允许的视屏时长为20秒
        imagePickerVC.videoMaximumDuration = RECORD_MAX_TIME;
        // 允许的视屏质量（如果质量选取的质量过高，会自动降低质量）
        imagePickerVC.videoQuality = UIImagePickerControllerQualityTypeHigh;
        imagePickerVC.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];
        // 设置代理，遵守UINavigationControllerDelegate, UIImagePickerControllerDelegate 协议
        imagePickerVC.delegate = self;
        // 是否允许编辑（YES：图片选择完成进入编辑模式）
        imagePickerVC.allowsEditing = YES;
        // model出控制器
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }
}



#pragma mark UIImagePickerControllerDelegate

//选择图片或者视频成功代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // dismiss UIImagePickerController
    [self dismissViewControllerAnimated:YES completion:nil];
    // 选择的图片信息存储于info字典中
    NSLog(@"%@", info);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // dismiss UIImagePickerController
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}



@end
