//
//  WBImagePickerController.h
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/9.
//  Copyright © 2016年 王博. All rights reserved.
//

#import <Photos/Photos.h>
#import "WBPhotoManagerEnumeration.h"
#import "WBPhotoManager.h"
#import "WBAlbumModel.h"
#import "WBPickingModel.h"

@protocol WBImagePickerControllerDelegate;

@interface WBImagePickerController : UINavigationController

/**
 是否多选，默认为 YES
 */
@property (assign, nonatomic, getter=allowsMutiSelected) BOOL mutiSelected;

/**
 最大选择个数，只在多选(allowsMutiSelected)为 YES 时可用，默认为 9
 */
@property (assign, nonatomic) int maxSelectCount;

/**
 获取的图片最大宽度，当选定『原图』时，该值无效。
 该值最小为 720，默认为 828
 */
@property (assign, nonatomic) CGFloat maxImageWidth;

/**
 一行显示多少个，默认为 4
 */
@property (assign, nonatomic) int numsInRow;

/**
 是否有蒙版，默认为 YES
 */
@property (assign, nonatomic, getter=allowsMasking) BOOL masking;

/**
 是否有选中动画，默认为 YES
 */
@property (assign, nonatomic, getter=allowsSelectedAnimation) BOOL selectedAnimation;

/**
 显示类型，默认为 light
 */
@property (assign, nonatomic) WBImagePickerStyle themeStyle;

/**
 图片分组类型，默认为 WBImageGroupTypeNone
 */
@property (assign, nonatomic) WBImageMomentGroupType photoMomentGroupType;

/**
 图片是否为降序排列，默认为 YES
 */
@property (assign, nonatomic, getter=isPhotosDesc) BOOL photosDesc;

/**
 是否显示相册缩略图，默认为 YES
 */
@property (assign, nonatomic, getter=isShowAlbumThumbnail) BOOL showAlbumThumbnail;

/**
 是否显示相册包含图片个数，默认为 YES
 */
@property (assign, nonatomic, getter=isShowAlbumNumber) BOOL showAlbumNumber;

/**
 是否显示空相册，默认为 NO
 */
@property (assign, nonatomic, getter=isShowEmptyAlbum) BOOL showEmptyAlbum;

/**
 是否只显示图片，默认为 NO
 */
@property (assign, nonatomic, getter=isOnlyShowImages) BOOL onlyShowImages;

/**
 是否显示 Live Photo 图标，默认为 YES
 */
@property (assign, nonatomic, getter=isShowLivePhotoIcon) BOOL showLivePhotoIcon;

/**
 是否返回 Live Photo, 默认为 YES
 当值为 NO 时, "showLivePhotoIcon" 失效且为NO
 */
@property (assign, nonatomic, getter=isCallBackLivePhoto) BOOL callBackLivePhoto;

/**
 第一个图标是否为相机，默认为 YES
 */
@property (assign, nonatomic, getter=isFirstCamera) BOOL firstCamera;

/**
 缩略图界面相机 cell 是否为动态, 默认为 NO
 仅当 "isFirstCamera" 为 YES 时生效
 当该属性生效时，界面会出现卡顿
 */
@property (assign, nonatomic, getter=isDynamicCamera) BOOL dynamicCamera;

/**
 是否可以录制视频，默认为 YES
 */
@property (assign, nonatomic, getter=allowsMakingVideo) BOOL makingVideo;

/**
 视频录制后，是否自动保存到系统相册，默认为 YES。
 当有自定义相册名称 "customAlbumName" 时，保存到该相册。
 仅当 "allowsMakingVideo" 为 YES 时生效。
 */
@property (assign, nonatomic, getter=isVideoAutoSave) BOOL videoAutoSave;

/**
 允许选择动图，默认为 YES
 */
@property (assign, nonatomic, getter=allowsPickGIF) BOOL pickGIF;

/**
 只有当 allowsMakingVideo 为 true 时可用，默认为 60
 */
@property (assign, nonatomic) NSTimeInterval videoMaximumDuration;

/**
 自定义相册名称，为空时保存到系统相册。不为空时，系统中没有该相册，则创建。
 */
@property (copy, nonatomic) NSString * _Nullable customAlbumName;

/**
 照片选择时，未选择时图片
 */
@property (strong, nonatomic) UIImage *  _Nullable photoNormal;

/**
 照片选择时，已选择时图片
 */
@property (strong, nonatomic) UIImage * _Nullable photoSelected;

/**
 WBPhotoGridController 中，camera cell显示图片
 */
@property (strong, nonatomic) UIImage * _Nullable cameraImage;


@property (weak, nonatomic, nullable) id <WBImagePickerControllerDelegate> WBDelegate;


/**
 构造器
 
 @param accessType  根据需要确定构造方法
 
 @return            实例
 */
- (instancetype _Nullable )initWithAccessType:(WBImagePickerAccessType)accessType;

/**
 构造器

 @param accessType  根据需要确定构造方法
 @param identifiers 已经选中过的图片的 identifier
 @return            实例
 */
- (instancetype _Nullable )initWithAccessType:(WBImagePickerAccessType)accessType identifiers:(NSArray <NSString *>*_Nullable)identifiers;



/**
 添加选中

 @param asset 选中的 asset

 @return 是否添加成功
 */
- (BOOL)addSelectedAsset:(WBAssetModel *_Nullable)asset;

/**
 移除选中

 @param asset 选中的 asset
 
 @return 是否移除成功
 */
- (BOOL)removeSelectedAsset:(WBAssetModel *_Nullable)asset;

/**
 选中图片中是否包含该 model

 @param asset 需判断的 asset
 @return 是否选中
 */
- (BOOL)containAssetModel:(WBAssetModel *_Nullable)asset;

/**
 已经选中了几张图片

 @return 选中数量
 */
- (NSInteger)hasSelected;

/**
 是否选中的是原图
 */
- (BOOL)isFullImage;

/**
 设置是否是原图
 */
- (void)setFullImageOption:(BOOL)isFullImage;

/**
 选完图片
 */
- (void)didFinishPicking:(BOOL)isFullImage;

@end

@protocol WBImagePickerControllerDelegate <NSObject>
@optional

- (void)WBImagePickerController:(nonnull WBImagePickerController *)picker didFinishPickingMediaWithArray:(nonnull NSArray <WBPickingModel *>*)array;
- (void)WBImagePickerController:(nonnull WBImagePickerController *)picker didFinishPickingVideoWithURL:(nonnull NSURL *)videoURL identifier:(nullable NSString *)localIdentifier;

- (void)WBImagePickerControllerDidCancel:(nonnull WBImagePickerController *)picker;

- (void)WBImagePickerController:(nonnull WBImagePickerController *)picker authorizeWithSourceType:(WBImagePickerSourceType)sourceType authorizationStatus:(WBAuthorizationStatus)status;

@end


