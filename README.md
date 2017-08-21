# LivePlayer

![image](https://github.com/pptk/LivePlayer/blob/master/b47a9c80-c000-4b74-8f41-173d18b4b50b.gif?raw=true) 

最后我也没有采取这种强制横屏的方式。而是让整个项目支持横竖屏然后在viewcontroller里面重写这两个方法。
- (BOOL)shouldAutorotate{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
