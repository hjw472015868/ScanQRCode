//
//  HJWScanQRViewController.h
//  ErWeiMaDemo
//
//  Created by HuJinwei on 2017/8/30.
//  Copyright © 2017年 HuJinwei. All rights reserved.
//

#import <UIKit/UIKit.h>
//信息扫描成功后返回的内容
typedef void(^SuccessBlock)(NSString *QRCodeInfo);

@interface HJWScanQRViewController : UIViewController
//扫描成功后的回传
@property (nonatomic, copy) SuccessBlock block;


@end
