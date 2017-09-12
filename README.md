# SuspendTipView
可显示通知消息的悬浮滑块
=======================
### 使用方法
```Objective-C
    _tipV = [[SuspendTipV alloc] initWithFrame:CGRectMake(kScreenWidth - kWidthHeight, 66, kWidthHeight, kWidthHeight)];
    [self.view addSubview:_tipV];
    _tipV.topMargin = 66;
    _tipV.btomMargin = 44;
    _tipV.tapBlock = ^NSString *{
        return @"yyyyyyyyyyyyyyyyyyyyyyyyy";
    };
    
    //将tipV扔到视图最顶层
    [self.view bringSubviewToFront:_tipV];
    
    //也可以这样显示消息
    [_tipV showWithMsg:@"xxxxxxxxxxxxxxxxxx"];
```
![](https://github.com/NSSONGMENG/SuspendTipView/blob/master/SuspendTipView/SuspendTipV/2017-09-13%2000_01_43.gif)
