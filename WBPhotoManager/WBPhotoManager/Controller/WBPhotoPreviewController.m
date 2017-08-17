//
//  WBPhotoPreviewController.m
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/19.
//  Copyright © 2016年 王博. All rights reserved.
//

#import "WBPhotoPreviewController.h"
#import "WBAlbumModel.h"
#import "WBMoment.h"
#import "UIView+WBUtils.h"
#import "WBPhotoPreviewImageCell.h"
#import "WBImagePickerController.h"
#import "WBPhotoConfiguration.h"
#import "WBPhotoManager.h"

@interface WBPhotoPreviewController ()<UICollectionViewDelegate, UICollectionViewDataSource, WBPhotoPreviewCellDelegate> {
    WBAlbumModel *_albumModel;
    WBMoment *_moment;
    NSInteger _currentItem;
    
    WBImagePickerStyle _pickerStyle;
    BOOL _isShowAnimation;
    
    BOOL _isShowBars;
}

@property (strong, nonatomic) UICollectionView *myCollectionView;

@property (strong, nonatomic) UIView *customNavigationBar;
@property (strong, nonatomic) UIView *customToolBar;

@property (strong, nonatomic) UIButton *selectedButton;
@property (strong, nonatomic) UIButton *originalImageButton;
@property (strong, nonatomic) UIButton *originalTextButton;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UILabel *pickedCountLabel;
@property (strong, nonatomic) UILabel *originalSizeLabel;

@end

@implementation WBPhotoPreviewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self mp_setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    WBPhotoPreviewImageCell *cell = (WBPhotoPreviewImageCell *)[_myCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentItem inSection:0]];
    [cell didDisplayed];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    if ([self.delegate respondsToSelector:@selector(photoPreviewDisappearIsFullImage:)]) [self.delegate photoPreviewDisappearIsFullImage:self.originalImageButton.isSelected];
}

#pragma mark - Instance Methods
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didSelectedWithAlbum:(WBAlbumModel *)album item:(NSInteger)item {
    _albumModel = album;
    _currentItem = item;
}

- (void)mp_setupSubviews {
    _isShowBars = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.myCollectionView.contentOffset = CGPointMake(0, 0);
    [self.myCollectionView setContentSize:CGSizeMake((self.view.WB_width + 20)*5, self.view.WB_height)];

    [self.myCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentItem inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    WBPhotoConfiguration *config = [WBPhotoConfiguration defaultConfiguration];
    _pickerStyle = config.themeStyle;
    _isShowAnimation = config.allowsSelectedAnimation;
    switch (_pickerStyle) {
        case WBImagePickerStyleDark:
            self.myCollectionView.backgroundColor = [UIColor blackColor];
            break;
        case WBImagePickerStyleLight:
            self.myCollectionView.backgroundColor = kLightStyleBGColor;
            break;
        default:
            break;
    }
    
    [self mp_setupCustomNavigationBar];
    [self mp_setupCustomToolBar];
    
    [self mp_refreshCustomBars];
}

- (void)mp_setupCustomNavigationBar {
    self.customNavigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 64, 64);
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(22, 22, 22, 22)];
    [backButton addTarget:self action:@selector(mp_backButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    
    switch (_pickerStyle) {
        case WBImagePickerStyleLight:
            _customNavigationBar.backgroundColor = [UIColor colorWithWhite:1 alpha:.85];
            [backButton setImage:[UIImage imageNamed:@"icon_preview_back_light"] forState:UIControlStateNormal];
            [self.selectedButton setImage:[UIImage imageNamed:@"icon_preview_normal_light"] forState:UIControlStateNormal];
            [self.selectedButton setImage:[UIImage imageNamed:@"icon_picture_selected"] forState:UIControlStateSelected];
            break;
        case WBImagePickerStyleDark:
            _customNavigationBar.backgroundColor = [UIColor colorWithWhite:0 alpha:.7];
            [backButton setImage:[UIImage imageNamed:@"icon_preview_back_dark"] forState:UIControlStateNormal];
            [self.selectedButton setImage:[UIImage imageNamed:@"icon_picture_normal"] forState:UIControlStateNormal];
            [self.selectedButton setImage:[UIImage imageNamed:@"icon_picture_selected"] forState:UIControlStateSelected];
            break;
    }
    
    [self.view addSubview:_customNavigationBar];
    [_customNavigationBar addSubview:backButton];
    [_customNavigationBar addSubview:_selectedButton];
}

- (void)mp_setupCustomToolBar {
    self.customToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44)];
    
    switch (_pickerStyle) {
        case WBImagePickerStyleLight:
            _customToolBar.backgroundColor = [UIColor colorWithWhite:1 alpha:.7];
            [self.originalTextButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateSelected];
            [self.originalTextButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            self.originalSizeLabel.textColor = [UIColor darkTextColor];
            break;
        case WBImagePickerStyleDark:
            _customToolBar.backgroundColor = [UIColor colorWithWhite:0 alpha:.7];
            [self.originalTextButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [self.originalTextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            self.originalSizeLabel.textColor = [UIColor lightTextColor];
            break;
    }
    
    //判断是否显示原图
    WBImagePickerController *pickerCtrler = (WBImagePickerController *)self.navigationController;
    if (pickerCtrler.isFullImage) {
        self.originalImageButton.selected = YES;
        self.originalTextButton.selected = YES;
    }
    
    [self.view addSubview:_customToolBar];
    [_customToolBar addSubview:self.originalImageButton];
    [_customToolBar addSubview:self.originalTextButton];
    [_customToolBar addSubview:self.originalSizeLabel];
    [_customToolBar addSubview:self.doneButton];
    [_customToolBar addSubview:self.pickedCountLabel];
}

- (void)mp_refreshCustomBars {
    if (_isShowBars) {
        self.customToolBar.hidden = NO;
        self.customNavigationBar.hidden = NO;
        
        WBImagePickerController *pickerCtrler = (WBImagePickerController *)self.navigationController;
        WBAssetModel *currentModel = _albumModel.models[_currentItem];
        
        if ([pickerCtrler hasSelected]) {
            //有选中照片
            
            //检查是否为选中照片
            self.selectedButton.selected = [pickerCtrler containAssetModel:currentModel];
            
            self.pickedCountLabel.text = [NSString stringWithFormat:@"%zi", [pickerCtrler hasSelected]];
        }
        [self.doneButton setEnabled:[pickerCtrler hasSelected]];
        self.pickedCountLabel.hidden = ![pickerCtrler hasSelected];
        
        if (currentModel.type == WBAssetModelMediaTypeVideo) {
            //隐藏 『原图』
            self.originalTextButton.hidden = YES;
            self.originalImageButton.hidden = YES;
            self.originalSizeLabel.hidden = YES;
        } else {
            self.originalImageButton.hidden = NO;
            self.originalTextButton.hidden = NO;
            self.originalSizeLabel.hidden = NO;
            [self mp_refreshOriginalImageSize];
        }
    } else {
        self.customNavigationBar.hidden = YES;
        self.customToolBar.hidden = YES;
    }
}

- (UICollectionViewFlowLayout *)mp_flowLayout {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.itemSize = CGSizeMake(self.view.WB_width + 20, self.view.WB_height);
    
    return flowLayout;
}

- (CGFloat)mp_calculateWidthWithString:(NSString *)string textSize:(CGFloat)textSize {
    return [string boundingRectWithSize:CGSizeMake(300, 44) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:textSize]} context:nil].size.width;
}

- (void)mp_doneButtonDidClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    sender.enabled = NO;
    
    WBImagePickerController *pickerCtrler = (WBImagePickerController *)self.navigationController;
    
    [pickerCtrler didFinishPicking:self.originalImageButton.isSelected];
}

- (void)mp_originalImageButtonDidClicked:(UIButton *)sender {
    BOOL selected = !sender.selected;
    self.originalTextButton.selected = selected;
    self.originalImageButton.selected = selected;
    
    [self mp_refreshOriginalImageSize];
    
    if (!self.selectedButton.isSelected && selected) {
        [self mp_selectedButtonDidClicked:self.selectedButton];
    }
}

- (void)mp_refreshOriginalImageSize {
    if (self.originalImageButton.isSelected) {
        WBAssetModel *model = _albumModel.models[_currentItem];
        [[WBPhotoManager defaultManager] getImageBytesWithArray:@[model] completionBlock:^(NSString *result) {
            self.originalSizeLabel.text = [NSString stringWithFormat:@"(%@)", result];
        }];
    } else {
        self.originalSizeLabel.text = @"";
    }
}

- (void)mp_backButtonDidClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mp_selectedButtonDidClicked:(UIButton *)sender {
    WBImagePickerController *pickerCtrler = (WBImagePickerController *)self.navigationController;
    WBAssetModel *model = _albumModel.models[_currentItem];
    
    if (sender.isSelected) {
        //选中情况
        sender.selected = NO;
        [pickerCtrler removeSelectedAsset:model];
    } else {
        sender.selected = [pickerCtrler addSelectedAsset:model];
        
        if (sender.isSelected && _isShowAnimation) {
            [sender addSpringAnimation];
            [self.pickedCountLabel addSpringAnimation];
        }
    }
    [self mp_refreshCustomBars];
}

#pragma mark - Lazy Load
- (UICollectionView *)myCollectionView {
    if (!_myCollectionView) {
        self.myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-10, 0, self.view.WB_width + 20, self.view.WB_height) collectionViewLayout:[self mp_flowLayout]];
        _myCollectionView.pagingEnabled = YES;
        _myCollectionView.showsHorizontalScrollIndicator = NO;
        _myCollectionView.scrollsToTop = NO;
        
        _myCollectionView.dataSource = self;
        _myCollectionView.delegate = self;
        
        [self.view addSubview:_myCollectionView];
        [self.view sendSubviewToBack:_myCollectionView];
        
        [_myCollectionView registerClass:[WBPhotoPreviewImageCell class] forCellWithReuseIdentifier:@"WBPhotoPreviewImageCell"];
    }
    return _myCollectionView;
}

- (UIButton *)selectedButton {
    if (!_selectedButton) {
        self.selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedButton.frame = CGRectMake(kScreenWidth-64, 0, 64, 64);
        [_selectedButton setImageEdgeInsets:UIEdgeInsetsMake(16, 16, 16, 16)];
        [_selectedButton addTarget:self action:@selector(mp_selectedButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectedButton;
}

- (UIButton *)originalImageButton {
    if (!_originalImageButton) {
        self.originalImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalImageButton.frame = CGRectMake(10, 5, 34, 34);
        [_originalImageButton setImage:[UIImage imageNamed:@"icon_full_image_normal"] forState:UIControlStateNormal];
        [_originalImageButton setImage:[UIImage imageNamed:@"icon_full_image_selected"] forState:UIControlStateSelected];
        [_originalImageButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        
        [_originalImageButton addTarget:self action:@selector(mp_originalImageButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
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
        
        [_originalTextButton addTarget:self action:@selector(mp_originalImageButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _originalTextButton;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        NSString *string = NSLocalizedStringFromTable(@"str_done", @"WBImagePicker", @"完成");
        
        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.frame = CGRectMake(kScreenWidth-60, 0, 60, 44);
        [_doneButton setTitle:string forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor colorWithRed:0.65 green:0.82 blue:0.88 alpha:1.00] forState:UIControlStateDisabled];
        [_doneButton setTitleColor:[UIColor colorWithRed:0.36 green:0.79 blue:0.96 alpha:1.00] forState:UIControlStateNormal];
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:17];
        
        [_doneButton addTarget:self action:@selector(mp_doneButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
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
    }
    return _pickedCountLabel;
}

- (UILabel *)originalSizeLabel {
    if (!_originalSizeLabel) {
        self.originalSizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.originalTextButton.WB_right, 0, 80, 44)];
        _originalSizeLabel.font = [UIFont systemFontOfSize:13];
    }
    return _originalSizeLabel;
}

#pragma mark - UICollectionViewDataSource & Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _albumModel.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WBPhotoPreviewImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WBPhotoPreviewImageCell" forIndexPath:indexPath];
    cell.model = _albumModel.models[indexPath.item];
    cell.delegate = self;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(WBPhotoPreviewImageCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell recoverSubviews];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(WBPhotoPreviewImageCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [cell recoverSubviews];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth = offSetWidth +  ((self.view.WB_width + 20) * 0.5);
    
    NSInteger currentItem = offSetWidth / (self.view.WB_width + 20);
    
    if (_currentItem != currentItem) {
        _currentItem = currentItem;
        [self mp_refreshCustomBars];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
#warning waiting for updating 确认哪个，不想循环，虽然最多只有2个。
    for (WBPhotoPreviewImageCell *cell in _myCollectionView.visibleCells) {
        [cell didDisplayed];
    }
}

#pragma mark - WBPhotoPreviewCellDelegate
- (void)photoHasBeenTapped {
    _isShowBars = !_isShowBars;
    
    [self mp_refreshCustomBars];
}

@end
