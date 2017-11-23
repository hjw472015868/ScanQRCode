//
//  ViewController.m
//  ErWeiMaDemo
//
//  Created by HuJinwei on 2017/8/30.
//  Copyright © 2017年 HuJinwei. All rights reserved.
//

#import "ViewController.h"
#import "HJWScanQRViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    HJWScanQRViewController *hjwVC = [[HJWScanQRViewController alloc] init];
    hjwVC.block = ^(NSString *QRCodeInfo) {
        NSLog(@"%@",QRCodeInfo);//扫描成功后的回调
    };
    [self presentViewController:hjwVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
