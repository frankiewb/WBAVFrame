//
//  WBAlbumListController.m
//  WBImagePickerController
//
//  Created by 王博 on 2016/10/9.
//  Copyright © 2016年 王博. All rights reserved.
//

#import "WBAlbumListController.h"
#import "WBImagePickerController.h"
#import "UIViewController+WBUtils.h"
#import "UIView+WBUtils.h"
#import "WBPhotoGridController.h"
#import "WBPhotoManager.h"
#import "WBAlbumModel.h"
#import "WBPhotoConfiguration.h"
#import "WBAlbumListCell.h"

@interface WBAlbumListController ()<PHPhotoLibraryChangeObserver> {
    PHFetchResult *_colletionResult;
}
@property (strong, nonatomic) NSArray *albumModelsArray;
@end

@implementation WBAlbumListController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNavigationRightCancelButton];
    
    [self mp_initData];
    [self mp_setupViews];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

#pragma mark - Instance Methods
- (void)mp_initData {
    __weak typeof(self) weakSelf = self;
    WBPhotoConfiguration *config = [WBPhotoConfiguration defaultConfiguration];
    //读取相册信息
    [[WBPhotoManager defaultManager] loadAlbumInfoIsShowEmpty:config.isShowEmptyAlbum isDesc:config.isPhotosDesc isOnlyShowImage:config.isOnlyShowImages CompletionBlock:^(PHFetchResult *customAlbum, NSArray *albumModelArray) {
        _colletionResult = customAlbum;
        weakSelf.albumModelsArray = albumModelArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)mp_setupViews {
    self.tableView.tableFooterView = [UIView new];
    
    [WBPhotoManager checkAuthorizationStatusWithSourceType:WBImagePickerSourceTypePhoto callBack:^(WBImagePickerSourceType sourceType, WBAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status != WBAuthorizationStatusAuthorized) {
                UILabel *label = [[UILabel alloc] init];
                label.font = [UIFont systemFontOfSize:18];
                label.textColor = [UIColor blackColor];
                label.numberOfLines = 0;
                label.textAlignment = NSTextAlignmentCenter;
                NSString *name = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
                if (!name) name = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
                label.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"str_access_photo", @"WBImagePicker", @"访问相册"), name];
                label.translatesAutoresizingMaskIntoConstraints = NO;
                
                [self.view addSubview:label];
                self.tableView.scrollEnabled = NO;
                
                NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
                NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:100];
                NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kScreenWidth - 30];
                [self.view addConstraints:@[centerX, top, width]];
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
                [btn setTitle:NSLocalizedStringFromTable(@"str_setting", @"WBImagePicker", @"设置") forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:18];
                btn.translatesAutoresizingMaskIntoConstraints = NO;
                [btn addTarget:self action:@selector(mp_jumpToSettings) forControlEvents:UIControlEventTouchUpInside];
                
                [self.view addSubview:btn];
                
                NSLayoutConstraint *center1 = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
                NSLayoutConstraint *top1 = [NSLayoutConstraint constraintWithItem:btn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeBottom multiplier:1 constant:20];
                
                [self.view addConstraints:@[center1, top1]];
            }
        });
    }];
}

- (void)mp_jumpToSettings {
    //跳转到设置
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)mp_cancelButtonDidClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    WBImagePickerController *pickerCtrler = (WBImagePickerController *)self.navigationController;
    if ([pickerCtrler.WBDelegate respondsToSelector:@selector(WBImagePickerControllerDidCancel:)]) {
        [pickerCtrler.WBDelegate WBImagePickerControllerDidCancel:pickerCtrler];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumModelsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WBPhotoConfiguration *config = [WBPhotoConfiguration defaultConfiguration];
    
    WBAlbumModel *model = self.albumModelsArray[indexPath.row];
    
    if (config.isShowAlbumThumbnail) {
        WBAlbumListCell *cell = [WBAlbumListCell cellWithTableView:tableView];
        
        cell.placeholderThumbnail = self.placeholderThumbnail;
        cell.albumModel = model;
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumCellReuserIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kAlbumCellReuserIdentifier];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.text = model.albumName;
        
        if (config.isShowAlbumNumber) cell.detailTextLabel.text = [NSString stringWithFormat:@"(%zd)", model.count];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    WBPhotoConfiguration *config = [WBPhotoConfiguration defaultConfiguration];
    WBPhotoGridController *pgc = [[WBPhotoGridController alloc] initWithCollectionViewLayout:[WBPhotoGridController flowLayoutWithNumInALine:config.numsInRow]];
    pgc.album = self.albumModelsArray[indexPath.row];
    [self.navigationController pushViewController:pgc animated:YES];
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // 检测是否有资源变化
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:_colletionResult];
    if (!collectionChanges) {
        return;
    }

    [self mp_initData];
}
@end
