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

@interface MMScannerController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) MMScannerLayer *scannerLayer;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *inputDevice;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIView *warnView;
@property (nonatomic, strong) UILabel *warnLab;
@property (nonatomic, strong) UILabel *noteLab;
@property (nonatomic, strong) UIView *flashlightView;

@end

@implementation MMScannerController

#pragma mark - 初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 80;
        // 初始值
        _qrScanLineImageName = @"scan_line";
        _qrScanLineAnimateDuration = 0.01;
        _qrScanLayerBorderColor =  [UIColor whiteColor];
        _qrScanArea = CGRectMake(40, 80, width, width);
    }
    return self;
}

#pragma mark - 生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"扫描";
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setUpUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.session startRunning];
    [self.scannerLayer startAnimation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.session stopRunning];
    [self.scannerLayer stopAnimation];
}

#pragma mark - 扫描控制
- (void)startScan
{
    [self.session startRunning];
}

- (void)stopScan
{
    [self.session stopRunning];
}

#pragma mark - 设置UI
- (void)setUpUI
{
    //## 导航栏设置
    if (self.showGalleryOption) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"图库" style:UIBarButtonItemStylePlain target:self action:@selector(galleryClicked)];
    }
    //## 设置采集
    // 获取摄像设备、输入输出流
    NSError *err = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.inputDevice error:&err];
    if (!input) {
        return;
    }
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //  持续自动曝光
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
                                       AVMetadataObjectTypeEAN13Code,
                                       AVMetadataObjectTypeEAN8Code,
                                       AVMetadataObjectTypeCode128Code];
    } else {
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    }
    
    // 创建预览图层
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    // 设置扫描区域
    [[NSNotificationCenter defaultCenter]addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
        output.rectOfInterest = [layer metadataOutputRectOfInterestForRect:self.qrScanArea];
    }];
    [self.view.layer insertSublayer:layer atIndex:0];
    // 添加扫描框等
    [self.view addSubview:self.scannerLayer];
    [self.view addSubview:self.noteLab];
    // 手电筒
    if (self.showFlashlight) {
        [self.view addSubview:self.flashlightView];
    }
    // 风火轮
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    // 未识别提示
    [self.view addSubview:self.warnView];
    self.warnView.hidden = YES;
}

#pragma mark - 懒加载
- (MMScannerLayer *)scannerLayer
{
    if (!_scannerLayer) {
        _scannerLayer = [[MMScannerLayer alloc] initWithFrame:self.view.bounds];
        _scannerLayer.qrScanArea = self.qrScanArea;
        _scannerLayer.qrScanLayerBorderColor = self.qrScanLayerBorderColor;
        _scannerLayer.qrScanLineAnimateDuration = self.qrScanLineAnimateDuration;
        _scannerLayer.qrScanLineImageName = self.qrScanLineImageName;
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

- (UIActivityIndicatorView *)spinner
{
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _spinner.center = CGPointMake(self.qrScanArea.origin.x+self.qrScanArea.size.width/2, self.qrScanArea.origin.y+self.qrScanArea.size.height/2);
    }
    return _spinner;
}

- (UIView *)warnView
{
    if (!_warnView) {
        _warnView = [[UIView alloc] initWithFrame:self.view.bounds];
        _warnView.backgroundColor = [UIColor blackColor];
        _warnView.alpha = 0.7;
        _warnView.userInteractionEnabled = YES;
        [_warnView addSubview:self.warnLab];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureResponse)];
        [_warnView addGestureRecognizer:tapGestureRecognizer];
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
        
        //设置行距
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
        _noteLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.qrScanArea.origin.y+self.qrScanArea.size.height+10, self.view.bounds.size.width, 20)];
        _noteLab.textColor = [UIColor whiteColor];
        _noteLab.text = @"将二维码置于框内，即可自动扫描";
        _noteLab.textAlignment = NSTextAlignmentCenter;
        _noteLab.backgroundColor = [UIColor clearColor];
        _noteLab.font = [UIFont systemFontOfSize:13.0];
    }
    return _noteLab;
}

- (UIView *)flashlightView
{
    if (!_flashlightView) {
        _flashlightView = [[UIView alloc] initWithFrame:CGRectMake(0, self.noteLab.frame.origin.y + self.noteLab.frame.size.height + 10, self.view.bounds.size.width, 80)];
        _flashlightView.backgroundColor = [UIColor clearColor];
        
        UIButton *flashBtn = [[UIButton alloc] initWithFrame:CGRectMake((_flashlightView.bounds.size.width-60)/2, 0, 60, 60)];
        [flashBtn setImage:[UIImage imageNamed:[@"MMScanner.bundle" stringByAppendingPathComponent:@"scan_flashlight"]] forState:UIControlStateNormal];
        [flashBtn addTarget:self action:@selector(flashClicked) forControlEvents:UIControlEventTouchUpInside];
        [_flashlightView addSubview:flashBtn];
        
        UILabel *noteLab = [[UILabel alloc] initWithFrame:CGRectMake(0, flashBtn.frame.origin.y + flashBtn.frame.size.height - 10, _flashlightView.bounds.size.width, 20)];
        noteLab.textColor = [UIColor whiteColor];
        noteLab.text = @"轻触照亮";
        noteLab.textAlignment = NSTextAlignmentCenter;
        noteLab.backgroundColor = [UIColor clearColor];
        noteLab.font = [UIFont systemFontOfSize:13.0];
        [_flashlightView addSubview:noteLab];
    }
    return _flashlightView;
}

#pragma mark - 手电筒
- (void)flashClicked
{
    if (self.inputDevice.torchMode == AVCaptureTorchModeOn) {
        [self.inputDevice lockForConfiguration:nil];
        [self.inputDevice setTorchMode:AVCaptureTorchModeOff];
        [self.inputDevice unlockForConfiguration];
    } else {
        [self.inputDevice lockForConfiguration:nil];
        [self.inputDevice setTorchMode:AVCaptureTorchModeOn];
        [self.inputDevice unlockForConfiguration];
    }
}

#pragma mark - 继续扫描
- (void)gestureResponse
{
    self.warnView.hidden = YES;
}

#pragma mark - 图库选择
- (void)galleryClicked
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.navigationBar.tintColor = [UIColor blackColor];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 获取图片
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // 初始化扫描仪，设置设别类型和识别质量
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    // 扫描获取的特征组
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    // 获取扫描结果
    if ([features count]) {
        self.warnView.hidden = YES;
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scanConetent = feature.messageString;
        // 回传
        if (self.completion) self.completion(scanConetent);
    } else {
        self.warnView.hidden = NO;
    }
    //  dismiss图库
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0)
    {
        self.warnView.hidden = YES;
        // 获取扫描结果
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        NSString *scanConetent = metadataObject.stringValue;
        // 回传
        if (self.completion) {
            self.completion(scanConetent);
        }
        // 停止扫描
        [self.session stopRunning];
    }
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
