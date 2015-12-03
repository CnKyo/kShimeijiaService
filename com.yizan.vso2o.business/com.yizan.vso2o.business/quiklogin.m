//
//  quiklogin.m
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/14.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "quiklogin.h"
#import "WebVC.h"
@interface quiklogin ()<UITextFieldDelegate>
{
    ///判断验证码发送时间
    NSTimer   *timer;
    ///
    int ReadTime;

}
@end

@implementation quiklogin
@synthesize phoneTx,phoneTxBGKVC,requestPwdBtn,mianzeshenming,loginBtn,rephonePwd,phoneTestCode;
-(void)loadView
{
    self.hiddenTabBar = YES;

    [super loadView];

}
- (void)viewDidLoad {
    self.Title = self.mPageName = @"手机快捷登录";
    [self initView];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)initView{

    
    phoneTxBGKVC.layer.masksToBounds = YES;
    phoneTxBGKVC.layer.cornerRadius = 5;
    phoneTxBGKVC.layer.borderColor = [UIColor colorWithRed:0.831 green:0.820 blue:0.816 alpha:1].CGColor;
    phoneTxBGKVC.layer.borderWidth = 1.0;
    
    rephonePwd.layer.masksToBounds = YES;
    rephonePwd.layer.cornerRadius = 5;
    rephonePwd.layer.borderColor = [UIColor colorWithRed:0.831 green:0.820 blue:0.816 alpha:1].CGColor;
    rephonePwd.layer.borderWidth = 1.0;
    
    loginBtn.layer.masksToBounds = YES;
    loginBtn.layer.cornerRadius = 3;
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn setBackgroundColor:M_CO];
    [loginBtn addTarget:self action:@selector(loginBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    ReadTime = 61;
    requestPwdBtn.layer.masksToBounds = YES;
    requestPwdBtn.layer.cornerRadius = 3;
    [requestPwdBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [requestPwdBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [requestPwdBtn setBackgroundColor:M_CO];
    [requestPwdBtn addTarget:self action:@selector(phonetestCodeAction) forControlEvents:UIControlEventTouchUpInside];
    
    
   [mianzeshenming addTarget:self action:@selector(btnsAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    [phoneTx setKeyboardType:UIKeyboardTypeNumberPad];
    phoneTx.clearButtonMode = UITextFieldViewModeUnlessEditing;
    phoneTx.tag = 11;
    phoneTx.delegate = self;
    
    [phoneTestCode setKeyboardType:UIKeyboardTypeNumberPad];
    phoneTestCode.clearButtonMode = UITextFieldViewModeUnlessEditing;
    phoneTestCode.tag = 6;
    phoneTestCode.delegate = self;
    
    UITapGestureRecognizer *tapAction = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:tapAction];
}
#pragma mark----获取验证码事件
- (void)phonetestCodeAction{
    if (![Util isMobileNumber:phoneTx.text]) {
        [self showErrorStatus:@"请输入合法的手机号码"];
        [phoneTx becomeFirstResponder];
        return;
    }
    requestPwdBtn.userInteractionEnabled = NO;
    
    [SVProgressHUD showWithStatus:@"正在发送验证码..." maskType:SVProgressHUDMaskTypeClear];
    [SUser sendSM:phoneTx.text block:^(SResBase *resb) {
        
        if( resb.msuccess )
        {
            [SVProgressHUD showSuccessWithStatus:resb.mmsg];
            
            timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(postPhoneTestCode)
                                                   userInfo:nil
                                                    repeats:YES];
            
            [timer fire];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
            requestPwdBtn.userInteractionEnabled = YES;
        }
        
        
    }];
    
   
    
    

}
- (void)postPhoneTestCode{
    ReadTime --;
    if (ReadTime <= 0) {
        
        MLLog(@"你点击了获取验证码");
        
        [requestPwdBtn setTitle:@"重新发送验证码" forState:UIControlStateNormal];
        ReadTime = 61;
        requestPwdBtn.userInteractionEnabled = YES;
        [timer invalidate];
        timer = nil;
        return;
    }
    else{
        NSString *timestr = [NSString stringWithFormat:@"%i秒可重新发送",ReadTime];
        [requestPwdBtn setTitle:timestr forState:UIControlStateNormal];
//        requestPwdBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
//        requestPwdBtn.titleLabel.text = timestr;
////        [requestPwdBtn setTitle:nil forState:nil];
    }
}
#pragma mark----登录事件在此处
- (void)loginBtnAction{
    
    [SVProgressHUD showWithStatus:@"正在登录...." maskType:SVProgressHUDMaskTypeClear];
    [SUser loginWithPhoneSMCode:phoneTx.text smcode:phoneTestCode.text block:^(SResBase *resb, SUser *user) {
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
    if( self.quikTagVC )
    {
        [self setToViewController_2:self.quikTagVC];
    }
    else
    {
        [self popViewController_2];
    }
}
#pragma mark----手机快速登录和免责申明事件
- (void)btnsAction{
    WebVC* vc = [[WebVC alloc]init];
    vc.mName = @"免责声明";
    vc.mUrl = @"http://wap.vso2o.jikesoft.com/More/disclaimer";
    [self pushViewController:vc];
    MLLog(@"这是免责申明");
}
#pragma  mark -----键盘消失
- (void)tapAction{
    
    [phoneTx resignFirstResponder];
    [phoneTestCode resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
///限制电话号码输入长度
#define TEXT_MAXLENGTH 11
///限制验证码输入长度
#define PASS_LENGHT 6
#pragma mark **----键盘代理方法
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *new = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSInteger res;
    if (textField.tag==11) {
        res= TEXT_MAXLENGTH-[new length];
    
        
    }else
    {
        res= PASS_LENGHT-[new length];
        
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

@end
