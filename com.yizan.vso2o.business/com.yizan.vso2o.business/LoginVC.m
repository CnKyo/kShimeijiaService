//
//  LoginVC.m
//  com.yizan.vso2o.business
//
//  Created by zzl on 15/4/13.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "LoginVC.h"
#import "quiklogin.h"
#import "changePwd.h"

#import "OrderVC.h"
#import "WebVC.h"
@interface LoginVC ()<UITextFieldDelegate,UIGestureRecognizerDelegate>

@end

@implementation LoginVC
@synthesize phoneNumBgkVC,phoneTX,pwdBgkVC,pwdTX,quikLogin,loginBtn,mianzeshuoming,forgetPwd,shangjiabanBGKVC,tagVC;
-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];
}
- (void)viewDidLoad {
    self.Title = self.mPageName = @"登录";
    self.rightBtnTitle = @"注册";
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.hiddenBackBtn = YES;
    [self initView];

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
- (void)initView{
    self.quikLogin.hidden = YES;
    phoneNumBgkVC.layer.masksToBounds = YES;
    phoneNumBgkVC.layer.cornerRadius = 5;
    phoneNumBgkVC.layer.borderColor = [UIColor colorWithRed:0.831 green:0.820 blue:0.816 alpha:1].CGColor;
    phoneNumBgkVC.layer.borderWidth = 1.0;
    
    
    pwdBgkVC.layer.masksToBounds = YES;
    pwdBgkVC.layer.cornerRadius = 5;
    pwdBgkVC.layer.borderColor = [UIColor colorWithRed:0.831 green:0.820 blue:0.816 alpha:1].CGColor;
    pwdBgkVC.layer.borderWidth = 1.0;
    
    shangjiabanBGKVC.layer.masksToBounds = YES;
    shangjiabanBGKVC.layer.cornerRadius = 2;
    
    loginBtn.layer.masksToBounds = YES;
    loginBtn.layer.cornerRadius = 3;
    [loginBtn setBackgroundColor:M_CO];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    [forgetPwd setTitleColor:[UIColor colorWithRed:0.529 green:0.502 blue:0.514 alpha:1] forState:UIControlStateNormal];
    [forgetPwd addTarget:self action:@selector(btnsAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [quikLogin addTarget:self action:@selector(btnsAction:) forControlEvents:UIControlEventTouchUpInside];
    [mianzeshuoming addTarget:self action:@selector(btnsAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [phoneTX setKeyboardType:UIKeyboardTypeNumberPad];
    phoneTX.clearButtonMode = UITextFieldViewModeUnlessEditing;
    phoneTX.delegate = self;
    
    pwdTX.clearButtonMode = UITextFieldViewModeUnlessEditing;
    [pwdTX setSecureTextEntry:YES];
    pwdTX.delegate = self;


    UITapGestureRecognizer *tapAction = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:tapAction];
    
}
- (void)rightBtnTouched:(id)sender{
    int xxx = 0;
    changePwd *changeVC = [[changePwd alloc]initWithNibName:@"changePwd" bundle:nil];
    changeVC.changePwdVC = self.tagVC;
    changeVC.xxx = xxx;
    [self pushViewController:changeVC];
}
#pragma mark----登录事件在此处
- (void)loginBtnAction{
    
    [SVProgressHUD showWithStatus:@"正在登录..." maskType:SVProgressHUDMaskTypeClear];
    [SUser loginWithPhone:phoneTX.text psw:pwdTX.text block:^(SResBase *resb, SUser *user) {
        if( resb.msuccess )
        {
            [SVProgressHUD showSuccessWithStatus:resb.mmsg];
            [self loginOk];
        }
        else
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
    }];
}
-(void)loginOk
{
    if( self.tagVC )
    {
        [self setToViewController:self.tagVC];
    }
    else
    {
        [self popViewController];
    }
}
#pragma mark----1为免责申明  2为手机快速登录  3为忘记密码
- (void)btnsAction:(UIButton *)sender{
///1为免责申明  2为手机快速登录  3为忘记密码
    switch (sender.tag) {
        case 1:
        {
            NSLog(@"1");
            WebVC* vc = [[WebVC alloc]init];
            vc.mName = @"免责声明";
            vc.mUrl = @"http://wap.shimeijiavip.com/More/disclaimer";
            [self pushViewController:vc];
            
        }
            break;
        case 2:
        {
            NSLog(@"2");
            quiklogin *quikActionVC = [[quiklogin alloc]initWithNibName:@"quiklogin" bundle:nil];
            quikActionVC.quikTagVC = self.tagVC;
            [self pushViewController:quikActionVC];
            
            
        }
            break;
        case 3:
        {
            NSLog(@"3");
            int xxx = 1;
            changePwd *changeVC = [[changePwd alloc]initWithNibName:@"changePwd" bundle:nil];
            changeVC.xxx = xxx;
            changeVC.changePwdVC = self.tagVC;
            [self pushViewController:changeVC];
            
            
        }
            break;
        default:
            break;
    }
}

#pragma  mark -----键盘消失
- (void)tapAction{
    
    [phoneTX resignFirstResponder];
    [pwdTX resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
///限制电话号码输入长度
#define TEXT_MAXLENGTH 11
///限制密码输入长度
#define PASS_LENGHT 20
#pragma mark **----键盘代理方法
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *new = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSInteger res;
    if (textField.tag==20) {
        res= PASS_LENGHT-[new length];
        
        
    }else
    {
        res= TEXT_MAXLENGTH-[new length];
        
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
