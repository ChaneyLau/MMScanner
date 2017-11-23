//
//  MMScannerLayer.m
//  MMScanner
//
//  Created by LEA on 2017/11/23.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "MMScannerLayer.h"

@interface MMScannerLayer ()

// 定时器
@property (nonatomic, strong) NSTimer *scanTimer;
// 扫描线
@property (nonatomic, strong) UIImageView *qrScanLine;
// 扫描线竖向偏移量
@property (nonatomic, assign) CGFloat qrScanLineOffY;

@end

@implementation MMScannerLayer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
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

#pragma mark - 初始化  
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!_qrScanLine) {
        UIImage *image = [UIImage imageNamed:[@"MMScanner.bundle" stringByAppendingPathComponent:_qrScanLineImageName]];
        _qrScanLine  = [[UIImageView alloc] initWithFrame:CGRectMake(_qrScanArea.origin.x,_qrScanArea.origin.y, _qrScanArea.size.width, image.size.height)];
        _qrScanLine.image = image;
        _qrScanLine.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_qrScanLine];
        _qrScanLineOffY = _qrScanLine.frame.origin.y;
    }
}

#pragma mark - 动画
- (void)startAnimation
{
    _scanTimer = [NSTimer scheduledTimerWithTimeInterval:_qrScanLineAnimateDuration
                                                  target:self
                                                selector:@selector(scanQrCode)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_scanTimer forMode:NSRunLoopCommonModes];
    [_scanTimer fire];
}

- (void)stopAnimation
{
    [_scanTimer invalidate];
}

#pragma mark - 扫描
- (void)scanQrCode
{
    [UIView animateWithDuration:_qrScanLineAnimateDuration animations:^{
        CGRect rect = _qrScanLine.frame;
        rect.origin.y = _qrScanLineOffY;
        _qrScanLine.frame = rect;
    } completion:^(BOOL finished) {
        CGFloat maxBorder = _qrScanArea.origin.y+_qrScanArea.size.height;
        if (_qrScanLineOffY >= maxBorder - 1) {
            _qrScanLineOffY = _qrScanArea.origin.y;
        }
        _qrScanLineOffY ++;
    }];
}

#pragma mark - 渲染
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self addScreenFillRect:ctx rect:self.frame];
    [self addCenterClearRect:ctx rect:_qrScanArea];
    [self addWhiteRect:ctx rect:_qrScanArea];
    [self addCornerLineWithContext:ctx rect:_qrScanArea];
}

- (void)addScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextSetRGBFillColor(ctx, 0/255.0, 0/255.0, 0/255.0, 0.7);
    CGContextFillRect(ctx, rect);
}

- (void)addCenterClearRect:(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextClearRect(ctx, rect);
}

- (void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextStrokeRect(ctx, rect);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
    CGContextSetLineWidth(ctx, 0.8);
    CGContextAddRect(ctx, rect);
    CGContextStrokePath(ctx);
}

- (void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect
{
    //边角的长度
    CGFloat margin = 20;
    
    //获取颜色RGB值
    CGFloat red = 0.0;
    CGFloat green = 0.0;
    CGFloat blue = 0.0;
    CGFloat alpha = 0.0;
    [_qrScanLayerBorderColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    CGContextSetLineWidth(ctx, 2);
    CGContextSetRGBStrokeColor(ctx, red, green, blue, 1.0);
    
    //左上角
    CGPoint poinsTopLeftA[] = {
        CGPointMake(rect.origin.x, rect.origin.y),
        CGPointMake(rect.origin.x, rect.origin.y + margin)
    };
    CGPoint poinsTopLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y),CGPointMake(rect.origin.x + margin, rect.origin.y)};
    [self addLine:poinsTopLeftA pointB:poinsTopLeftB ctx:ctx];
    //左下角
    CGPoint poinsBottomLeftA[] = {CGPointMake(rect.origin.x, rect.origin.y + rect.size.height - margin),CGPointMake(rect.origin.x,rect.origin.y + rect.size.height)};
    CGPoint poinsBottomLeftB[] = {CGPointMake(rect.origin.x , rect.origin.y + rect.size.height) ,CGPointMake(rect.origin.x + margin, rect.origin.y + rect.size.height)};
    [self addLine:poinsBottomLeftA pointB:poinsBottomLeftB ctx:ctx];
    //右上角
    CGPoint poinsTopRightA[] = {CGPointMake(rect.origin.x + rect.size.width - margin, rect.origin.y),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y )};
    CGPoint poinsTopRightB[] = {CGPointMake(rect.origin.x + rect.size.width, rect.origin.y),CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + margin)};
    [self addLine:poinsTopRightA pointB:poinsTopRightB ctx:ctx];
    //右下角
    CGPoint poinsBottomRightA[] = {CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height+ - margin),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y +rect.size.height)};
    CGPoint poinsBottomRightB[] = {CGPointMake(rect.origin.x + rect.size.width - margin , rect.origin.y + rect.size.height),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y + rect.size.height)};
    [self addLine:poinsBottomRightA pointB:poinsBottomRightB ctx:ctx];
    CGContextStrokePath(ctx);
}

- (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx
{
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}

@end
