//
//  changePwd.h
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/14.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "BaseVC.h"

@interface changePwd : BaseVC
@property (weak, nonatomic) IBOutlet UIView *phoneBgkView;
@property (weak, nonatomic) IBOutlet UIView *phoneTseCodeView;
@property (weak, nonatomic) IBOutlet UIView *xinPwdBgkView;
@property (weak, nonatomic) IBOutlet UIView *querenPwdbgkView;

@property (weak, nonatomic) IBOutlet UIButton *changeBtn;
@property (weak, nonatomic) IBOutlet UIButton *testCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *connectionServiverBtn;

@property (weak, nonatomic) IBOutlet UITextField *phoneTx;
@property (weak, nonatomic) IBOutlet UITextField *testCodeTx;
@property (weak, nonatomic) IBOutlet UITextField *xinPwdTx;
@property (weak, nonatomic) IBOutlet UITextField *querenPwdTx;
@property (nonatomic,strong)    UIViewController *changePwdVC;

@property (nonatomic,assign)int xxx;
@end
