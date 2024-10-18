//
//  BarDetailViewController.m
//  MMScannerDemo
//
//  Created by LEA on 2018/12/19.
//  Copyright © 2018 LEA. All rights reserved.
//

#import "BarDetailViewController.h"
#import "MMCodeMaker.h"

@interface BarDetailViewController ()

@property(nonatomic, strong) UIImageView * codeImageView;
@property(nonatomic, copy) NSString * codeContent;

@end

@implementation BarDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"条形码";
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    
    self.codeContent = @"1234567890abcdefghijk";
    self.codeImageView.image = [MMCodeMaker barCodeImageWithContent:self.codeContent size:CGSizeMake(300, 120)];
    [self.view addSubview:self.codeImageView];
    
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 300, self.view.bounds.size.width, self.view.bounds.size.height-300)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.borderColor = [[[UIColor lightGrayColor] colorWithAlphaComponent:0.7] CGColor];
    contentView.layer.borderWidth = 1.0;
    [self.view addSubview:contentView];
    
    UILabel * noteLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 20)];
    noteLab.font = [UIFont systemFontOfSize:14.0];
    noteLab.text = @"内容：";
    noteLab.textColor = [UIColor grayColor];
    [contentView addSubview:noteLab];
    
    CGSize contentSize = [self.codeContent boundingRectWithSize:CGSizeMake(self.view.bounds.size.width-20, MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}
                                                      context:nil].size;
    
    UILabel * contentLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, self.view.bounds.size.width-20, contentSize.height+10)];
    contentLab.font = [UIFont systemFontOfSize:13.0];
    contentLab.textColor = [UIColor grayColor];
    contentLab.numberOfLines = 0;
    contentLab.text = self.codeContent;
    [contentView addSubview:contentLab];
}

#pragma mark - lazy load
- (UIImageView *)codeImageView
{
    if (!_codeImageView) {
        _codeImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 300) / 2.0, 0, 300, 300)];
        _codeImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _codeImageView;
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
