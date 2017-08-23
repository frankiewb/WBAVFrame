//
//  WBPlayerViewController.m
//  WBNativePlayer
//
//  Created by 王博 on 2017/8/18.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBPlayerViewController.h"
#import "WBImagePickerController.h"
#import "WBSettingMacros.h"
#import "WBNativePlayerViewController.h"
#import "WBMacros.h"


@interface WBPlayerViewController ()<WBImagePickerControllerDelegate>

@property (nonatomic, assign) WBPlayerType playerType;//播放器类型
@property (nonatomic, strong) WBImagePickerController *imagePickerController;//相册VC
@property (nonatomic, strong) WBNativePlayerViewController *nativePlayerViewController;//原生播放器VC

@end

@implementation WBPlayerViewController


- (instancetype)initWithPlayerType:(WBPlayerType)type
{
    self = [super init];
    if (self)
    {
        self.playerType = type;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.nativePlayerViewController = [[WBNativePlayerViewController alloc] init];
    [self setupImagePickerController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark ImagePicker相关

- (void)setupImagePickerController
{
    
    //初始化
    self.imagePickerController = [[WBImagePickerController alloc] initWithAccessType:WBImagePickerAccessTypeAlbums];
    self.imagePickerController.WBDelegate = self;    
    //最大选择个数
    self.imagePickerController.maxSelectCount = 9;
    //一行显示多少
    self.imagePickerController.numsInRow = 4;
    //是否开启多选图片
    self.imagePickerController.mutiSelected = YES;
    //是否开启选中蒙版效果
    self.imagePickerController.masking = YES;
    //是否开启选中动画
    self.imagePickerController.selectedAnimation = YES;
    //显示主题类型：Light/Dark
    self.imagePickerController.themeStyle = WBImagePickerStyleDark;
    //图片分组方式
    self.imagePickerController.photoMomentGroupType = WBImageMomentGroupTypeNone;
    //图片是否开启降序排列
    self.imagePickerController.photosDesc = YES;
    //是否显示相册缩略图
    self.imagePickerController.showAlbumThumbnail = YES;
    //是否显示相册内容个数
    self.imagePickerController.showAlbumNumber = YES;
    //是否显示空相册
    self.imagePickerController.showEmptyAlbum = NO;
    //是否只显示图片
    self.imagePickerController.onlyShowImages = NO;
    //是否显示Live图标
    self.imagePickerController.showLivePhotoIcon = YES;
    //第一个图标是否为相机
    self.imagePickerController.firstCamera = YES;
    //是否可以录制视频
    self.imagePickerController.makingVideo = YES;
    //录制视频是否自动保存至相册
    self.imagePickerController.videoAutoSave = YES;
    //视频最大录制时间
    self.imagePickerController.videoMaximumDuration = 10;
    //自定义相册名称
    self.imagePickerController.customAlbumName = VIDEO_FOLDER_NAME;
    
    //[self presentViewController:_imagePickerController animated:YES completion:nil];
    [self.view addSubview:_imagePickerController.view];

}

//WBImagePickerControllerDelegate
- (void)WBImagePickerController:(WBImagePickerController *)picker didPlayingVideoWithURL:(NSURL *)videoURL identifier:(NSString *)localIdentifier
{
    NSLog(@"将要播放视频了，快快播放吧");
    if (self.nativePlayerViewController)
    {
        [self.nativePlayerViewController setVideoViewTitle:localIdentifier];
        [self.nativePlayerViewController setVideoViewURL:videoURL];
        [self.nativePlayerViewController setVideoViewPlaceholder:nil];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //放到主线程去push，否则影响效率
        [self.navigationController pushViewController:_nativePlayerViewController animated:YES];
    });
    
}

- (void)WBImagePickerControllerDidCancel:(WBImagePickerController *)picker
{
    NSLog(@"取消相册点选");
    [self.navigationController popViewControllerAnimated:YES];
}


@end
