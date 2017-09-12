//
//  SuspendTipV.h
//  FXApp
//
//  Created by Seven on 2017/7/19.
//  Copyright © 2017年 wsz. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kScreenWidth    [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight   [[UIScreen mainScreen] bounds].size.height


typedef NS_ENUM(NSInteger, Position) {
    PositionLeft = 0,
    PositionRight = 1,
};

#define kWidthHeight  30

@interface SuspendTipV : UIView

/** 点击倒计时图标回调 */
@property (nonatomic, copy) NSString * (^tapBlock)();
@property (nonatomic, assign) CGFloat   topMargin;  //距屏幕顶部留白
@property (nonatomic, assign) CGFloat   btomMargin; //距屏幕底部留白
@property (nonatomic, assign) CGFloat   stayDuration;   //tip显示时间，默认为3s，<=0则不自动隐藏

/** 弹出提示提示语 */
- (void)showWithMsg:(NSString *)msg;

- (void)dismiss;

@end

