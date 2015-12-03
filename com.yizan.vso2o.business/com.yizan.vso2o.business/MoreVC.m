//
//  MoreVC.m
//  com.yizan.vso2o.business
//
//  Created by zzl on 15/4/13.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "MoreVC.h"
#import "messageView.h"
#import "updataView.h"
#import "WebVC.h"

#import "feedBackViewController.h"
@interface MoreVC ()<UIGestureRecognizerDelegate>
{
    
}
@end

@implementation MoreVC
- (void)loadView{
    self.hiddenBackBtn = YES;
    [super loadView];
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if ([SUser isNeedLogin]) {
        self.nameLb.text = nil;
        self.phoneNumLb.text = nil;
        [self.changgeBtn setTitle:@"登录" forState:UIControlStateNormal];
    }else{
    
        [self.headerImg sd_setImageWithURL:[NSURL URLWithString:[SUser currentUser].mHeadImgURL] placeholderImage:[UIImage imageNamed:@"defultHead.png"]];
        self.nameLb.text = [SUser currentUser].mUserName;
        self.phoneNumLb.text = [SUser currentUser].mPhone;
        [self.changgeBtn setTitle:@"退出登录" forState:UIControlStateNormal];

    }
    if( [SUser isNeedLogin] )
    {
        [self gotoLoginVC];
        return;
    }

    [self loadData];
    
    
}

- (void)viewDidLoad {

    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    self.mPageName = @"更多";
    self.Title = self.mPageName;
    [self initView];
    // Do any additional setup after loading the view.
    self.hiddenBackBtn = YES;
    self.secondPiontImg.hidden = [GInfo shareClient].mAppDownUrl.length == 0;

    
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if( self.navigationController.viewControllers.count == 1 )  return NO;
    return YES;
}


- (void)initView{

    self.headerImg.layer.masksToBounds = YES;
    self.headerImg.layer.cornerRadius = 30;
    
    self.changgeBtn.layer.masksToBounds = YES;
    self.changgeBtn.layer.cornerRadius = 5;
    
    self.topBgkVC.layer.masksToBounds = YES;
    self.topBgkVC.layer.borderColor = [UIColor colorWithRed:0.847 green:0.835 blue:0.831 alpha:1].CGColor;
    self.topBgkVC.layer.borderWidth = 1;
    
    [self.msgBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.aboutUsBTn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.updataBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];

    [self.changgeBtn addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.feedBackBtn addTarget:self action:@selector(feedBackBtnaction:) forControlEvents:UIControlEventTouchUpInside];

}
- (void)loadData{

    [[SUser currentUser] getUserState:^(SResBase *resb, SUserState *userstate) {
        
        self.firstPionImg.hidden = !userstate.mbHaveNewMsg;
        
    }];
    
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark－－－－消息，关于我们，检查更新按钮事件1为消息，2为关于我们，3为检查更新
- (void)btnAction:(UIButton *)sender{
    switch (sender.tag) {
        case 1:
        {///消息
            MLLog(@"消息");
            messageView *msgVC = [[messageView alloc] init];
            [self pushViewController:msgVC];
            [self.firstPionImg removeFromSuperview];
        }
            break;
        case 2:
        {///关于我们
            MLLog(@"关于我们");
            WebVC* vc = [[WebVC alloc]init];
            vc.mName = @"关于我们";
            vc.mUrl = @"http://wap.shimeijiavip.com/More/aboutus";
            [self pushViewController:vc];
        }
            break;
        case 3:
        {///检查更新
            MLLog(@"检查更新");
            [SVProgressHUD showWithStatus:@"正在检查版本信息" maskType:SVProgressHUDMaskTypeClear];
            [GInfo getGInfoForce:^(SResBase *resb, GInfo *gInfo) {
                if( resb.msuccess )
                {
                    if( gInfo.mAppDownUrl.length != 0 )
                    {
                        [SVProgressHUD dismiss];
                        [self checkAPPUpdate];
                    }
                    
                    else
                    {
                        [SVProgressHUD showSuccessWithStatus:@"当前已经是最新版本了"];
                    }
                }
                else
                {
                    [SVProgressHUD showErrorWithStatus:resb.mmsg];
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (void)feedBackBtnaction:(UIButton *)sender{
    feedBackViewController *feedBack = [[feedBackViewController alloc]initWithNibName:@"feedBackViewController" bundle:nil];
    [self pushViewController:feedBack];
}
-(void)doupdateAPP
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[GInfo shareClient].mAppDownUrl]];
}

-(void)checkAPPUpdate
{
    if( [GInfo shareClient].mAppDownUrl )
    {
        NSString* msg = [GInfo shareClient].mUpgradeInfo;
        if( [GInfo shareClient].mForceUpgrade )
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"版本更新" message:msg delegate:self cancelButtonTitle:@"升级" otherButtonTitles:nil, nil];
            [alert show];
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"版本更新" message:msg delegate:self cancelButtonTitle:@"暂不更新" otherButtonTitles:@"立即更新", nil];
            [alert show];
        }
    }
}


#pragma mark－－－－切换账号事件
- (void)changeAction:(UIButton *)sender{
    MLLog(@"切换账号");
    
//    UIAlertView* al = [[UIAlertView alloc] initWithTitle:@"退出登录" message:@"是否确定退出当前用户" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    al.delegate = self;
//    [al show];
    [self AlertViewShow:@"退出登录" alertViewMsg:@"是否确定退出当前用户" alertViewCancelBtnTiele:@"取消" alertTag:10];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 10 )
    {
        if( buttonIndex == 1)
        {
            [SUser logout];
            [SVProgressHUD showSuccessWithStatus:@"退出成功"];
            [self.changgeBtn setTitle:@"登录" forState:UIControlStateNormal];
            [self gotoLoginVC];
        }
    }
    else
    {
        
        if( [GInfo shareClient].mForceUpgrade )
        {
            [self doupdateAPP];
        }
        else
        {
            if( 1 == buttonIndex )
            {
                [self doupdateAPP];
            }
        }
    }
}
- (void)AlertViewShow:(NSString *)alerViewTitle alertViewMsg:(NSString *)msg alertViewCancelBtnTiele:(NSString *)cancelTitle alertTag:(int)tag{
    
    UIAlertView* al = [[UIAlertView alloc] initWithTitle:alerViewTitle message:msg delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:@"确定", nil];
    al.delegate = self;
    al.tag = tag;
    [al show];
}
@end
