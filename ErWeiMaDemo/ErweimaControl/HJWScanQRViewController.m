//
//  HJWScanQRViewController.m
//  ErWeiMaDemo
//
//  Created by HuJinwei on 2017/8/30.
//  Copyright © 2017年 HuJinwei. All rights reserved.
//

#import "HJWScanQRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "HJWSystemFunctions.h"
@interface HJWScanQRViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSString *QRCode;
    UIView *maskView;
}
#pragma mark - ---属性---
/**
 *输入输出中间桥梁(会话)
 */
@property (strong, nonatomic) AVCaptureSession *session;

/**
 *计时器
 */
@property (strong, nonatomic) CADisplayLink *link;

/**
 *实际有效扫描区域的背景图(亦或者自己设置一个边框)
 */
@property (strong, nonatomic) UIImageView *bgImg;

/**
 *有效扫描区域循环往返的一条线（这里用的是一个背景图）
 */
@property (strong, nonatomic) UIImageView *scrollLine;


/**
 *用于控制照明灯的开启
 */
@property (strong, nonatomic) UIButton *lamp;

/**
 *用于相册的btn
 */
@property (strong, nonatomic) UIButton *photoBtn;

/**
 *用于记录scrollLine的上下循环状态
 */
@property (assign, nonatomic) BOOL up;

#pragma mark -------

@end


@implementation HJWScanQRViewController

-(BOOL)shouldAutorotate
{
    return NO;
}
/*
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat ratio = 0;
    if (self.view.frame.size.width > self.view.frame.size.height) {
        ratio = self.view.frame.size.height/320.0;
        CGFloat orangeX = ratio*50;
        self.bgImg.frame = CGRectMake(orangeX, orangeX, self.view.frame.size.height-orangeX*2, self.view.frame.size.height-orangeX*2);
        self.bgImg.center = self.view.center;
    }else{
        ratio = self.view.frame.size.width/320.0;
        CGFloat orangeX = ratio*50;
        
        self.bgImg.frame = CGRectMake(orangeX, 70, self.view.frame.size.width-orangeX*2, self.view.frame.size.width-orangeX*2);
        self.bgImg.center = CGPointMake(self.view.center.x, self.view.center.y-60);
    }
    
    self.scrollLine.frame = CGRectMake(self.bgImg.frame.origin.x, self.bgImg.frame.origin.y+4, self.bgImg.frame.size.width, 4);
    self.lamp.frame = CGRectMake(CGRectGetMaxX(self.bgImg.frame)- 60, CGRectGetMaxY(self.bgImg.frame) + 35, 60, 60);
    self.photoBtn.frame = CGRectMake(self.bgImg.frame.origin.x , CGRectGetMaxY(self.bgImg.frame) + 35, 60, 60);
    
}
*/

#pragma mark - ---lazy load---
- (UIImageView *)bgImg {
    if (!_bgImg) {
        CGFloat ratio = 0;
        if (self.view.frame.size.width > self.view.frame.size.height) {
            ratio = self.view.frame.size.height/320.0;
            CGFloat orangeX = ratio*50;
            _bgImg = [[UIImageView alloc]initWithFrame:CGRectMake(orangeX, orangeX, self.view.frame.size.width-orangeX*2, self.view.frame.size.width-orangeX*2)];
            self.bgImg.center = self.view.center;
        }else{
            ratio = self.view.frame.size.width/320.0;
            CGFloat orangeX = ratio*50;
            
            _bgImg = [[UIImageView alloc]initWithFrame:CGRectMake(orangeX, 70, self.view.frame.size.width-orangeX*2, self.view.frame.size.width-orangeX*2)];
            self.bgImg.center = CGPointMake(self.view.center.x, self.view.center.y-60);
        }
        _bgImg.image = [UIImage imageNamed:@"scan_box"];
    }
    return _bgImg;
}

- (UIImageView *)scrollLine {
    if (!_scrollLine) {
        _scrollLine = [[UIImageView alloc]initWithFrame:CGRectMake(self.bgImg.frame.origin.x, self.bgImg.frame.origin.y+4, self.bgImg.frame.size.width, 4)];
        _scrollLine.contentMode = UIViewContentModeScaleAspectFit;
        _scrollLine.image = [UIImage imageNamed:@"scan_line"];
    }
    return _scrollLine;
}


- (CADisplayLink *)link {
    if (!_link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(LineAnimation)];
    }
    return _link;
}

#pragma mark - 线条运动的动画
- (void)LineAnimation {
    if (_up == YES) {
        CGFloat y = self.scrollLine.frame.origin.y;
        y += 2;
        CGRect frame =  self.scrollLine.frame;
        frame.origin.y = y;
        self.scrollLine.frame = frame;
        if (y >= (CGRectGetMaxY(self.bgImg.frame)-self.scrollLine.frame.size.height)) {
            _up = NO;
        }
    }else{
        CGFloat y = self.scrollLine.frame.origin.y;
        y -= 2;
        CGRect frame =  self.scrollLine.frame;
        frame.origin.y = y;
        self.scrollLine.frame = frame;
        if (y <= self.bgImg.frame.origin.y) {
            _up = YES;
        }
    }
}

- (UIButton *)lamp {
    if (!_lamp) {
        _lamp = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.bgImg.frame)- 60, CGRectGetMaxY(self.bgImg.frame) + 35, 60, 60)];
        [_lamp setImage:[UIImage imageNamed:@"ic_flashlight_normal"] forState:UIControlStateNormal];
        [_lamp setImage:[UIImage imageNamed:@"ic_flashlight_light"] forState:UIControlStateSelected];
        [_lamp setBackgroundImage:[UIImage imageNamed:@"bg_white_normal"] forState:UIControlStateNormal];
        [_lamp setBackgroundImage:[UIImage imageNamed:@"bg_blue_light"] forState:UIControlStateSelected];
        [_lamp addTarget:self action:@selector(touchLamp:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lamp;
}


- (UIButton *)photoBtn {
    if (!_photoBtn) {
        _photoBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bgImg.frame.origin.x, CGRectGetMaxY(self.bgImg.frame) + 35, 60, 60)];
        [_photoBtn setImage:[UIImage imageNamed:@"ic_photo_album"] forState:UIControlStateNormal];
        [_photoBtn setImage:[UIImage imageNamed:@"ic_photo_album"] forState:UIControlStateSelected];
        [_photoBtn setBackgroundImage:[UIImage imageNamed:@"bg_white_normal"] forState:UIControlStateNormal];
        [_photoBtn setBackgroundImage:[UIImage imageNamed:@"bg_blue_light"] forState:UIControlStateHighlighted];
        [_photoBtn addTarget:self action:@selector(gotoPhotoes) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoBtn;
}

#pragma mark - 打开相册
- (void)gotoPhotoes {
    //1.判断相册是否可以打开
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return;
    }
    //2.创建图片选择控制器
    UIImagePickerController *ipc = [[UIImagePickerController alloc]init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    //选中之后大图编辑模式
    ipc.allowsEditing = YES;
    [self presentViewController:ipc animated:YES completion:nil];
}


#pragma mark - 开灯或关灯
- (void)touchLamp:(UIButton *)btn {
    btn.selected = !btn.selected;
    [HJWSystemFunctions openLight:btn.selected];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.session startRunning];
    //计时器添加到循环中去
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.session stopRunning];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _up = YES;

    //1.添加一个可见的扫描有效区域的框（这里直接是设置一个背景图片）
    [self.view addSubview:self.bgImg];
    //2.添加一个上下循环运动的线条（这里直接是添加一个背景图片来运动）
    [self session];
    
    [self.view addSubview:self.scrollLine];
    //3.添加其他有效控件
    [self.view addSubview:self.lamp];
    [self.view addSubview:self.photoBtn];
    
    //4.添加汉字
    UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(self.photoBtn.frame.origin.x, CGRectGetMaxY(self.photoBtn.frame)+5, self.photoBtn.frame.size.width, 15)];
    lab1.font = [UIFont systemFontOfSize:14];
    lab1.textAlignment = NSTextAlignmentCenter;
    lab1.text = @"相册";
    lab1.textColor = [UIColor whiteColor];
    lab1.backgroundColor = [UIColor clearColor];
    [self.view addSubview:lab1];
    UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.bgImg.frame)-self.lamp.frame.size.width, CGRectGetMaxY(self.lamp.frame)+5, self.photoBtn.frame.size.width, 15)];
    lab2.text = @"手电筒";
    lab2.textAlignment = NSTextAlignmentCenter;
    lab2.font = [UIFont systemFontOfSize:14];
    lab2.textColor = [UIColor whiteColor];
    lab2.backgroundColor = [UIColor clearColor];
    [self.view addSubview:lab2];
}




- (AVCaptureSession *)session {
    if (!_session) {
        //1.获取输入设备（摄像头）
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        //2.根据输入设备创建输入对象
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
        if (input == nil) {
            return nil;
        }
        
        //3.创建元数据的输出对象
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
        //4.设置代理监听输出对象输出的数据,在主线程中刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        // 5.创建会话(桥梁)
        AVCaptureSession *session = [[AVCaptureSession alloc]init];
        //实现高质量的输出和摄像，默认值为AVCaptureSessionPresetHigh，可以不写
        [session setSessionPreset:AVCaptureSessionPresetHigh];
        // 6.添加输入和输出到会话中（判断session是否已满）
        if ([session canAddInput:input]) {
            [session addInput:input];
        }
        if ([session canAddOutput:output]) {
            [session addOutput:output];
        }
        
        // 7.告诉输出对象, 需要输出什么样的数据 (二维码还是条形码等) 要先创建会话才能设置
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeAztecCode];
        
        // 8.创建预览图层
        AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
        [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        previewLayer.frame = self.view.bounds;
        [self.view.layer insertSublayer:previewLayer atIndex:0];
        
        //9.设置有效扫描区域，默认整个图层(很特别，1、要除以屏幕宽高比例，2、其中x和y、width和height分别互换位置)
        CGRect rect = CGRectMake(self.bgImg.frame.origin.y/self.view.frame.size.height, self.bgImg.frame.origin.x/self.bgImg.frame.size.width, self.bgImg.frame.size.width/self.view.frame.size.height, self.bgImg.frame.size.width/self.view.frame.size.width);
        output.rectOfInterest = rect;
        
        //10.设置中空区域，即有效扫描区域(中间扫描区域透明度比周边要低的效果)
        maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        [self.view addSubview:maskView];
        UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
        [rectPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:self.bgImg.frame cornerRadius:1] bezierPathByReversingPath]];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = rectPath.CGPath;
        maskView.layer.mask = shapeLayer;
        
        _session = session;
    }
    return _session;
}



#pragma mark - UIImagePickerControllerDelegate

//相册获取的照片进行处理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    // 1.取出选中的图片
    UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
    
    CIImage *ciImage = [CIImage imageWithCGImage:pickImage.CGImage];
    
    //2.从选中的图片中读取二维码数据
    //2.1创建一个探测器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    
    // 2.2利用探测器探测数据
    NSArray *feature = [detector featuresInImage:ciImage];
    
    // 2.3取出探测到的数据
    for (CIQRCodeFeature *result in feature) {
        NSString *urlStr = result.messageString;
        NSLog(@"%@",urlStr);
        //二维码信息回传
        !self.block ? : self.block(urlStr);
        
        }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (feature.count == 0) {
        [self showAlertWithTitle:@"扫描结果" Message:@"没有扫描到有效二维码" OptionalAction:@[@"确认"]];
    }
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
// 扫描到数据时会调用
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count > 0) {
        [HJWSystemFunctions openShake:YES Sound:YES];
                // 1.停止扫描
        [self.session stopRunning];
        //        // 2.停止冲击波
        [self.link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        // 3.取出扫描到得数据
        AVMetadataMachineReadableCodeObject *obj = [metadataObjects lastObject];
        if (obj)
        {
            NSLog(@"%@",[obj stringValue]);
            //二维码信息回传
            !self.block ? : self.block([obj stringValue]);
        }
    }
}

#pragma mark - 提示框
- (void)showAlertWithTitle:(NSString *)title Message:(NSString *)message OptionalAction:(NSArray *)actions {
    
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:actions.firstObject style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.session startRunning];
        [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }]];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
