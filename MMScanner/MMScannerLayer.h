//
//  MMScannerLayer.h
//  MMScanner
//
//  Created by LEA on 2017/11/23.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMScannerLayer : UIView

// 透明的区域[扫描区 | 默认：左边距40，上边距80]
@property (nonatomic, assign) CGRect qrScanArea;
// 动画间隔时间 [默认值:0.01]
@property (nonatomic, assign) double qrScanLineAnimateDuration;
// 四角颜色 [默认：白色]
@property (nonatomic, strong) UIColor *qrScanLayerBorderColor;
// 扫描线图片[默认：使用bundle下的scan_line]
@property (nonatomic, copy) NSString *qrScanLineImageName;

// 开始动画
- (void)startAnimation;
// 停止动画
- (void)stopAnimation;

@end
