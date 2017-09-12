//
//  ViewController.m
//  SuspendTipView
//
//  Created by songmeng on 17/9/12.
//  Copyright © 2017年 songmeng. All rights reserved.
//

#import "ViewController.h"
#import "SuspendTipV.h"

@interface ViewController ()

@property (nonatomic, strong) SuspendTipV   * tipV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tipV = [[SuspendTipV alloc] initWithFrame:CGRectMake(kScreenWidth - kWidthHeight, 66, kWidthHeight, kWidthHeight)];
    [self.view addSubview:_tipV];
    _tipV.topMargin = 66;
    _tipV.btomMargin = 44;
    _tipV.tapBlock = ^NSString *{
        return @"yyyyyyyyyyyyyyyyyyyyyyyyy";
    };
    
    UIView  * topV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 66)];
    topV.backgroundColor = [UIColor redColor];
    [self.view addSubview:topV];
    
    UIView  * centerV = [[UIView alloc] initWithFrame:CGRectMake(0, 66, kScreenHeight, kScreenHeight - 66 - 44)];
    centerV.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:centerV];
    
    UIView  * btomV = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44)];
    btomV.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:btomV];
    
    [self.view bringSubviewToFront:_tipV];
    
    UITapGestureRecognizer  * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [btomV addGestureRecognizer:tap];
}


- (void)tapAction
{
    [_tipV showWithMsg:@"xxxxxxxxxxxxxxxxxx"];
}


@end
