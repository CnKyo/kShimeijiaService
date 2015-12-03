//
//  OrderVC.m
//  com.yizan.vso2o.business
//
//  Created by zzl on 15/4/13.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "OrderVC.h"
#import "orderCell.h"
#import "historyOrderVC.h"
#import "orderMessageVC.h"
#import <MapKit/MapKit.h>
@interface OrderVC ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
{
    NSString *phoneNum;
    ///是否加载过
    BOOL    isloding;
    ///用户
    int      userId;
    ///时间间隔
    NSDate *nowTime;

}
@end

@implementation OrderVC
@synthesize orderStr;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([SUser isNeedLogin]) {
        [self gotoLoginVC];
        return;
    }

    if (isloding) {
        return;
    }
    if (self.tempArray.count != 0 && nowTime && [nowTime timeIntervalSinceNow] < 60*5 && userId == [SUser currentUser].mUserId) {
        return;
    }else {
        [self headerBeganRefresh];
    }
    userId = [SUser currentUser].mUserId;
    isloding = YES;
    
    
    
}
- (void)viewDidLoad {
    self.mPageName = @"订单";
    self.Title = self.mPageName;
    orderStr = self.mPageName;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    self.hiddenBackBtn = YES;
    self.hiddenTabBar = NO;
    //    self.navBar.rightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:10];
    self.navBar.rightBtn.backgroundColor = [UIColor clearColor];
    self.rightBtnTitle = @"历史订单";
    [self setRightBtnWidth:123];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self loadTableView:CGRectMake(0, 0, 320, DEVICE_InNavTabBar_Height) delegate:self dataSource:self];
    
    self.haveFooter = YES;
    self.haveHeader = YES;
    
    UINib *nib = [UINib nibWithNibName:@"orderCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self checkAPPUpdate];
    [self showFrist];
}

-(void)showFrist
{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSString* v = [def objectForKey:@"showed"];
    NSString* nowver = [Util getAppVersion];
    if( ![v isEqualToString:nowver] )
    {
        UIScrollView* firstview = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        firstview.showsHorizontalScrollIndicator = NO;
        firstview.backgroundColor = [UIColor colorWithRed:0.937 green:0.922 blue:0.918 alpha:1.000];
        firstview.pagingEnabled = YES;
        firstview.bounces = NO;
        NSArray* allimgs = [self getFristImages];
        
        CGFloat x_offset = 0.0f;
        CGRect f;
        UIImageView* last = nil;
        for ( NSString* oneimgname in allimgs ) {
            UIImageView* itoneimage = [[UIImageView alloc] initWithFrame:firstview.bounds];
            itoneimage.image = [UIImage imageNamed: oneimgname];
            f = itoneimage.frame;
            f.origin.x = x_offset;
            itoneimage.frame = f;
            x_offset += firstview.frame.size.width;
            [firstview addSubview: itoneimage];
            last  = itoneimage;
        }
        UITapGestureRecognizer* guset = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fristTaped:)];
        last.userInteractionEnabled = YES;
        [last addGestureRecognizer: guset];
        
        CGSize cs = firstview.contentSize;
        cs.width = x_offset;
        firstview.contentSize = cs;
        
        [self setNeedsStatusBarAppearanceUpdate];
        
        
        [((UIWindow*)[UIApplication sharedApplication].delegate).window addSubview: firstview];
    }

}
-(NSArray*)getFristImages
{
    if( DeviceIsiPhone() )
    {
        return @[@"frist_4_0.jpg",@"frist_4_1.jpg"];
    }
    else
    {
        return @[@"frist_5_0.jpg",@"frist_5_1.jpg"];
    }
    
}

-(void)fristTaped:(UITapGestureRecognizer*)sender
{
    UIView* ttt = [sender view];
    UIView* pview = [ttt superview];
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect f = pview.frame;
        f.origin.y = -pview.frame.size.height;
        pview.frame = f;
        
    } completion:^(BOOL finished) {
        
        [pview removeFromSuperview];
        
        NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
        NSString* nowver = [Util getAppVersion];
        [def setObject:nowver forKey:@"showed"];
        [def synchronize];
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if( self.navigationController.viewControllers.count == 1 )  return NO;
    return YES;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----顶部刷新数据
- (void)headerBeganRefresh{

    self.page = 1;
    [[SUser currentUser]getMyOrdersForSeller:_mtype page:self.page block:^(SResBase *resb, NSArray *all) {
        
        isloding = NO;
        nowTime = [NSDate date];
        
        [self headerEndRefresh];
        [self.tempArray removeAllObjects];
        if (resb.msuccess) {
            [self.tempArray addObjectsFromArray:all];
        }
        else{
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
        if( self.tempArray.count == 0 )
        {
            [self addEmptyViewWithImg:nil];
        }
        else
        {
            [self removeEmptyView];
        }
        [self.tableView reloadData];

    }];
}
-(void)footetBeganRefresh
{
    self.page ++;
    [[SUser currentUser]getMyOrdersForSeller:_mtype page:self.page block:^(SResBase *resb, NSArray *all) {
        [self footetEndRefresh];
        if (resb.msuccess) {
            
            [self.tempArray addObjectsFromArray:all];
            [self.tableView reloadData];
            
        }
        else{
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
        if( self.tempArray.count == 0 )
        {
            [self addEmptyViewWithImg:nil];
        }
        else
        {
            [self removeEmptyView];
        }
    }];
    
}
#pragma mark ----列表代理方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    orderCell *cell = (orderCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    SOrder *order =  self.tempArray[indexPath.row];
    cell.address.numberOfLines = 0;
    
    cell.navgationBtn.layer.masksToBounds = YES;
    cell.navgationBtn.layer.cornerRadius = 5;
    cell.navgationBtn.layer.borderColor = [UIColor colorWithRed:0.624 green:0.604 blue:0.616 alpha:1].CGColor;
    cell.navgationBtn.layer.borderWidth = 1;
    
    cell.connectionBtn.layer.masksToBounds = YES;
    cell.connectionBtn.layer.cornerRadius = 5;
    cell.connectionBtn.layer.borderColor = M_CO.CGColor;
    cell.connectionBtn.layer.borderWidth = 1;
    
    cell.toplinebgkVC.layer.masksToBounds = YES;
    cell.toplinebgkVC.layer.borderColor = [UIColor colorWithRed:0.867 green:0.847 blue:0.843 alpha:1].CGColor;
    cell.toplinebgkVC.layer.borderWidth = 0.7;
    
    cell.payStatusBgkVc.layer.masksToBounds = YES;
    cell.payStatusBgkVc.layer.cornerRadius = 3;
    cell.productNameLb.text = order.mGooods.mName;
    cell.nameLb.text = order.mUserName;
    cell.dateTimeLb.text = order.mCreateOrderTime;
    cell.phoneNumLb.text = order.mPhoneNum;
    phoneNum = order.mPhoneNum;
    NSString *pricestr = [NSString stringWithFormat:@"¥%.02f元",order.mPayMoney];
    cell.priceLb.text = pricestr;
    cell.orderCodeLb.text = order.mSn;
    cell.address.text = order.mAddress;
    cell.querenLb.text = order.mOrderStateStr;
    cell.payStatusBgkVc.backgroundColor = [UIColor colorWithRed:1.000 green:0.631 blue:0.220 alpha:1];
    cell.payStatusLb.text = @"在线支付";
    
    [cell.navgationBtn addTarget:self action:@selector(NavAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.navgationBtn.tag = indexPath.row;
    [cell.connectionBtn addTarget:self action:@selector(TelAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.connectionBtn.tag = indexPath.row;
    
    
    cell.firstLine.frame = CGRectMake(15, 39, 310, 0.7);
    cell.secondLine.frame = CGRectMake(15, 173, 310, 0.7);

    
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tempArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 240;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SOrder *order =  self.tempArray[indexPath.row];
    
    orderMessageVC *orderVC = [[orderMessageVC alloc]init];
    orderVC.msgStr = self.orderStr;
    orderVC.mtagorder = order;
    
    [self pushViewController:orderVC];
}
#pragma mark----右侧历史订单按钮事件
- (void)rightBtnTouched:(id)sender{
    MLLog(@"历史订单");
    historyOrderVC *hVC = [[historyOrderVC alloc]init];
    [self pushViewController:hVC];

}

-(void)NavAction:(UIButton*)sender
{
    MLLog(@"路径导航");
    
    SOrder *order =  self.tempArray[sender.tag];
    
    //跳转到高德地图
    NSString* ampurl = [NSString stringWithFormat:@"iosamap://navi?sourceApplication=testapp&backScheme=zyseller&lat=%.7f&lon=%.7f&dev=0&style=0",order.mLat,order.mLongit];
    
    if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:ampurl]] )
    {//
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ampurl]];
    }
    else
    {//ioS map
        
        CLLocationCoordinate2D to;
        to.latitude =  order.mLat;
        to.longitude =  order.mLongit;
        
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:to addressDictionary:nil] ];
        toLocation.name = order.mAddress;
        [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil]
                       launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
                                                                 forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
    }
}

#pragma mark----路径导航和联系顾客按钮事件
- (void)TelAction:(UIButton *)sender{
    
    SOrder *order =  self.tempArray[sender.tag];
    MLLog(@"联系顾客");
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",order.mPhoneNum];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
@end
