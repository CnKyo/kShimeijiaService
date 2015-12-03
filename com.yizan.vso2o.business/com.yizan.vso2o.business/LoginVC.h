//
//  LoginVC.h
//  com.yizan.vso2o.business
//  登录页面
//  Created by zzl on 15/4/13.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "BaseVC.h"

@interface LoginVC : BaseVC
@property (weak, nonatomic) IBOutlet UIView *phoneNumBgkVC;
@property (weak, nonatomic) IBOutlet UIView *pwdBgkVC;
@property (weak, nonatomic) IBOutlet UITextField *phoneTX;
@property (weak, nonatomic) IBOutlet UITextField *pwdTX;
@property (weak, nonatomic) IBOutlet UIButton *quikLogin;
@property (weak, nonatomic) IBOutlet UIButton *forgetPwd;
@property (weak, nonatomic) IBOutlet UIButton *mianzeshuoming;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIView *shangjiabanBGKVC;
@property (weak, nonatomic) IBOutlet UIView *bgkVC;

@property (nonatomic,strong)    UIViewController* tagVC;

@end
