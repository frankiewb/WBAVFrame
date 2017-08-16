//
//  WBPhotoManager.m
//  WBUtils
//
//  Created by 王博 on 2017/8/16.
//  Copyright © 2017年 王博. All rights reserved.
//

#import "WBPhotoManager.h"

@interface WBPhotoManager ()

@property (strong, nonatomic) PHImageManager *imageManager;

@end

@implementation WBPhotoManager

+ (instancetype)defaultManager {
    static WBPhotoManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WBPhotoManager alloc] init];
    });
    
    return instance;
}

+ (void)checkAuthorizationStatusWithSourceType:(WBImagePickerSourceType)type callBack:(void (^)(WBImagePickerSourceType, WBAuthorizationStatus))callBackBlock {
    switch (type) {
        case WBImagePickerSourceTypePhoto: {
            if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
                
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    callBackBlock ? callBackBlock(type, (WBAuthorizationStatus)status) : nil;
                }];
            } else {
                callBackBlock ? callBackBlock(type, WBAuthorizationStatusAuthorized) : nil;
            }
        }
            break;
        case WBImagePickerSourceTypeSound: {
            
        }
            break;
        case WBImagePickerSourceTypeCamera: {
            
        }
            break;
    }
}

#pragma mark - Load
- (void)loadCameraRollInfoisDesc:(BOOL)isDesc isShowEmpty:(BOOL)isShowEmpty isOnlyShowImage:(BOOL)isOnlyShowImage CompletionBlock:(void (^)(WBAlbumModel *))completionBlock {
    PHFetchResult *albumCollection= [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    
    [albumCollection enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:!isDesc]];
        if (isOnlyShowImage) {
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
        }
        
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:obj options:fetchOptions];
        
        WBAlbumModel *model = nil;
        
        if (result.count > 0 || isShowEmpty) {
            model = [WBAlbumModel new];
            model.isCameraRoll = YES;
            model.albumName = obj.localizedTitle;//相册名
            model.content = result;//保存这个相册的内容
        }
        
        completionBlock ? completionBlock(model) : nil;
    }];
}

- (void)loadAlbumInfoIsShowEmpty:(BOOL)isShowEmpty isDesc:(BOOL)isDesc isOnlyShowImage:(BOOL)isOnlyShowImage CompletionBlock:(void (^)(PHFetchResult *, NSArray *))completionBlock {
    //用来存放每个相册的model
    NSMutableArray *albumModelsArray = [NSMutableArray array];
    
    //创建读取相册信息的options
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:!isDesc]];
    if (isOnlyShowImage) {
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d",PHAssetMediaTypeImage];
    }
    
    [self loadCameraRollInfoisDesc:isDesc isShowEmpty:isShowEmpty isOnlyShowImage:isOnlyShowImage CompletionBlock:^(WBAlbumModel *result) {
        [albumModelsArray addObject:result];
    }];
    
    PHFetchResult *albumsCollection2 = [PHAssetCollection fetchTopLevelUserCollectionsWithOptions:nil];
    
    [albumsCollection2 enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHFetchResult *assetsResult = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
        
        if (assetsResult.count > 0 || isShowEmpty) {
            WBAlbumModel *model = [WBAlbumModel new];
            model.isCameraRoll = NO;
            model.albumName = collection.localizedTitle;
            model.content = assetsResult;
            
            [albumModelsArray addObject:model];
        }
        
    }];
    
    //回调
    completionBlock ? completionBlock(albumsCollection2, albumModelsArray) : nil;
}

#pragma mark - Save
- (void)saveImageToSystemAlbumWithImage:(UIImage *)image completionBlock:(void (^)(PHAsset *, NSString *))completionBlock {
    __block NSString *createdAssetID = nil;
    
    // 保存图片
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        //获取保存到系统相册成功后的 asset
        PHAsset *creatAsset = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil].firstObject;
        
        //回调
        completionBlock ? completionBlock(creatAsset, error.description) : nil;
    }];
}

- (void)saveImageToCustomAlbumWithImage:(UIImage *)image albumName:(NSString *)albumName completionBlock:(void (^)(PHAsset *, NSString *))completionBlock {
    //先保存到系统相册中
    __weak typeof(self) weakSelf = self;
    [self saveImageToSystemAlbumWithImage:image completionBlock:^(PHAsset *asset, NSString *error) {
        //非空判断
        if (asset) {
            PHAssetCollection *collection = [weakSelf mp_getAssetCollectionWithCustomAlbumName:albumName];
            
            if (!collection) return ;
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                [request addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                completionBlock ? completionBlock(asset, error.description) : nil;
            }];
        }
    }];
}

- (void)saveVideoToSystemAlbumWithURL:(NSURL *)url completionBlock:(void (^)(PHAsset *, NSString *))completionBlock {
    __block NSString *createdAssetID = nil;
    
    // 保存图片
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url].placeholderForCreatedAsset.localIdentifier;
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        //获取保存到系统相册成功后的 asset
        PHAsset *creatAsset = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil].firstObject;
        
        //回调
        completionBlock ? completionBlock(creatAsset, error.description) : nil;
    }];
}

- (void)saveVideoToCustomAlbumWithURL:(NSURL *)url albumName:(NSString *)albumName completionBlcok:(void (^)(PHAsset *, NSString *))completionBlock {
    __weak typeof(self) weakSelf = self;
    [self saveVideoToSystemAlbumWithURL:url completionBlock:^(PHAsset *asset, NSString *error) {
        if (asset) {
            PHAssetCollection *collection = [weakSelf mp_getAssetCollectionWithCustomAlbumName:albumName];
            
            if (!collection) return ;
            
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                [request addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                completionBlock ? completionBlock(asset, error.description) : nil;
            }];
        }
    }];
}

- (PHAssetCollection *)mp_getAssetCollectionWithCustomAlbumName:(NSString *)customName {
    //获取所有相册
    PHFetchResult *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    //遍历
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:customName]) {
            return collection;
        }
    }
    
    //创建
    NSError *error = nil;
    __block NSString * createId = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:customName];
        createId = request.placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    
    if (error) {
        //创建失败
        NSLog(@"Fail to create the custom album.");
        return nil;
    } else {
        //创建成功
        return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createId] options:nil].firstObject;
    }
}

- (NSArray<WBMoment *> *)sortByMomentType:(WBImageMomentGroupType)momentType assets:(NSArray *)models {
    WBMoment *newMoment = nil;
    
    NSMutableArray *groups = [NSMutableArray array];
    
    for (NSInteger i = 0; i < models.count; i++) {
        WBAssetModel *asset = models[i];
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:asset.asset.creationDate];
        
        NSUInteger year = components.year;
        NSUInteger month = components.month;
        NSUInteger day = components.day;
        
        switch (momentType) {
            case WBImageMomentGroupTypeYear:
                if (newMoment && newMoment.dateComponents.year == year) break;
            case WBImageMomentGroupTypeMonth:
                if (newMoment && newMoment.dateComponents.year == year && newMoment.dateComponents.month == month) break;
            case WBImageMomentGroupTypeDay:
                if (newMoment && newMoment.dateComponents.year == year && newMoment.dateComponents.month == month && newMoment.dateComponents.day == day) break;
            default:
                newMoment = [WBMoment new];
                newMoment.dateComponents = components;
                newMoment.date = asset.asset.creationDate;
                [groups addObject:newMoment];
                break;
        }
        [newMoment.assets addObject:asset];
    }
    return groups;
}

#pragma mark - Get
- (WBAssetModel *)getWBAssetModelWithIdentifier:(NSString *)identifier {
    PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:nil].firstObject;
    WBAssetModel *model = [WBAssetModel modelWithAsset:asset];
    
    return model;
}

- (void)getWBAssetModelWithPHFetchResult:(PHFetchResult *)fetchResult completionBlock:(void (^)(NSArray<WBAssetModel *> *))completionBlock {
    NSMutableArray *modelsArray = [NSMutableArray arrayWithCapacity:fetchResult.count];
    [fetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        WBAssetModel *model = [WBAssetModel modelWithAsset:asset];
        
        [modelsArray addObject:model];
    }];
    completionBlock ? completionBlock(modelsArray) : nil;
}

- (void)getThumbnailImageFromPHAsset:(PHAsset *)asset photoWidth:(CGFloat)width completionBlock:(void (^)(UIImage *, NSDictionary *))completionBlock {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.synchronous = NO;
    
    [self mp_getImageFromPHAsset:asset imageSize:CGSizeMake(width * 2.f, width * 2.f) options:options isFixOrientation:NO completionBlock:^(UIImage *result, NSDictionary *info) {
        completionBlock ? completionBlock(result, info) : nil;
    }];
}

- (void)getPreviewImageFromPHAsset:(PHAsset *)asset isHighQuality:(BOOL)isHighQuality completionBlock:(void (^)(UIImage *, NSDictionary *, BOOL))completionBlock {
    CGFloat scale = isHighQuality ? [UIScreen mainScreen].scale : .1f;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat pixelWidth = width * scale;
    CGFloat pixelHeight = width / aspectRatio;
    CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = isHighQuality ? PHImageRequestOptionsDeliveryModeHighQualityFormat : PHImageRequestOptionsDeliveryModeFastFormat;
    options.synchronous = NO;
    
    [self mp_getImageFromPHAsset:asset imageSize:imageSize options:options isFixOrientation:YES completionBlock:^(UIImage *result, NSDictionary *info) {
        completionBlock ? completionBlock(result, info, [info[PHImageResultIsDegradedKey] boolValue]) : nil;
    }];
}

- (void)mp_getImageFromPHAsset:(PHAsset *)asset imageSize:(CGSize)imageSize options:(PHImageRequestOptions *)options isFixOrientation:(BOOL)fixOrientation completionBlock:(void(^)(UIImage *result, NSDictionary *info))completionBlock {
    [self.imageManager requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        BOOL finished = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (finished && result) {
            if (fixOrientation) result = [UIImage fixOrientation:result];
            
            //回调
            completionBlock ? completionBlock(result, info) : nil;
        }
    }];
}

- (void)getLivePhotoFromPHAsset:(PHAsset *)asset completionBlock:(void (^)(PHLivePhoto *, BOOL))completionBlock {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
    CGFloat pixelWidth = width * scale;
    CGFloat pixelHeight = width / aspectRatio;
    CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
    
    PHLivePhotoRequestOptions *options = [[PHLivePhotoRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    [self.imageManager requestLivePhotoForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        completionBlock ? completionBlock(livePhoto, [info[PHImageResultIsDegradedKey] boolValue]) : nil;
    }];
}

- (void)getPickingImageFromPHAsset:(PHAsset *)asset isFullImage:(BOOL)isFullImage maxImageWidth:(CGFloat)width completionBlock:(void (^)(UIImage *, NSDictionary *, BOOL))completionBlock {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    CGSize targetSize;
    
    if (isFullImage) {
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        
        targetSize = PHImageManagerMaximumSize;
    } else {
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        //        targetSize = PHImageManagerMaximumSize;
        if (width > asset.pixelWidth) {
            targetSize = PHImageManagerMaximumSize;
        } else {
            CGFloat scale = [UIScreen mainScreen].scale;
            CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
            CGFloat pixelWidth = width * scale;
            CGFloat pixelHeight = width / aspectRatio;
            targetSize = CGSizeMake(pixelWidth, pixelHeight);
        }
    }
    
    [self.imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        result = [UIImage fixOrientation:result];
        if (!isFullImage) {
            result = [result scaleImageWithMaxWidth:width];
        }
        
        NSData *data = UIImageJPEGRepresentation(result, .45);
        result = [UIImage imageWithData:data];
        
        completionBlock ? completionBlock(result, info, [info[PHImageResultIsDegradedKey] boolValue]) : nil;
    }];
}

- (void)getAVPlayerItemFromPHAsset:(PHAsset *)asset completionBlock:(void (^)(AVPlayerItem *))completionBlock {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = NO;
    options.version = PHVideoRequestOptionsVersionOriginal;
    
    [self.imageManager requestPlayerItemForVideo:asset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        completionBlock ? completionBlock(playerItem) : nil;
    }];
}

- (void)getImageBytesWithArray:(NSArray<WBAssetModel *> *)models completionBlock:(void (^)(NSString *))completionBlock {
    __block NSUInteger dataLength = 0;
    __block NSUInteger count = models.count;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeNone;
    options.synchronous = YES;
    
    for (WBAssetModel *model in models) {
        [self.imageManager requestImageDataForAsset:model.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            count--;
            dataLength += imageData.length;
            if (count <= 0) {
                completionBlock ? completionBlock([NSByteCountFormatter stringFromByteCount:dataLength countStyle:NSByteCountFormatterCountStyleFile]) : nil;
            }
        }];
    }
}

#pragma mark - Lazy Load
- (PHImageManager *)imageManager {
    if (!_imageManager) {
        self.imageManager = [PHImageManager defaultManager];
    }
    return _imageManager;
}


@end
