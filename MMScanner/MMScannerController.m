//
//  MMScannerController.m
//  MMScanner
//
//  Created by LEA on 2017/11/23.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "MMScannerController.h"
#import "MMScannerLayer.h"
#import <AVFoundation/AVFoundation.h>

@interface MMScannerController () <AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) MMScannerLayer *scannerLayer;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *inputDevice;
@property (nonatomic, strong) UIView *warnView;
@property (nonatomic, strong) UILabel *warnLab;
@property (nonatomic, strong) UILabel *noteLab;

// 透明的区域[扫描区 | 默认：左边距50, 居中]
@property (nonatomic, assign) CGRect qrScanArea;

@end

@implementation MMScannerController

#pragma mark - 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        CGFloat margin = 50.0;
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 2*margin;
        CGFloat top = ([UIScreen mainScreen].bounds.size.height - width)/2.0;
        self.qrScanArea = CGRectMake(margin, top, width, width);
    }
    return self;
}

#pragma mark - life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpUI];
    [self setUpNavigation];
    [self setUpBottom];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self startScan];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO] ;
    [self stopScan];
}

#pragma mark - 扫描控制
- (void)startScan
{
    [self.scannerLayer startAnimation];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.session startRunning];
    });
}

- (void)stopScan
{
    [self.scannerLayer stopAnimation];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.session stopRunning];
    });
}

#pragma mark - 设置UI
- (void)setUpNavigation
{
    self.title = @"扫一扫";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[UIImageView new]];
    CGFloat top = [[UIApplication sharedApplication] statusBarFrame].size.height;
    // 返回
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(20, top, 44, 44)];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [backButton setImage:[UIImage imageNamed:[@"MMScanner.bundle" stringByAppendingPathComponent:@"scan_back"]] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    // 标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-100)/2.0, top, 100, 44)];
    titleLabel.text = @"扫一扫";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    [self.view addSubview:titleLabel];
}

- (void)setUpBottom
{
    CGFloat safeHeight = 0;
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        safeHeight = mainWindow.safeAreaInsets.bottom;
    }
    CGFloat margin = self.qrScanArea.origin.x;
    CGFloat bWidth = 50;
    CGFloat bMargin = 60;
    CGFloat bottom = safeHeight + bMargin + bWidth;
    
    // 我的
    UIButton *mineButton = [[UIButton alloc] initWithFrame:CGRectMake(margin, self.view.bounds.size.height-bottom, bWidth, bWidth)];
    mineButton.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    mineButton.layer.cornerRadius = bWidth/2.0;
    mineButton.layer.masksToBounds = YES;
    [mineButton setImageEdgeInsets:UIEdgeInsetsMake(13, 13, 13, 13)];
    [mineButton setImage:[UIImage imageNamed:[@"MMScanner.bundle" stringByAppendingPathComponent:@"scan_mine"]] forState:UIControlStateNormal];
    [mineButton addTarget:self action:@selector(onMine) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mineButton];
    
    UILabel *mineLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin-10, mineButton.frame.origin.y+mineButton.frame.size.height, bWidth+20, 30)];
    mineLabel.text = @"我的二维码";
    mineLabel.textColor = [UIColor whiteColor];
    mineLabel.textAlignment = NSTextAlignmentCenter;
    mineLabel.font = [UIFont systemFontOfSize:12.0];
    [self.view addSubview:mineLabel];
    
    // 图库
    UIButton *albumButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-margin-bWidth, self.view.bounds.size.height-bottom, bWidth, bWidth)];
    albumButton.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.3];
    albumButton.layer.cornerRadius = bWidth/2.0;
    albumButton.layer.masksToBounds = YES;
    [albumButton setImageEdgeInsets:UIEdgeInsetsMake(13, 13, 13, 13)];
    [albumButton setImage:[UIImage imageNamed:[@"MMScanner.bundle" stringByAppendingPathComponent:@"scan_album"]] forState:UIControlStateNormal];
    [albumButton addTarget:self action:@selector(onAlbum) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:albumButton];
    
    UILabel *albumLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-margin-bWidth, albumButton.frame.origin.y+albumButton.frame.size.height, bWidth, 30)];
    albumLabel.text = @"图库";
    albumLabel.textColor = [UIColor whiteColor];
    albumLabel.textAlignment = NSTextAlignmentCenter;
    albumLabel.font = [UIFont systemFontOfSize:12.0];
    [self.view addSubview:albumLabel];
}

- (void)setUpUI
{
    self.view.backgroundColor = [UIColor blackColor];
    // 相机权限
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) { // 首次访问
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (!granted) { // 未授权 > 返回
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }];
    } else {
        if (status == AVAuthorizationStatusRestricted ||
            status == AVAuthorizationStatusDenied) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在设置中打开相机权限" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
    }
    // 设置采集
    // 获取摄像设备、输入输出流
    NSError *err = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.inputDevice error:&err];
    if (!input) {
        return;
    }
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 持续自动曝光
    NSError *error = nil;
    if ([self.inputDevice lockForConfiguration:&error]) {
        [self.inputDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        [self.inputDevice setTorchMode:AVCaptureTorchModeAuto];
        [self.inputDevice unlockForConfiguration];
    }
    [self.session setSessionPreset:AVCaptureSessionPreset1920x1080];
    [self.session addInput:input];
    [self.session addOutput:output];
    // 是否支持条形码
    if (self.supportBarcode) {
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                       // 条形码（添加越多扫描越慢
                                       AVMetadataObjectTypeEAN8Code,
                                       AVMetadataObjectTypeEAN13Code,
                                       AVMetadataObjectTypeUPCECode,
                                       AVMetadataObjectTypeCode39Code,
                                       AVMetadataObjectTypeCode128Code,
                                       AVMetadataObjectTypeCode39Mod43Code,
                                       AVMetadataObjectTypeCode93Code,
                                       AVMetadataObjectTypePDF417Code,
                                       AVMetadataObjectTypeInterleaved2of5Code];
    } else {
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    }
    
    // 创建预览图层
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    // 设置扫描区域
    [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *_Nonnull note) {
        output.rectOfInterest = [layer metadataOutputRectOfInterestForRect:self.qrScanArea];
    }];
    [self.view.layer insertSublayer:layer atIndex:0];
    // 添加扫描框等
    [self.view addSubview:self.scannerLayer];
    [self.view addSubview:self.noteLab];
    // 未识别提示
    [self.view addSubview:self.warnView];
    self.warnView.hidden = YES;
}

#pragma mark - 事件
- (void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onMine
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onScanMineClickCallback)]) {
        [self.delegate onScanMineClickCallback];
    }
}

- (void)onAlbum
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onScanAlbumClickCallback:)]) {
        __typeof(&*self) __weak weakSelf = self;
        [self.delegate onScanAlbumClickCallback:^(UIImage *image) {
            [weakSelf performSelector:@selector(scanForImage:) withObject:image afterDelay:0.5];
        }];
    }
}

#pragma mark - 继续扫描
- (void)gestureResponse
{
    self.warnView.hidden = YES;
    [self startScan];
}

- (void)scanForImage:(UIImage *)image
{
    // 停止扫描
    [self stopScan];
    // 初始化扫描仪，设置设别类型和识别质量
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    // 扫描获取的特征组
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    // 获取扫描结果
    if ([features count]) {
        self.warnView.hidden = YES;
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scanContent = feature.messageString;
        // 回传
        if (self.delegate && [self.delegate respondsToSelector:@selector(onScanResultCallback:)]) {
            [self.delegate onScanResultCallback:scanContent];
        }
    } else {
        self.warnView.hidden = NO;
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        self.warnView.hidden = YES;
        // 获取扫描结果
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        NSString *scanContent = metadataObject.stringValue;
        NSLog(@"scanContent: %@",scanContent);
        // 回传
        if (self.delegate && [self.delegate respondsToSelector:@selector(onScanResultCallback:)]) {
            [self.delegate onScanResultCallback:scanContent];
        }
        // 停止扫描
        [self stopScan];
    }
}

#pragma mark - lazy load
- (MMScannerLayer *)scannerLayer
{
    if (!_scannerLayer) {
        _scannerLayer = [[MMScannerLayer alloc] initWithFrame:self.view.bounds];
        _scannerLayer.qrScanArea = self.qrScanArea;
        _scannerLayer.contentMode = UIViewContentModeRedraw;
        _scannerLayer.backgroundColor = [UIColor clearColor];
    }
    return _scannerLayer;
}

- (AVCaptureDevice *)inputDevice
{
    if (!_inputDevice) {
        _inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _inputDevice;
}

- (AVCaptureSession *)session
{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (UIView *)warnView
{
    if (!_warnView) {
        _warnView = [[UIView alloc] initWithFrame:self.view.bounds];
        _warnView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        _warnView.userInteractionEnabled = YES;
        [_warnView addSubview:self.warnLab];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureResponse)];
        [_warnView addGestureRecognizer:tap];
    }
    return _warnView;
}

- (UILabel *)warnLab
{
    if (!_warnLab) {
        _warnLab = [[UILabel alloc] initWithFrame:self.qrScanArea];
        _warnLab.numberOfLines = 0;
        _warnLab.font = [UIFont systemFontOfSize:14.0];
        _warnLab.textColor = [UIColor whiteColor];
        _warnLab.backgroundColor = [UIColor clearColor];
        
        NSString *warnStr = @"未发现二维码\n轻触屏幕继续";
        if (self.supportBarcode) {
            warnStr = @"未发现二维码/条形码\n轻触屏幕继续";
        }
        // 设置行距
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:warnStr];
        NSMutableParagraphStyle *stype = [[NSMutableParagraphStyle alloc] init];
        stype.lineSpacing = 3;
        stype.alignment = NSTextAlignmentCenter;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:stype range:NSMakeRange(0,[warnStr length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0] range:NSMakeRange(0,warnStr.length-6)];
        _warnLab.attributedText = attributedString;
    }
    return _warnLab;
}

- (UILabel *)noteLab
{
    if (!_noteLab) {
        _noteLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.qrScanArea.origin.y+self.qrScanArea.size.height+20, self.view.bounds.size.width, 20)];
        _noteLab.textColor = [UIColor whiteColor];
        _noteLab.text = @"请将二维码对准扫码框中心";
        _noteLab.textAlignment = NSTextAlignmentCenter;
        _noteLab.backgroundColor = [UIColor clearColor];
        _noteLab.font = [UIFont boldSystemFontOfSize:13.0];
    }
    return _noteLab;
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
