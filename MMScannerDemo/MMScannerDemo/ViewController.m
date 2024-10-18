//
//  ViewController.m
//  MMScannerDemo
//
//  Created by LEA on 2017/11/23.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "ViewController.h"
#import "QRDetailViewController.h"
#import "BarDetailViewController.h"
#import "MMScannerController.h"
#import <Photos/Photos.h>

@interface ViewController () <UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,MMScannerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MMScannerController *scanner;
@property (nonatomic, copy) void (^onSelectImage)(UIImage *image);

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"DEMO";
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    [self.view addSubview:self.tableView];
}

#pragma mark - 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 44;
        _tableView.scrollEnabled = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"扫描二维码/条形码";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"制作二维码（可内嵌logo）";
    } else {
        cell.textLabel.text = @"制作条形码";
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        if (!self.scanner) {
            self.scanner = [[MMScannerController alloc] init];
            self.scanner.supportBarcode = YES;
            self.scanner.delegate = self;
        }
        [self.navigationController pushViewController:_scanner animated:YES];
    } else if (indexPath.row == 1) {
        QRDetailViewController *controller = [[QRDetailViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        BarDetailViewController *controller = [[BarDetailViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - MMScannerDelegate
- (void)onScanResultCallback:(NSString *)scanContent
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"扫描内容如下：" message:scanContent preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.scanner startScan];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)onScanMineClickCallback
{
    QRDetailViewController *controller = [[QRDetailViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)onScanAlbumClickCallback:(void (^)(UIImage *image))callback
{
    self.onSelectImage = callback;
    [self galleryClicked];
}

#pragma mark - 图库选择
- (void)galleryClicked
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == AVAuthorizationStatusNotDetermined) { // 首次访问
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                    imagePicker.delegate = self;
                    imagePicker.navigationBar.tintColor = [UIColor blackColor];
                    [self presentViewController:imagePicker animated:YES completion:nil];
                });
            }
        }];
    } else {
        if (status == AVAuthorizationStatusRestricted ||
            status == AVAuthorizationStatusDenied) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在设置中开启相册权限" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.delegate = self;
            picker.navigationBar.translucent = NO;
            picker.modalPresentationStyle = UIModalPresentationFullScreen;
            if (@available(iOS 13.0, *)) {
                [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAutomatic];
            }
            [self.navigationController presentViewController:picker animated:YES completion:nil];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    !self.onSelectImage ?: self.onSelectImage([info objectForKey:UIImagePickerControllerOriginalImage]);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
