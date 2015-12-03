//
//  historyOrderVC.m
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/15.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "historyOrderVC.h"
#import "orderCell.h"
#import "orderMessageVC.h"
#import "tongjiVC.h"
@interface historyOrderVC ()<UITableViewDataSource,UITableViewDelegate>
{

    ///用户
    int      userId;
    ///时间间隔
    NSDate *nowTime;

}
@end

@implementation historyOrderVC
@synthesize historyStr;

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([SUser isNeedLogin]) {
        [self gotoLoginVC];
        return;
    }
    if (_isloaddata) {
        return;
    }
    if (self.tempArray.count != 0 && nowTime && [nowTime timeIntervalSinceNow] < 60*5 && userId == [SUser currentUser].mUserId) {
        return;
    }
    else{
        [self headerBeganRefresh];

    }
    userId = [SUser currentUser].mUserId;
    _isloaddata = YES;
    
}
-(void)loadView
{
    self.hiddenTabBar = YES;
    [super loadView];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.mPageName = @"历史订单";
    self.Title = self.mPageName;
    historyStr = self.mPageName;
    
    self.rightBtnTitle = @"统计";
    self.navBar.rightBtn.frame = CGRectMake(240, 27, 123, 31);

    
    if ([SUser isNeedLogin]) {
        [self gotoLoginVC];
        return;
    }
    
    _mtype = 1;
    [self initView];
}
- (void)initView{
    
    [self loadTableView:CGRectMake(0, 0, 320, DEVICE_InNavBar_Height) delegate:self dataSource:self];
    
    self.haveFooter = YES;
    self.haveHeader = YES;
    UINib *nib = [UINib nibWithNibName:@"orderCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView headerBeginRefreshing];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark ----顶部刷新数据
- (void)headerBeganRefresh{
    
    self.page = 1;
    [[SUser currentUser]getMyOrdersForSeller:_mtype page:self.page block:^(SResBase *resb, NSArray *all) {
        
        _isloaddata = NO;
        nowTime = [NSDate date];
        
        [self headerEndRefresh];
        [self.tempArray removeAllObjects];
        MLLog(@"取出来的arr数据是:%@",all);
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
#pragma mark----右侧统计按钮事件
- (void)rightBtnTouched:(id)sender{
    MLLog(@"统计按钮");
    
    tongjiVC *tongji = [[tongjiVC alloc]init];
    tongji.month = 0;
    [self pushViewController:tongji];
    
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

    cell.payStatusBgkVc.layer.masksToBounds = YES;
    cell.payStatusBgkVc.layer.cornerRadius = 3;
    
    cell.toplinebgkVC.layer.masksToBounds = YES;
    cell.toplinebgkVC.layer.borderColor = [UIColor colorWithRed:0.867 green:0.847 blue:0.843 alpha:1].CGColor;
    cell.toplinebgkVC.layer.borderWidth = 1;
    
    cell.productNameLb.text = order.mGooods.mName;
    cell.nameLb.text = order.mUserName;
    cell.dateTimeLb.text = order.mCreateOrderTime;
    cell.phoneNumLb.text = order.mPhoneNum;
    NSString *pricestr = [NSString stringWithFormat:@"¥%.02f元",order.mPayMoney];
    cell.priceLb.text = pricestr;
    cell.orderCodeLb.text = order.mSn;
    cell.address.text = order.mAddress;
    cell.querenLb.text = order.mOrderStateStr;
    cell.payStatusBgkVc.backgroundColor = [UIColor colorWithRed:1.000 green:0.631 blue:0.220 alpha:1];
    cell.payStatusLb.text = @"在线支付";

    ///
    [cell.navgationBtn removeFromSuperview];
    [cell.connectionBtn removeFromSuperview];
    [cell.lineView removeFromSuperview];
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
    return 190;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SOrder *order =  self.tempArray[indexPath.row];

    orderMessageVC *orderVC = [[orderMessageVC alloc]init];
    
    orderVC.msgStr = self.historyStr;
    orderVC.mtagorder = order;
    [self pushViewController:orderVC];
}

@end
