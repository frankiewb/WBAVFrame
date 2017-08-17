//
//  WBPhotoManager.h
//  WBUtils
//
//  Created by 王博 on 2017/8/16.
//  Copyright © 2017年 王博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "WBPhotoManagerEnumeration.h"


@class WBAlbumModel,WBMoment,WBAssetModel;
@interface WBPhotoManager : NSObject

/** 单例 */
+ (instancetype)defaultManager;

/**
 检查 app 授权
 
 @param type 授权类型
 @param callBackBlock 回调
 */
+ (void)checkAuthorizationStatusWithSourceType:(WBImagePickerSourceType)type callBack:(void(^)(WBImagePickerSourceType sourceType, WBAuthorizationStatus status)) callBackBlock;

/**
 读取『相机胶卷』的信息
 
 @param isDesc          是否为倒序
 @param isShowEmpty     是否显示为空的情况
 @param isOnlyShowImage 是否只显示图片
 @param completionBlock 返回数组<WBAlbumModel>
 */
- (void)loadCameraRollInfoisDesc:(BOOL)isDesc isShowEmpty:(BOOL)isShowEmpty isOnlyShowImage:(BOOL)isOnlyShowImage CompletionBlock:(void (^)(WBAlbumModel *result))completionBlock;

/**
 读取所有相册的信息
 
 @param isShowEmpty     是否显示空相册
 @param isDesc          是否为倒序
 @param isOnlyShowImage 是否只显示图片
 @param completionBlock 返回数组<WBAlbumModel>
 */
- (void)loadAlbumInfoIsShowEmpty:(BOOL)isShowEmpty isDesc:(BOOL)isDesc isOnlyShowImage:(BOOL)isOnlyShowImage CompletionBlock:(void(^)(PHFetchResult *customAlbum, NSArray *albumModelArray)) completionBlock;

/**
 保存图片到系统相册
 
 @param image           待保存图片
 @param completionBlock 回调
 */
- (void)saveImageToSystemAlbumWithImage:(UIImage *)image completionBlock:(void(^)(PHAsset *asset, NSString *error))completionBlock;

/**
 保存图片的到自定义相册，没有则创建
 
 @param image           待保存图片
 @param albumName       自定义相册名称
 @param completionBlock 回调
 */
- (void)saveImageToCustomAlbumWithImage:(UIImage *)image albumName:(NSString *)albumName completionBlock:(void(^)(PHAsset *asset, NSString *error))completionBlock;

/**
 保存视频到系统相册
 
 @param url             视频 url
 @param completionBlock 回调
 */
- (void)saveVideoToSystemAlbumWithURL:(NSURL *)url completionBlock:(void(^)(PHAsset *asset, NSString *error))completionBlock;

/**
 保存视频到自定义相册，没有则创建
 
 @param url             视频 url
 @param albumName       自定义相册名称
 @param completionBlock 回调
 */
- (void)saveVideoToCustomAlbumWithURL:(NSURL *)url albumName:(NSString *)albumName completionBlcok:(void(^)(PHAsset *asset, NSString *error))completionBlock;

/**
 根据时间分组排序
 
 @param momentType  分组类型
 @param models 传入数据
 
 @return 分组结果
 */
- (NSArray<WBMoment *> *)sortByMomentType:(WBImageMomentGroupType)momentType assets:(NSArray <WBAssetModel *>*)models;


/**
 根据 identifier 得到 WBAssetModel
 
 @param identifier      标识符
 */
- (WBAssetModel *)getWBAssetModelWithIdentifier:(NSString *)identifier;

/**
 根据相册封装 assetModel
 
 @param fetchResult     相册信息
 @param completionBlock 回调
 */
- (void)getWBAssetModelWithPHFetchResult:(PHFetchResult *)fetchResult completionBlock:(void(^)(NSArray <WBAssetModel *>*models))completionBlock;

/**
 读取缩略图
 
 @param asset           图片内容
 @param width           图片宽度，宽高比为 1:1，scale 默认为 2.0
 @param completionBlock 回调
 */
- (void)getThumbnailImageFromPHAsset:(PHAsset *)asset photoWidth:(CGFloat)width completionBlock:(void(^)(UIImage *result, NSDictionary *info))completionBlock;

/**
 读取预览图片，宽度默认为屏幕宽度
 
 @param asset           图片内容
 @param isHighQuality   是否是高质量，为 YES 时，scale 为设备屏幕的 scale， NO 时 scale 为 0.1
 @param completionBlock 回调
 */
- (void)getPreviewImageFromPHAsset:(PHAsset *)asset isHighQuality:(BOOL)isHighQuality completionBlock:(void(^)(UIImage *result, NSDictionary *info, BOOL isDegraded))completionBlock;

/**
 读取 Live Photo
 
 @param asset           live photo 内容
 @param completionBlock 回调
 */
- (void)getLivePhotoFromPHAsset:(PHAsset *)asset completionBlock:(void(^)(PHLivePhoto *livePhoto, BOOL isDegraded))completionBlock;

/**
 读取选定照片
 
 @param asset           图片内容
 @param isFullImage     是否为原图
 @param width           最大图片宽度，isFullImage 为 NO 时生效
 @param completionBlock 回调
 */
- (void)getPickingImageFromPHAsset:(PHAsset *)asset isFullImage:(BOOL)isFullImage maxImageWidth:(CGFloat)width completionBlock:(void(^)(UIImage *result, NSDictionary *info, BOOL isDegraded))completionBlock;

/**
 读取视频
 
 @param asset 视频内容
 @param completionBlock 回调
 */
- (void)getAVPlayerItemFromPHAsset:(PHAsset *)asset completionBlock:(void(^)(AVPlayerItem *item))completionBlock;


/**
 获取图片的大小
 
 @param models 图片内容
 @param completionBlock 回调
 */
- (void)getImageBytesWithArray:(NSArray <WBAssetModel *>*)models completionBlock:(void(^)(NSString *result))completionBlock;



@end
