//
//  MMScannerLayer.h
//  MMScanner
//
//  Created by LEA on 2017/11/23.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMScannerLayer : UIView

// 透明的区域[扫描区 | 默认：左边距50，居中]
@property (nonatomic, assign) CGRect qrScanArea;

// 开始动画
- (void)startAnimation;
// 停止动画
- (void)stopAnimation;

@end
