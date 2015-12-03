//
//  BaseVC.m
//  testBase
//
//  Created by ljg on 15-2-27.
//  Copyright (c) 2015年 ljg. All rights reserved.
//

#import "BaseVC.h"
#import "MobClick.h"
#import "LoginVC.h"
@interface BaseVC ()
{
    UIView *emptyView;
    UIView *notifView;
}
@end

@implementation BaseVC
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if( self ) {
        //MLLog_VC("initWithNibName");
     //   self.isCancelConectionsWhenviewDidDisappear = YES;
      //  originY = 0;
    //    vcType = kViewController_MainVC;
        NSLog(@"<------isnib");
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        //MLLog_VC("init");
    //    self.isCancelConectionsWhenviewDidDisappear = YES;
      //  originY = 0;
     //   vcType = kViewController_MainVC;
        NSLog(@"--------->isnotnib");

    }
    return self;
}

-(void)loadView
{
    [super loadView];
    //***
   
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = COLOR(238, 234, 233);
    [self hideTabBar];
    self.navBar =  [[NavBar alloc]init];
    self.navBar.NavDelegate = self;
    self.navBar.bgImage = [UIImage imageNamed:@"navbg.png"];

    if ([self.Title isEmpty]) {
        self.Title = @"base";
    }

    if (!self.hiddenNavBar&&!self.hiddenTabBar) {
        self.contentView = [[ContentScrollView alloc]initWithFrame:CGRectMake(0, DEVICE_NavBar_Height, DEVICE_Width, DEVICE_InNavTabBar_Height)];
        self.contentView.clipsToBounds = YES;
        [self.view addSubview:self.navBar];
    }
    else if (!self.hiddenNavBar&&self.hiddenTabBar)
    {
        self.contentView = [[ContentScrollView alloc]initWithFrame:CGRectMake(0, DEVICE_NavBar_Height, DEVICE_Width, DEVICE_InNavBar_Height)];
        self.contentView.clipsToBounds = YES;
        [self.view addSubview:self.navBar];
    }
    else if (self.hiddenNavBar)
    {
        self.contentView = [[ContentScrollView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_Width, DEVICE_Height)];
        self.contentView.clipsToBounds = YES;
    }
    self.contentView.backgroundColor = [UIColor colorWithWhite:0.910 alpha:1.000];
    [self.view addSubview:self.contentView];
    self.automaticallyAdjustsScrollViewInsets = NO;

   //
   static  TabBar *tab;
    if (tab == nil) {
        tab = [[TabBar alloc]initWithFrame:CGRectMake(0, self.contentView.frame.size.height+self.contentView.frame.origin.y, 320, DEVICE_TabBar_Height)];
        tab.tabDelegate = self;
    }
    self.tabBar = tab;

    if( !self.tempArray )
        self.tempArray = [[NSMutableArray alloc]init];
    self.page = 0;

}

-(void)setHiddenBackBtn:(BOOL)hiddenBackBtn
{
    self.navBar.leftBtn.hidden = hiddenBackBtn;
}
-(void)checkUserGinfo
{
    [self removeNotifacationStatus];
}
-(void)addNotifacationStatus:(NSString *)str
{
    if (!notifView) {
        notifView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        self.contentView.clipsToBounds = NO;
        UILabel *label = [[UILabel alloc]initWithFrame:notifView.bounds];
        label.text =str;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        notifView.backgroundColor = COLOR(88, 88, 88);
        notifView.alpha = 0.0;
       // label.backgroundColor = [UIColor redColor];
        [notifView addSubview:label];
    }
    [self.contentView addSubview:notifView];

    [self notifViewAnimation:YES];
}
-(void)notifViewAnimation:(BOOL)isbegan
{
    if (isbegan) {
        [UIView animateWithDuration:1 animations:^{
//            CGRect rect = notifView.frame;
//            rect.origin.y=0;
//            notifView.frame = rect;
            notifView.alpha = 1.0;
        }];
    }else
    {
        [UIView animateWithDuration:1 animations:^{
//            CGRect rect = notifView.frame;
//            rect.origin.y=-50;
//            notifView.frame = rect;
               notifView.alpha = 0.0;
        }completion:^(BOOL finished) {
            [notifView removeFromSuperview];
            notifView = nil;
        }];
    }
}
-(void)removeNotifacationStatus
{
    [self notifViewAnimation:NO];
}
- (void)hideTabBar {
    if (self.tabBarController.tabBar.hidden == YES) {
        return;
    }
    UIView *contentView;
    if ( [[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )
        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    else
        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
    contentView.frame = CGRectMake(contentView.bounds.origin.x,  contentView.bounds.origin.y,  contentView.bounds.size.width, contentView.bounds.size.height + self.tabBarController.tabBar.frame.size.height);
    self.tabBarController.tabBar.hidden = YES;

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if( !_mPageName )
    {
        NSLog(@"page not name:%@",[self description]);
        assert(_mPageName);
    }
    [MobClick beginLogPageView:_mPageName];
    MLLog_VC("viewWillAppear");

    if (!self.hiddenTabBar) {
        [super.view addSubview:self.tabBar];
    }

}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //MLLog_VC("viewWillDisappear");

    [MobClick endLogPageView:_mPageName];

}
-(void)setHaveHeader:(BOOL)have
{
    __block BaseVC *vc = self;

    [self.tableView addHeaderWithCallback:^{
        [vc headerBeganRefresh];
    }];
}
-(void)setHaveFooter:(BOOL)haveFooter
{
    __block BaseVC *vc = self;
    [self.tableView addFooterWithCallback:^{
        [vc footetBeganRefresh];
    }];

}
- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = false;
    [self.view sendSubviewToBack:self.contentView];

}
-(void)headerBeganRefresh
{
    [self headerEndRefresh];

    //todo
}
-(void)footetBeganRefresh
{
    [self footetEndRefresh];
    //todo
}

-(void)headerEndRefresh{
    [self.tableView headerEndRefreshing];
}//header停止刷新
-(void)footetEndRefresh{
    [self.tableView footerEndRefreshing];
}//footer停止刷新
-(void)loadTableView:(CGRect)rect delegate:(id<UITableViewDelegate>)delegate dataSource:(id<UITableViewDataSource>)datasource
{
    self.tableView = [[UITableView alloc]initWithFrame:rect];
    self.tableView.delegate = delegate;
    self.tableView.dataSource = datasource;
    [self.contentView addSubview:self.tableView];
}

-(void)leftBtnTouched:(id)sender
{
    [self dismiss];
    [self popViewController];
    //todo
}
-(void)rightBtnTouched:(id)sender
{
    //todo
}

-(void)setTitle:(NSString *)str
{
    _Title = str;
    self.navBar.titleLabel.text = str;
}
-(void)setRightBtnTitle:(NSString *)str
{
    [self.navBar.rightBtn setImage:nil forState:UIControlStateNormal];
    [self.navBar.rightBtn setTitle:str forState:UIControlStateNormal];
}
-(void)addEmptyView:(NSString *)str
{
    return [self addEmptyViewWithImg:nil];
    
    if (emptyView) {
        [self.tableView addSubview:emptyView];
        return;
    }
    emptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_Width, 200)];
    emptyView.backgroundColor = [UIColor clearColor];
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(150, 40, 43, 43)];
    image.center = CGPointMake(emptyView.bounds.size.width / 2, emptyView.frame.size.height / 2-40) ;
    image.image = [UIImage imageNamed:@"noitem.png"];
    [emptyView addSubview:image];
    UIButton *addBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 250, 60)];
    [addBtn setCenter:CGPointMake(emptyView.bounds.size.width / 2, emptyView.frame.size.height / 2+20)];
    [addBtn setTitle:str forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    //  [addBtn addTarget:self action:@selector(addbtnTouched) forControlEvents:UIControlEventTouchUpInside];
    [emptyView addSubview:addBtn];
    self.tableView.tableFooterView = emptyView;
}
-(void)addEmptyViewWithImg:(NSString *)img
{
    if( img == nil )
        img = @"ic_empty";
    
    if (emptyView) {
        [self.tableView addSubview:emptyView];
        return;
    }
    
    emptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_Width, 200)];
    emptyView.backgroundColor = [UIColor clearColor];
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(150, 40, 140, 105)];
    image.center = CGPointMake(emptyView.bounds.size.width / 2, emptyView.frame.size.height / 2-40) ;
    image.image = [UIImage imageNamed:img];
    [emptyView addSubview:image];
    
//    UIButton *addBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 250, 60)];
//    [addBtn setCenter:CGPointMake(emptyView.bounds.size.width / 2, emptyView.frame.size.height / 2+20)];
//    [addBtn setTitle:str forState:UIControlStateNormal];
//    [addBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    [emptyView addSubview:addBtn];
//    
    self.tableView.tableFooterView = emptyView;
}






-(void)removeEmptyView
{
    if (emptyView) {
        self.tableView.tableFooterView = nil;
        emptyView = nil;
    }
}



-(void)setRightBtnImage:(UIImage *)rightImage
{
    [self.navBar.rightBtn setTitle:nil forState:UIControlStateNormal];
    [self.navBar.rightBtn setImage:rightImage forState:UIControlStateNormal];
}
-(void)setRightBtnWidth:(CGFloat)size              //setRightBtnWidth Set方法
{
    self.navBar.rightBtn.frame = CGRectMake(220, 27, 123, 31);
}

-(void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)popViewController_2
{
    NSMutableArray* vcs = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    if( vcs.count > 2 )
    {
        [vcs removeLastObject];
        [vcs removeLastObject];
        [self.navigationController setViewControllers:vcs   animated:YES];
    }
    else
        [self popViewController];
}
-(void)popToRootViewController{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)pushViewController:(UIViewController *)vc{
    if( [vc isKindOfClass:[BaseVC class] ] )
    {
        
        if( ((BaseVC*)vc).isMustLogin )
        {
            if( [SUser isNeedLogin] )
            {
                LoginVC *vclog = [[LoginVC alloc]init];
                vclog.tagVC = vc;
                [self pushViewController:vclog];//LoginVC,RegisterVC 里面的isMustLogin 一定不能设置了,否则递归
            }
            else
            {
                [self.navigationController pushViewController:vc animated:YES];
            }
        
        }
        else
            [self.navigationController pushViewController:vc animated:YES];
        
    }
    else
        [self.navigationController pushViewController:vc animated:YES];
}
-(void)setToViewController:(UIViewController *)vc
{
    NSMutableArray* vcs = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    [vcs removeLastObject];
    [vcs addObject:vc];
    [self.navigationController setViewControllers:vcs   animated:YES];
    
}
-(void)setToViewController_2:(UIViewController *)vc
{
    NSMutableArray* vcs = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    [vcs removeLastObject];
    if( vcs.count )
        [vcs removeLastObject];//把上一级也删除了
    
    [vcs addObject:vc];
    [self.navigationController setViewControllers:vcs   animated:YES];
}
-(void)showWithStatus:(NSString *)str //调用svprogresssview加载框 参数：加载时显示的内容
{
    [SVProgressHUD showWithStatus:str maskType:SVProgressHUDMaskTypeClear];
}
-(void)dismiss //隐藏svprogressview
{
    [SVProgressHUD dismiss];
}
-(void)showSuccessStatus:(NSString *)str//展示成功状态svprogressview
{
    [SVProgressHUD showSuccessWithStatus:str];
}
-(void)showErrorStatus:(NSString *)astr//展示失败状态svprogressview
{
    [SVProgressHUD showErrorWithStatus:astr];
}
-(void)didSelectBtn:(NSInteger)tag
{


    switch (tag) {
        case 0:
            if (self.tabBarController.selectedIndex == 0) {

                return;

            }
            else
                self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:0];
            break;
        case 1:
            if (self.tabBarController.selectedIndex == 1) {
                return;
            }
            else

                self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:1];
            break;
        case 2:
            if (self.tabBarController.selectedIndex == 2) {
                return;
            }
            else
                self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:2];
            break;
        case 3:
            if (self.tabBarController.selectedIndex == 3) {
                return;
            }
            else
                self.tabBarController.selectedViewController = [self.tabBarController.viewControllers objectAtIndex:3];
            break;
        default:
            break;
    }
    /*
     CATransition *animation =[CATransition animation];
     [animation setDuration:0.5f];
     [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
     [animation setType:kCATransitionFade];
     [animation setSubtype:kCATransitionFade];
     [self.view.layer addAnimation:animation forKey:@"change"];
     */
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)gotoLoginVC
{
    LoginVC *vclog = [[LoginVC alloc]initWithNibName:@"LoginVC" bundle:nil];
    [self pushViewController:vclog];//LoginVC,RegisterVC 里面的isMustLogin 一定不能设置了,否则递归
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
