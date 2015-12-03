//
//  changePwd.m
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/14.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "changePwd.h"

@interface changePwd ()<UITextFieldDelegate>
{
    ///判断验证码发送时间
    NSTimer   *timer;
    ///
    int ReadTime;
    
}
@end

@implementation changePwd
@synthesize phoneBgkView,phoneTseCodeView,xinPwdBgkView,querenPwdbgkView,changeBtn,testCodeBtn,connectionServiverBtn,phoneTx,testCodeTx,xinPwdTx,querenPwdTx;
-(void)loadView
{
    self.hiddenTabBar = YES;
    
    [super loadView];
    
}
- (void)viewDidLoad {
    if (self.xxx == 0) {
        self.Title = self.mPageName = @"注册";
        [self.changeBtn setTitle:@"注册" forState:UIControlStateNormal];

    }else{
        self.Title = self.mPageName = @"修改密码";
        [self.changeBtn setTitle:@"修改" forState:UIControlStateNormal];

    }
    [self initView];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (void)initView{
    
    phoneBgkView.layer.masksToBounds = YES;
    phoneBgkView.layer.cornerRadius = 5;
    phoneBgkView.layer.borderColor = [UIColor colorWithRed:0.831 green:0.820 blue:0.816 alpha:1].CGColor;
    phoneBgkView.layer.borderWidth = 1.0;
    
    phoneTseCodeView.layer.masksToBounds = YES;
    phoneTseCodeView.layer.cornerRadius = 5;
    phoneTseCodeView.layer.borderColor = [UIColor colorWithRed:0.831 green:0.820 blue:0.816 alpha:1].CGColor;
    phoneTseCodeView.layer.borderWidth = 1.0;
    
    xinPwdBgkView.layer.masksToBounds = YES;
    xinPwdBgkView.layer.cornerRadius = 5;
    xinPwdBgkView.layer.borderColor = [UIColor colorWithRed:0.831 green:0.820 blue:0.816 alpha:1].CGColor;
    xinPwdBgkView.layer.borderWidth = 1.0;
    
    querenPwdbgkView.layer.masksToBounds = YES;
    querenPwdbgkView.layer.cornerRadius = 5;
    querenPwdbgkView.layer.borderColor = [UIColor colorWithRed:0.831 green:0.820 blue:0.816 alpha:1].CGColor;
    querenPwdbgkView.layer.borderWidth = 1.0;
    
    changeBtn.layer.masksToBounds = YES;
    changeBtn.layer.cornerRadius = 3;
    [changeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [changeBtn setBackgroundColor:M_CO];
    [changeBtn addTarget:self action:@selector(changeBtnAction) forControlEvents:UIControlEventTouchUpInside];

    ReadTime = 61;

    testCodeBtn.layer.masksToBounds = YES;
    testCodeBtn.layer.cornerRadius = 3;
    [testCodeBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [testCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [testCodeBtn setBackgroundColor:M_CO];
    [testCodeBtn addTarget:self action:@selector(requestTestCodeAction) forControlEvents:UIControlEventTouchUpInside];

    [connectionServiverBtn addTarget:self action:@selector(connectionAction) forControlEvents:UIControlEventTouchUpInside];
    
    [phoneTx setKeyboardType:UIKeyboardTypeNumberPad];
    phoneTx.clearButtonMode = UITextFieldViewModeUnlessEditing;
    phoneTx.tag = 11;
    phoneTx.delegate = self;
    
    [testCodeTx setKeyboardType:UIKeyboardTypeNumberPad];
    testCodeTx.clearButtonMode = UITextFieldViewModeUnlessEditing;
    testCodeTx.tag = 6;
    testCodeTx.delegate = self;
    
    xinPwdTx.clearButtonMode = UITextFieldViewModeUnlessEditing;
    xinPwdTx.tag = 20;
    [xinPwdTx setSecureTextEntry:YES];
    xinPwdTx.delegate = self;
    
    querenPwdTx.clearButtonMode = UITextFieldViewModeUnlessEditing;
    querenPwdTx.tag = 20;
    [querenPwdTx setSecureTextEntry:YES];
    querenPwdTx.delegate = self;
    
    UITapGestureRecognizer *tapAction = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:tapAction];
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /**
     IQKeyboardManager为自定义收起键盘
     **/
    [[IQKeyboardManager sharedManager] setEnable:YES];///视图开始加载键盘位置开启调整
    [[IQKeyboardManager sharedManager]setEnableAutoToolbar:YES];///是否启用自定义工具栏
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;///启用手势
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];///视图消失键盘位置取消调整
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];///关闭自定义工具栏
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

}
#pragma  mark -----修改密码按钮

- (void)changeBtnAction{
    
    [SVProgressHUD showWithStatus:@"正在设置..." maskType:SVProgressHUDMaskTypeClear];
    [SUser reSetPswWithPhone:phoneTx.text newpsw:xinPwdTx.text smcode:testCodeTx.text block:^(SResBase *resb, SUser *user) {
        
        if( resb.msuccess )
        {
            [SVProgressHUD showSuccessWithStatus:resb.mmsg];
            [self loginOk];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
    }];

}
-(void)loginOk
{
    if( self.changePwdVC )
    {
        [self setToViewController_2:self.changePwdVC];
    }
    else
    {
        [self popViewController_2];
    }
}


#pragma  mark -----获取验证码按钮
#pragma mark----获取验证码事件
- (void)requestTestCodeAction{
    if (![Util isMobileNumber:phoneTx.text]) {
        [self showErrorStatus:@"请输入合法的手机号码"];
        [phoneTx becomeFirstResponder];
        return;
    }
    testCodeBtn.userInteractionEnabled = NO;
    
    [SVProgressHUD showWithStatus:@"正在发送验证码..." maskType:SVProgressHUDMaskTypeClear];
    [SUser sendSM:phoneTx.text block:^(SResBase *resb) {
        
        if( resb.msuccess )
            [SVProgressHUD showSuccessWithStatus:resb.mmsg];
        else
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        
    }];
    
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(phonetestCodeAction)
                                           userInfo:nil
                                            repeats:YES];
    
    [timer fire];
    
}

- (void)phonetestCodeAction{
    ReadTime --;
    if (ReadTime <= 0) {
        
        NSLog(@"你点击了获取验证码");
        
        [testCodeBtn setTitle:@"重新发送验证码" forState:UIControlStateNormal];
        ReadTime = 61;
        testCodeBtn.userInteractionEnabled = YES;
        [timer invalidate];
        timer = nil;
        return;
    }
    else{

        [testCodeBtn setTitle:[NSString stringWithFormat:@"%i%@",ReadTime,@"秒可重新发送"] forState:UIControlStateNormal];
        
    }

}
#pragma  mark -----联系客服按钮

- (void)connectionAction{
    
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",[GInfo shareClient].mServiceTel];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma  mark -----键盘消失
- (void)tapAction{
    
    [phoneTx resignFirstResponder];
    [testCodeTx resignFirstResponder];
    [xinPwdTx resignFirstResponder];
    [querenPwdTx resignFirstResponder];

}
///限制电话号码输入长度
#define TEXT_MAXLENGTH 11
///限制密码输入长度
#define PASS_LENGHT 20
//限制验证码输入长度
#define TEST_LENGHT 6

#pragma mark **----键盘代理方法
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *new = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSInteger res;
    if (textField.tag==11) {
        res= TEXT_MAXLENGTH-[new length];
        
        
    }else if(textField.tag == 20)
    {
        res= PASS_LENGHT-[new length];
        
    }
    else{
        res = TEST_LENGHT - [new length];
    }
    if(res >= 0){
        return YES;
    }
    else{
        NSRange rg = {0,[string length]+res};
        if (rg.length>0) {
            NSString *s = [string substringWithRange:rg];
            [textField setText:[textField.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
