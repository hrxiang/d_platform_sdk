//
//  ViewController.m
//  lite_demo
//
//  Created by tng on 2020/4/21.
//  Copyright © 2020 tng. All rights reserved.
//

#import "ViewController.h"
#import "DPlatformApi.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

/// 发起支付.
- (IBAction)launch:(id)sender {
    
    /// token模式.
    //[DPlatformApi sendPayReqWithOrderSn:@"ordersn_123" token:@"token_123" channelNo:@"00"];
    
    /// 无token模式.
    [DPlatformApi sendPayReqWithOrderSn:@"ordersn123" outUid:@"uid123" channelNo:@"10013057" extraParams:@{
        @"mobileNo": @"13888888888"
    }];
}


@end
