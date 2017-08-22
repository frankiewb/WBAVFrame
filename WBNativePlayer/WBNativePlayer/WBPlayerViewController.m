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
#import "ZFPlayer.h"
#import "WBMacros.h"
#import "MoviePlayerViewController.h"


@interface WBPlayerViewController ()<WBImagePickerControllerDelegate,ZFPlayerDelegate>

@property (nonatomic, assign) WBPlayerType playerType;//播放器类型
@property (nonatomic, strong) WBImagePickerController *imagePickerController;//相册VC
@property (nonatomic, strong) UIButton *backButton;//返回按钮
@property (nonatomic, strong) UIButton *photoAblumButton;//打开相册按钮

@property (nonatomic,strong) MoviePlayerViewController *movieVC;



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
    [self setSubView];
    [self setupImagePickerController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void)setPlayer
{
    switch (_playerType)
    {
        case WBPlayerTypeNativePlayer:
            [self setNativePlayer];
            break;
        case WBPlayerTypeIJKPlayer:
            [self setIJKPlayer];
            break;
    }
}

- (void)setNativePlayer
{
    
}


- (void)setIJKPlayer
{
    
}

- (void)setSubView
{
    //backButton
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"backLive"] forState:UIControlStateNormal];
    self.backButton.frame = CGRectMake(15*WBDeviceScale6, 25*WBDeviceScale6, 30*WBDeviceScale6, 30*WBDeviceScale6);
    [self.backButton addTarget:self action:@selector(backToParent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    
    //photoAblumButton
    self.photoAblumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.photoAblumButton setBackgroundImage:[UIImage imageNamed:@"turnCamera"] forState:UIControlStateNormal];
    self.photoAblumButton.frame = CGRectMake(WBScreenWidth - 45*WBDeviceScale6, 25*WBDeviceScale6, 30*WBDeviceScale6, 30*WBDeviceScale6);
    [self.photoAblumButton addTarget:self action:@selector(openPhotoAblum) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_photoAblumButton];
}

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
    
    [self presentViewController:_imagePickerController animated:YES completion:nil];

}

#pragma mark WBImagePickerControllerDelegate

- (void)WBImagePickerController:(WBImagePickerController *)picker didFinishPickingMediaWithArray:(NSArray<WBPickingModel *> *)array
{
    NSLog(@"选择了一组视频或者图片啦");
}

- (void)WBImagePickerController:(WBImagePickerController *)picker didFinishPickingVideoWithURL:(NSURL *)videoURL identifier:(NSString *)localIdentifier
{
    NSLog(@"选择视频啦");
}

- (void)WBImagePickerController:(WBImagePickerController *)picker didPlayingVideoWithURL:(NSURL *)videoURL identifier:(NSString *)localIdentifier
{
    NSLog(@"将要播放视频了，快快播放吧");
    self.movieVC = [[MoviePlayerViewController alloc] init];
    self.movieVC.videoURL = videoURL;
    [self.navigationController pushViewController:_movieVC animated:YES];
    
}

- (void)WBImagePickerControllerDidCancel:(WBImagePickerController *)picker
{
    NSLog(@"取消相册点选");
}

- (void)WBImagePickerController:(WBImagePickerController *)picker authorizeWithSourceType:(WBImagePickerSourceType)sourceType authorizationStatus:(WBAuthorizationStatus)status
{
    NSLog(@"授权代理");
}

- (void)backToParent
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)openPhotoAblum
{
    [self presentViewController:_imagePickerController animated:YES completion:nil];
}



@end
