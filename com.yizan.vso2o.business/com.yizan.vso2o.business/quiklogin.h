//
//  quiklogin.h
//  com.yizan.vso2o.business
//  手机快速登录页面
//  Created by 密码为空！ on 15/4/14.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "BaseVC.h"

@interface quiklogin : BaseVC
///手机号码背景
@property (weak, nonatomic) IBOutlet UIView *phoneTxBGKVC;
///验证码背景
@property (weak, nonatomic) IBOutlet UIView *rephonePwd;


///获取验证码按钮
@property (weak, nonatomic) IBOutlet UIButton *requestPwdBtn;
///免责申明按钮
@property (weak, nonatomic) IBOutlet UIButton *mianzeshenming;
///登录按钮
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;


///手机输入框
@property (weak, nonatomic) IBOutlet UITextField *phoneTx;
///手机验证码输入框
@property (weak, nonatomic) IBOutlet UITextField *phoneTestCode;

@property (nonatomic,strong)    UIViewController* quikTagVC;

@end
