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

@interface ViewController () <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) MMScannerController * scanner;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"二维码";
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
    if (indexPath.row == 0)
    {
        __weak typeof(self) weakSelf = self;
        _scanner = [[MMScannerController alloc] init];
        _scanner.showGalleryOption = YES;
        _scanner.showFlashlight = YES;
        _scanner.supportBarcode = YES;
        [_scanner setCompletion:^(NSString *scanConetent) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"扫描内容如下："
                                                             message:scanConetent
                                                            delegate:weakSelf
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil, nil];
            [alert show];
        }];
        [self.navigationController pushViewController:_scanner animated:YES];
    } else if (indexPath.row == 1) {
        QRDetailViewController * controller = [[QRDetailViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        BarDetailViewController * controller = [[BarDetailViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [_scanner startScan];
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
