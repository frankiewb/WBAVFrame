//
//  WBImagePickerController.m
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/9.
//  Copyright © 2016年 王博. All rights reserved.
//

#import "WBImagePickerController.h"
#import "WBPhotoConfiguration.h"
#import "WBAlbumListController.h"
#import "WBPhotoGridController.h"
#import "UIViewController+WBUtils.h"
#import "UIView+WBUtils.h"

@interface WBImagePickerController () {
    BOOL _toolBarEnbled;
}

@property (strong, nonatomic) WBPhotoConfiguration *config;

@property (assign, nonatomic) WBImagePickerAccessType accessType;

@property (strong, nonatomic) WBAlbumListController *albumListController;
@property (strong, nonatomic) WBPhotoGridController *photoGridController;

@property (strong, nonatomic) NSMutableArray <WBAssetModel *>*pickedModels;
@property (strong, nonatomic) NSMutableArray <NSString *>*pickedModelIdentifiers;

@property (strong, nonatomic) UIButton *previewButton;
@property (strong, nonatomic) UIButton *originalImageButton;
@property (strong, nonatomic) UIButton *originalTextButton;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UILabel *pickedCountLabel;
@property (strong, nonatomic) UILabel *originalSizeLabel;

@end

@implementation WBImagePickerController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self mp_setupNavigationBar];
    [self mp_setupToolBar];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];

}

#pragma mark - Initialization Methods
- (instancetype)initWithAccessType:(WBImagePickerAccessType)accessType{
    if (self = [super init]) {
        self.accessType = accessType;
        self.albumTitle = NSLocalizedStringFromTable(@"str_photos", @"WBImagePicker", @"相册");
        [self mp_checkAuthorizationStatus];
    }
    return self;
}

- (instancetype)initWithAccessType:(WBImagePickerAccessType)accessType identifiers:(NSArray<NSString *> *)identifiers {
    if (self = [self initWithAccessType:accessType]) {
        self.pickedModelIdentifiers = [NSMutableArray arrayWithArray:identifiers];
        [self mp_addPickModelsFromPickedIdentifiers];
    }
    return self;
}

#pragma mark - Instance Methods
- (BOOL)addSelectedAsset:(WBAssetModel *)asset {
    if (self.pickedModelIdentifiers.count == self.config.maxSelectCount) {
        
        [self presentViewController:[self addAlertControllerWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"str_get_to_maximum_selected", @"WBImagePicker", @"最大选择数量提示"), self.config.maxSelectCount] actionTitle:NSLocalizedStringFromTable(@"str_i_see", @"WBImagePicker", @"我知道了")] animated:YES completion:nil];
        
        return NO;
    }
    
    //已经保存过
    if ([self containAssetModel:asset]) return YES;
    
    asset.selected = YES;
    [self.pickedModels addObject:asset];
    [self.pickedModelIdentifiers addObject:asset.identifier];
    
    [self mp_refreshToolBar];
    
    return YES;
}

- (BOOL)removeSelectedAsset:(WBAssetModel *)asset {
    if ([self.pickedModelIdentifiers containsObject:asset.identifier]) {
        asset.selected = NO;
        
        NSInteger index = [self.pickedModelIdentifiers indexOfObject:asset.identifier];
        
        [self.pickedModelIdentifiers removeObjectAtIndex:index];
        [self.pickedModels removeObjectAtIndex:index];
        
        [self mp_refreshToolBar];
        
        return YES;
    }
    return NO;
}

- (BOOL)containAssetModel:(WBAssetModel *)asset {
    return [self.pickedModelIdentifiers containsObject:asset.identifier];
}

- (NSInteger)hasSelected {
    return self.pickedModelIdentifiers.count;
}

- (BOOL)isFullImage {
    return self.originalImageButton.isSelected;
}

- (void)setFullImageOption:(BOOL)isFullImage {
    self.originalTextButton.selected = isFullImage;
    self.originalImageButton.selected = isFullImage;
    
    [self mp_refreshOriginalImageSize];
}

- (void)didFinishPicking:(BOOL)isFullImage {
    __block NSInteger photoCount = self.pickedModels.count;
    NSMutableArray *images = [NSMutableArray array];
    
    for (WBAssetModel *model in self.pickedModels) {
        WBPickingModel *pickingModel = [[WBPickingModel alloc] init];
        pickingModel.type = model.type;
        pickingModel.identifier = model.identifier;
        
        [[WBPhotoManager defaultManager] getPickingImageFromPHAsset:model.asset isFullImage:isFullImage maxImageWidth:self.config.maxImageWidth completionBlock:^(UIImage *result, NSDictionary *info, BOOL isDegraded) {
            pickingModel.image = result;
            
            if (model.type == WBAssetModelMediaTypeLivePhoto && self.config.isCallBackLivePhoto) {
                [[WBPhotoManager defaultManager] getLivePhotoFromPHAsset:model.asset completionBlock:^(PHLivePhoto *livePhoto, BOOL isDegraded) {
                    if (!isDegraded) {
                        photoCount--;
                        pickingModel.livePhoto = livePhoto;
                        [images addObject:pickingModel];
                        
                        if (!photoCount) {
                            //回调
                            if ([self.WBDelegate respondsToSelector:@selector(WBImagePickerController:didFinishPickingMediaWithArray:)]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.WBDelegate WBImagePickerController:self didFinishPickingMediaWithArray:images];
                                });
                            }
                        }
                    }
                }];
            } else {
                [images addObject:pickingModel];
                photoCount--;
                
                if (!photoCount) {
                    //回调
                    if ([self.WBDelegate respondsToSelector:@selector(WBImagePickerController:didFinishPickingMediaWithArray:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.WBDelegate WBImagePickerController:self didFinishPickingMediaWithArray:images];
                        });
                    }
                }
            }
        }];
    }
}

/**
 检查授权访问状态
 */
- (void)mp_checkAuthorizationStatus {
    [WBPhotoManager checkAuthorizationStatusWithSourceType:WBImagePickerSourceTypePhoto callBack:^(WBImagePickerSourceType sourceType, WBAuthorizationStatus status) {
        if ([self.WBDelegate respondsToSelector:@selector(WBImagePickerController:authorizeWithSourceType:authorizationStatus:)]) {
            [self.WBDelegate WBImagePickerController:self authorizeWithSourceType:WBImagePickerSourceTypePhoto authorizationStatus:status];
        }
        
        if (status == WBAuthorizationStatusAuthorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setToolbarHidden:NO animated:NO];
                
                switch (_accessType) {
                    case WBImagePickerAccessTypeAlbums: {
                        [self setViewControllers:@[self.albumListController]];
                    }
                        break;
                    case WBImagePickerAccessTypePhotosWithAlbums: {
                        [self setViewControllers:@[self.albumListController, self.photoGridController]];
                    }
                        break;
                    case WBImagePickerAccessTypePhotosWithoutAlbums: {
                        [self setViewControllers:@[self.photoGridController] animated:YES];
                    }
                        break;
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setViewControllers:@[self.albumListController]];
            });
        }
    }];
}

- (void)mp_setupNavigationBar {
    switch (self.config.themeStyle) {
        case WBImagePickerStyleLight:
            self.navigationBar.barStyle = UIBarStyleDefault;
            self.navigationBar.translucent = YES;
            break;
        case WBImagePickerStyleDark:
            self.navigationBar.barStyle = UIBarStyleBlack;
            self.navigationBar.translucent = YES;
            self.navigationBar.tintColor = [UIColor whiteColor];
            break;
    }
}

- (void)mp_setupToolBar {
    _toolBarEnbled = self.pickedModelIdentifiers.count ? YES : NO;
    [self mp_setupToolBarButtonEnbled];
    self.originalSizeLabel.text = @"";
}

- (void)mp_setupToolBarButtonEnbled {
    [self.previewButton setEnabled:_toolBarEnbled];
    [self.originalImageButton setEnabled:_toolBarEnbled];
    [self.originalTextButton setEnabled:_toolBarEnbled];
    [self.doneButton setEnabled:_toolBarEnbled];
    self.pickedCountLabel.hidden = !_toolBarEnbled;
    self.pickedCountLabel.text = [NSString stringWithFormat:@"%zi", self.pickedModelIdentifiers.count];
    
    if (_toolBarEnbled) {
        [self.originalImageButton setSelected:NO];
        [self.originalTextButton setSelected:NO];
    }
}

- (void)mp_refreshToolBar {
    if (self.pickedModelIdentifiers.count) {
        if (!_toolBarEnbled) {
            _toolBarEnbled = YES;
            [self mp_setupToolBarButtonEnbled];
        }
        self.pickedCountLabel.text = [NSString stringWithFormat:@"%zi", self.pickedModelIdentifiers.count];
        if (self.config.allowsSelectedAnimation)
            [self.pickedCountLabel addSpringAnimation];
    } else {
        _toolBarEnbled = NO;
        [self mp_setupToolBarButtonEnbled];
    }
    
    [self mp_refreshOriginalImageSize];
}

- (CGFloat)mp_calculateWidthWithString:(NSString *)string textSize:(CGFloat)textSize {
    return [string boundingRectWithSize:CGSizeMake(300, 44) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:textSize]} context:nil].size.width;
}

- (void)mp_previewButtonDidClicked:(UIButton *)sender {
    sender.selected = !sender.isSelected;
}

- (void)mp_doneButtonDidClicked:(UIButton *)sender {
    sender.enabled = NO;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self didFinishPicking:_originalImageButton.isSelected];
}

- (void)mp_originalImageButtonDidClicked:(UIButton *)sender {
    BOOL selected = !sender.selected;
    self.originalTextButton.selected = selected;
    self.originalImageButton.selected = selected;
    
    [self mp_refreshOriginalImageSize];
}

- (void)mp_refreshOriginalImageSize {
    if (self.originalImageButton.isSelected && self.originalImageButton.isEnabled) {
        [[WBPhotoManager defaultManager] getImageBytesWithArray:self.pickedModels completionBlock:^(NSString *result) {
            self.originalSizeLabel.text = [NSString stringWithFormat:@"(%@)", result];
        }];
    } else {
        self.originalSizeLabel.text = @"";
    }
}

//根据传进来的 identifers 封装 WBAssetModel
- (void)mp_addPickModelsFromPickedIdentifiers {
    for (int i = 0; i < self.pickedModelIdentifiers.count; i++) {
        [self.pickedModels addObject:[[WBPhotoManager defaultManager] getWBAssetModelWithIdentifier:self.pickedModelIdentifiers[i]]];
    }
}

#pragma mark - Lazy Load
- (WBPhotoConfiguration *)config {
    if (!_config) {
        self.config = [WBPhotoConfiguration defaultConfiguration];
    }
    return _config;
}

- (WBAlbumListController *)albumListController{
    if (!_albumListController) {
        self.albumListController = [[WBAlbumListController alloc] init];
    }
    return _albumListController;
}

- (WBPhotoGridController *)photoGridController{
    if (!_photoGridController) {
        self.photoGridController = [[WBPhotoGridController alloc] initWithCollectionViewLayout:[WBPhotoGridController flowLayoutWithNumInALine:self.config.numsInRow]];
        [[WBPhotoManager alloc] loadCameraRollInfoisDesc:self.config.isPhotosDesc isShowEmpty:self.config.isShowEmptyAlbum isOnlyShowImage:self.config.isOnlyShowImages CompletionBlock:^(WBAlbumModel *result) {
            _photoGridController.album = result;
        }];
    }
    return _photoGridController;
}

- (NSMutableArray *)pickedModels {
    if (!_pickedModels) {
        self.pickedModels = [NSMutableArray array];
    }
    return _pickedModels;
}

- (NSMutableArray<NSString *> *)pickedModelIdentifiers {
    if (!_pickedModelIdentifiers) {
        self.pickedModelIdentifiers = [NSMutableArray array];
    }
    return _pickedModelIdentifiers;
}

- (UIButton *)previewButton {
    if (!_previewButton) {
        NSString *string = NSLocalizedStringFromTable(@"str_preview", @"WBImagePicker", @"预览");

        self.previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _previewButton.frame = CGRectMake(0, 0, [self mp_calculateWidthWithString:string textSize:17] + 20, 44);
        [_previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

        _previewButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_previewButton setTitle:string forState:UIControlStateNormal];

        [_previewButton addTarget:self action:@selector(mp_previewButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.toolbar addSubview:_previewButton];
    }
    return _previewButton;
}

- (UIButton *)originalImageButton {
    if (!_originalImageButton) {
        self.originalImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalImageButton.frame = CGRectMake(self.previewButton.WB_right, 5, 34, 34);
        [_originalImageButton setImage:[UIImage imageNamed:@"icon_full_image_normal"] forState:UIControlStateNormal];
        [_originalImageButton setImage:[UIImage imageNamed:@"icon_full_image_selected"] forState:UIControlStateSelected];
        [_originalImageButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        
        [_originalImageButton addTarget:self action:@selector(mp_originalImageButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.toolbar addSubview:_originalImageButton];
    }
    return _originalImageButton;
}

- (UIButton *)originalTextButton {
    if (!_originalTextButton) {
        NSString *string = NSLocalizedStringFromTable(@"str_original", @"WBImagePicker", @"原图");
        
        self.originalTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalTextButton.frame = CGRectMake(self.originalImageButton.WB_right, 0, [self mp_calculateWidthWithString:string textSize:15], 44);
        [_originalTextButton setTitle:string forState:UIControlStateNormal];
        _originalTextButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_originalTextButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_originalTextButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        
        [_originalTextButton addTarget:self action:@selector(mp_originalImageButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];

        [self.toolbar addSubview:_originalTextButton];
    }
    return _originalTextButton;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        NSString *string = NSLocalizedStringFromTable(@"str_done", @"WBImagePicker", @"完成");
        
        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.frame = CGRectMake(self.toolbar.WB_width-[self mp_calculateWidthWithString:string textSize:17]-20, 0, [self mp_calculateWidthWithString:string textSize:17] + 20, 44);
        [_doneButton setTitle:string forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor colorWithRed:0.65 green:0.82 blue:0.88 alpha:1.00] forState:UIControlStateDisabled];
        [_doneButton setTitleColor:[UIColor colorWithRed:0.36 green:0.79 blue:0.96 alpha:1.00] forState:UIControlStateNormal];
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:17];
        
        [_doneButton addTarget:self action:@selector(mp_doneButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.toolbar addSubview:_doneButton];
    }
    return _doneButton;
}

- (UILabel *)pickedCountLabel {
    if (!_pickedCountLabel) {
        self.pickedCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.doneButton.WB_left - 28, 8, 28, 28)];
        _pickedCountLabel.textColor = [UIColor whiteColor];
        _pickedCountLabel.font = [UIFont systemFontOfSize:15];
        _pickedCountLabel.backgroundColor = [UIColor colorWithRed:0.36 green:0.79 blue:0.96 alpha:1.00];
        _pickedCountLabel.textAlignment = NSTextAlignmentCenter;
        [_pickedCountLabel WB_cornerRadius:14];
        
        [self.toolbar addSubview:_pickedCountLabel];
    }
    return _pickedCountLabel;
}

- (UILabel *)originalSizeLabel {
    if (!_originalSizeLabel) {
        self.originalSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.originalTextButton.WB_right, 0, 80, 44)];
        _originalSizeLabel.font = [UIFont systemFontOfSize:13];
        _originalSizeLabel.textColor = [UIColor blackColor];
        
        [self.toolbar addSubview:_originalSizeLabel];
    }
    return _originalSizeLabel;
}

#pragma mark - Setter
- (void)setMutiSelected:(BOOL)mutiSelected {
    self.config.mutiSelected = mutiSelected;
    
    if (!mutiSelected) self.config.maxSelectCount = 1;
}

- (void)setMaxSelectCount:(int)maxSelectCount {
    if (!self.config.allowsMutiSelected) maxSelectCount = 1;
    
    self.config.maxSelectCount = maxSelectCount;
}

- (void)setMaxImageWidth:(CGFloat)maxImageWidth {
    if (maxImageWidth < 720) maxImageWidth = 720;
    self.config.maxImageWidth = maxImageWidth;
}

- (void)setNumsInRow:(int)numsInRow {
    self.config.numsInRow = numsInRow;
}

- (void)setMasking:(BOOL)masking {
    self.config.masking = masking;
}

- (void)setSelectedAnimation:(BOOL)selectedAnimation {
    self.config.selectedAnimation = selectedAnimation;
}

- (void)setThemeStyle:(WBImagePickerStyle)themeStyle {
    self.config.themeStyle = themeStyle;
}

- (void)setPhotoMomentGroupType:(WBImageMomentGroupType)photoMomentGroupType {
    self.config.photoMomentGroupType = photoMomentGroupType;
}

- (void)setPhotosDesc:(BOOL)photosDesc {
    self.config.photosDesc = photosDesc;
}

- (void)setShowAlbumThumbnail:(BOOL)showAlbumThumbnail {
    self.config.showAlbumThumbnail = showAlbumThumbnail;
}

- (void)setShowAlbumNumber:(BOOL)showAlbumNumber {
    self.config.showAlbumNumber = showAlbumNumber;
}

- (void)setShowEmptyAlbum:(BOOL)showEmptyAlbum {
    self.config.showEmptyAlbum = showEmptyAlbum;
}

- (void)setOnlyShowImages:(BOOL)onlyShowImages {
    self.config.onlyShowImages = onlyShowImages;
}

- (void)setShowLivePhotoIcon:(BOOL)showLivePhotoIcon {
    self.config.showLivePhotoIcon = showLivePhotoIcon;
}

- (void)setCallBackLivePhoto:(BOOL)callBackLivePhoto {
    self.config.callBackLivePhoto = callBackLivePhoto;
    
    if (!callBackLivePhoto)
        self.config.showLivePhotoIcon = NO;
}

- (void)setFirstCamera:(BOOL)firstCamera {
    self.config.firstCamera = firstCamera;
}

- (void)setDynamicCamera:(BOOL)dynamicCamera {
    self.config.dynamicCamera = dynamicCamera;
}

- (void)setMakingVideo:(BOOL)makingVideo {
    self.config.makingVideo = makingVideo;
}

- (void)setVideoAutoSave:(BOOL)videoAutoSave {
    self.config.videoAutoSave = videoAutoSave;
}

- (void)setPickGIF:(BOOL)pickGIF {
    self.config.pickGIF = pickGIF;
}

- (void)setVideoMaximumDuration:(NSTimeInterval)videoMaximumDuration {
    self.config.videoMaximumDuration = videoMaximumDuration;
}

- (void)setCustomAlbumName:(NSString *)customAlbumName {
    self.config.customAlbumName = customAlbumName;
}

- (void)setAlbumTitle:(NSString *)albumTitle {
    self.albumListController.title = albumTitle;
}

- (void)setAlbumPlaceholderThumbnail:(UIImage *)albumPlaceholderThumbnail {
    self.albumListController.placeholderThumbnail = albumPlaceholderThumbnail;
}

- (void)setPhotoNormal:(UIImage *)photoNormal {
    self.config.photoNormal = photoNormal;
}

- (void)setPhotoSelected:(UIImage *)photoSelected {
    self.config.photoSelected = photoSelected;
}

- (void)setCameraImage:(UIImage *)cameraImage {
    self.config.cameraImage = cameraImage;
}

@end




















