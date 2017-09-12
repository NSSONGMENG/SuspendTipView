//
//  SuspendTipV.m
//  FXApp
//
//  Created by Seven on 2017/7/19.
//  Copyright © 2017年 wsz. All rights reserved.
//

#import "SuspendTipV.h"

#define weakself   __weak   __typeof(&*self)weak_self = self

#define kSelectedColor [UIColor colorWithWhite:0.3 alpha:0.6]

#define UIColorHexFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


// -------------------------------------------------
@interface SubTipV : UIView
@property (nonatomic, copy) NSString    * tip;
@property (nonatomic, assign) Position  positon;
@end
// -------------------------------------------------

@interface SuspendTipV ()

@property (nonatomic, strong) UIImageView       * imgV;
@property (nonatomic, strong) UIView            * btomV;
@property (nonatomic, strong) SubTipV    * mainV;
@property (nonatomic, assign) Position  position;
@property (nonatomic, strong) NSMutableArray    * tipAnimOperatArr;  //用于处理自动隐藏操作
@property (nonatomic, strong) NSMutableArray    * colorAnimOperatArr;

@end

@implementation SuspendTipV


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = NO;
        [self configFrameWithAnimation:NO];
        [self addSubview:self.imgV];
        _stayDuration = 3.f;
    }
    return self;
}

- (void)configFrameWithAnimation:(BOOL)aniamtion
{
    CGPoint p = self.frame.origin;
    
    CGRect  aimR = CGRectZero;
    if (self.center.x < kScreenWidth/2) {
        aimR = CGRectMake(2, p.y, kWidthHeight, kWidthHeight);
        _position = PositionLeft;
    }else{
        aimR = CGRectMake(kScreenWidth - kWidthHeight - 2, p.y, kWidthHeight, kWidthHeight);
        _position = PositionRight;
    }
    
    self.mainV.positon = _position;
    
    if (aniamtion) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = aimR;
        } completion:nil];
    }else{
        self.frame = aimR;
    }
}


#pragma mark -
#pragma mark - public sel

- (void)showWithMsg:(NSString *)msg
{
    if (self.btomV.superview || !msg.length) {
        //tip正在显示
        return;
    }
    
    self.mainV.tip = msg;
    
    [self addSubview:self.btomV];
    [self.btomV addSubview:self.mainV];
    
    [self show];
}

- (void)show
{
    CGSize  mainVSize = self.mainV.frame.size;
    if (_position == PositionLeft) {
        self.btomV.frame = CGRectMake(kWidthHeight + 6,
                                      0,
                                      mainVSize.width,
                                      mainVSize.height);
        self.mainV.frame = CGRectMake(- mainVSize.width, 0, mainVSize.width, mainVSize.height);
    }else{
        self.btomV.frame = CGRectMake(- mainVSize.width - 6,
                                      0,
                                      mainVSize.width,
                                      mainVSize.height);
        self.mainV.frame = CGRectMake(mainVSize.width, 0, mainVSize.width, mainVSize.height);
    }
    
    self.imgV.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.mainV.frame = CGRectMake(0, 0, mainVSize.width, mainVSize.height);
    } completion:^(BOOL finished) {
        self.imgV.userInteractionEnabled = YES;
        if (_stayDuration > 0) {
            NSInvocationOperation * op = [[NSInvocationOperation alloc] initWithTarget:self
                                                                              selector:@selector(dismiss)
                                                                                object:nil];
            [self.tipAnimOperatArr addObject:op];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                         (int64_t)(_stayDuration * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^
            {
                [op start];
            });
        }
    }];
}

- (void)dismiss
{
    for (NSInvocationOperation * op in self.tipAnimOperatArr) {
        [op cancel];
    }
    for (NSInvocationOperation * op in self.colorAnimOperatArr) {
        [op cancel];
    }
    [self.colorAnimOperatArr removeAllObjects];
    [self.tipAnimOperatArr removeAllObjects];
    
    CGRect  aimFrame = CGRectZero;
    CGSize  mainVSize = self.mainV.frame.size;
    if (_position == PositionLeft) {
        aimFrame = CGRectMake(- mainVSize.width, 0, mainVSize.width, mainVSize.height);
    }else{
        aimFrame = CGRectMake(mainVSize.width, 0, mainVSize.width, mainVSize.height);
    }
    
    self.imgV.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.mainV.frame = aimFrame;
    } completion:^(BOOL finished) {
        [self.btomV removeFromSuperview];
        self.imgV.userInteractionEnabled = YES;
    }];
}

#pragma mark -
#pragma mark - gesture

- (void)tapAction:(UIGestureRecognizer *)recognizer
{
    if (self.btomV.superview) {
        for (NSInvocationOperation * op in self.tipAnimOperatArr) {
            [op cancel];
        }
        [self.tipAnimOperatArr removeAllObjects];
        [self dismiss];
    }
    else if (self.tapBlock){
        NSString * tip = self.tapBlock();
        [self showWithMsg:tip];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.imgV.backgroundColor = kSelectedColor;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.imgV.backgroundColor = [UIColor clearColor];
        }];
    }];
}

- (void)panAction:(UIPanGestureRecognizer *)pan
{
    if (pan.state == UIGestureRecognizerStateBegan) {
        //开始
        [self dismiss];
        [UIView animateWithDuration:0.2 animations:^{
            self.imgV.backgroundColor = kSelectedColor;
        }];
    }
    else if (pan.state == UIGestureRecognizerStateEnded
             || pan.state == UIGestureRecognizerStateCancelled){
        //结束
        [self configFrameWithAnimation:YES];
        
        NSInvocationOperation   * op = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(resetColor)
                                                                              object:nil];
        [self.colorAnimOperatArr addObject:op];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(2 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^
        {
            [op start];
        });
    }
    else {
        //移动
        CGPoint p = [pan locationInView:[UIApplication sharedApplication].keyWindow];
        p.y = MAX(p.y, _topMargin + kWidthHeight/2);
        p.y = MIN(kScreenHeight - _btomMargin - kWidthHeight/2, p.y);
        
        [UIView animateWithDuration:0.15 animations:^{
            self.center = p;
        }];
    }
}

- (void)resetColor
{
    [self.colorAnimOperatArr removeAllObjects];
    [UIView animateWithDuration:0.3 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.imgV.backgroundColor = [UIColor clearColor];
    } completion:nil];
}

#pragma mark -
#pragma mark - lazy loading

- (UIImageView *)imgV
{
    if (!_imgV) {
        _imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"time_down"]];
        _imgV.frame = self.bounds;
        _imgV.layer.cornerRadius = 2.f;
        _imgV.clipsToBounds = YES;
        _imgV.userInteractionEnabled = YES;
        
        UITapGestureRecognizer  * tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(tapAction:)];
        UIPanGestureRecognizer  * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(panAction:)];
        [_imgV addGestureRecognizer:tap];
        [_imgV addGestureRecognizer:pan];
    }
    return _imgV;
}

- (UIView *)btomV
{
    if (!_btomV) {
        _btomV = [[UIView alloc] initWithFrame:CGRectMake(kWidthHeight + 6,
                                                          0,
                                                          kScreenWidth - (kWidthHeight+6)*2,
                                                          kWidthHeight)];
        _btomV.backgroundColor = [UIColor clearColor];
        _btomV.clipsToBounds = YES;
    }
    return _btomV;
}

- (SubTipV *)mainV
{
    if (!_mainV) {
        _mainV = [[SubTipV alloc] initWithFrame:CGRectMake(0, 0, 0, kWidthHeight)];
    }
    return _mainV;
}

- (NSMutableArray *)tipAnimOperatArr
{
    if (!_tipAnimOperatArr) {
        _tipAnimOperatArr = [@[] mutableCopy];
    }
    return _tipAnimOperatArr;
}

- (NSMutableArray *)colorAnimOperatArr
{
    if (!_colorAnimOperatArr) {
        _colorAnimOperatArr = [@[] mutableCopy];
    }
    return _colorAnimOperatArr;
}


@end


//---------------------------------------------------------------------------------------------
//----------------------------------------- SubTipV -------------------------------------------
//---------------------------------------------------------------------------------------------

@interface SubTipV ()

@property (nonatomic, strong) UIImageView   * leftImgV;
@property (nonatomic, strong) UIImageView   * rightImgV;
@property (nonatomic, strong) UIView    * tipV;
@property (nonatomic, strong) UILabel   * tipLab;

@end

@implementation SubTipV

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createSubview];
    }
    return self;
}

- (void)createSubview
{
    [self addSubview:self.tipV];
    [self addSubview:self.tipLab];
    [self addSubview:self.leftImgV];
    [self addSubview:self.rightImgV];
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    CGSize  textSize = [_tip sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    CGFloat width = textSize.width + 9 + 20;
    CGSize  size = self.frame.size;
    
    self.frame = CGRectMake(0, 0, width, size.height);
    self.tipV.frame = CGRectMake(4.5, 0, width - 9, size.height);
    self.tipLab.frame = CGRectMake(14.5, 0, textSize.width, size.height);
    self.leftImgV.frame = CGRectMake(0, (size.height - 8)/2, 4.5, 8);
    self.rightImgV.frame = CGRectMake(width - 4.5, (size.height - 8)/2, 4.5, 8);
}

- (void)setTip:(NSString *)tip
{
    _tip = tip;
    _tipLab.text = tip;
    
    [self layoutSubviews];
}

- (void)setPositon:(Position)positon
{
    _positon = positon;

    self.leftImgV.hidden = positon == PositionRight;
    self.rightImgV.hidden = positon == PositionLeft;
}


- (UILabel *)tipLab
{
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, kWidthHeight)];
        _tipLab.textColor = UIColorHexFromRGB(0xe9e9ea);
        _tipLab.font = [UIFont systemFontOfSize:12];
    }
    return _tipLab;
}

- (UIView *)tipV
{
    if (!_tipV) {
        _tipV = [[UIView alloc] initWithFrame:CGRectZero];
        _tipV.backgroundColor = UIColorHexFromRGB(0x4c6072);
        _tipV.layer.cornerRadius = 3.f;
        _tipV.clipsToBounds = YES;
    }
    return _tipV;
}

- (UIImageView *)leftImgV
{
    if (!_leftImgV) {
        _leftImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 4.5, 8)];
        _leftImgV.image = [UIImage imageNamed:@"pdm_arrow_left"];
    }
    return _leftImgV;
}

- (UIImageView *)rightImgV
{
    if (!_rightImgV) {
        _rightImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 4.5, 8)];
        _rightImgV.image = [UIImage imageNamed:@"pdm_arrow_right"];
    }
    return _rightImgV;
}


@end

