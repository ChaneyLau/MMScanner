//
//  MMScannerController.h
//  MMScanner
//
//  Created by LEA on 2017/11/23.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMScannerDelegate;
@interface MMScannerController : UIViewController

// 代理
@property (nonatomic, weak) id<MMScannerDelegate> delegate;
// 是否支持条码 [默认显示：NO]
@property (nonatomic, assign) BOOL supportBarcode;

// 扫描控制
- (void)startScan;
- (void)stopScan;

@end

@protocol MMScannerDelegate <NSObject>

@optional
// 扫描结果返回
- (void)onScanResultCallback:(NSString *)scanContent;
// 进入【我的二维码】
- (void)onScanMineClickCallback;
// 进入图库，并回传图片
- (void)onScanAlbumClickCallback:(void (^)(UIImage *image))callback;

@end
