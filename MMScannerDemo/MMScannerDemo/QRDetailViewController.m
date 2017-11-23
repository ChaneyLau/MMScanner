//
//  QRDetailViewController.m
//  MMScannerDemo
//
//  Created by LEA on 2017/11/23.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "QRDetailViewController.h"
#import "MMCodeMaker.h"

@interface QRDetailViewController ()

@property(nonatomic,strong) UIImageView *qrImageView;
@property(nonatomic, copy) NSString *qrContent;

@end

@implementation QRDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"结果";
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    
    self.qrContent = @"Hello, this is a two-dimensional code";
    self.qrImageView.image = [MMCodeMaker qrImageWithContent:self.qrContent logoImage:[UIImage imageNamed:@"logo.jpg"] qrColor:[UIColor blackColor] qrWidth:300];
    [self.view addSubview:self.qrImageView];

    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 300, self.view.bounds.size.width, self.view.bounds.size.height-300)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.borderColor = [[[UIColor lightGrayColor] colorWithAlphaComponent:0.7] CGColor];
    contentView.layer.borderWidth = 1.0;
    [self.view addSubview:contentView];
    
    UILabel *noteLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 20)];
    noteLab.font = [UIFont systemFontOfSize:14.0];
    noteLab.text = @"内容：";
    noteLab.textColor = [UIColor grayColor];
    [contentView addSubview:noteLab];
    
    CGSize contentSize = [self.qrContent boundingRectWithSize:CGSizeMake(self.view.bounds.size.width-20, MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}
                                                      context:nil].size;
    
    UILabel *contentLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, self.view.bounds.size.width-20, contentSize.height+10)];
    contentLab.font = [UIFont systemFontOfSize:13.0];
    contentLab.textColor = [UIColor grayColor];
    contentLab.numberOfLines = 0;
    contentLab.text = self.qrContent;
    [contentView addSubview:contentLab];
}

#pragma mark - GETTER
- (UIImageView *)qrImageView
{
    if (!_qrImageView) {
        _qrImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-200)/2, 50, 200, 200)];
        _qrImageView.backgroundColor = [UIColor clearColor];
        _qrImageView.layer.borderWidth = 0.5;
        _qrImageView.layer.borderColor = [[[UIColor lightGrayColor] colorWithAlphaComponent:0.7] CGColor];
    }
    return _qrImageView;
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
