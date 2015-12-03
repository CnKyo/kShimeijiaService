//
//  tongjiVC.m
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/16.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "tongjiVC.h"
#import "tongjiCell.h"
#import "orderMessageVC.h"
@interface tongjiVC ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL    _bdoing;
    
    int         _userid;
    
    NSDate* _lastget;
}
@end

@implementation tongjiVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)loadView{
    self.hiddenTabBar = YES;
    [super loadView];
    self.contentView.needFix = YES;
}
- (void)viewDidLoad {
    
    if( _month == 0 )
    {
        self.Title =   self.mPageName = @"收入统计";
        self.rightBtnTitle = @"按月份";
        self.navBar.rightBtn.frame = CGRectMake(230, 27, 123, 31);
    }
    else if ( _month == -1 )
    {
        self.Title =    self.mPageName = @"月份收入汇总";
    }
    else if( _month > 0 || _month < 13 )
    {
        self.Title =   self.mPageName = [NSString stringWithFormat:@"%d年%d月",_myeaer,_month];
    }
    else{
        MLLog(@"erro!!!!");
        [self showErrorStatus:@"运行错误：日期错误!!!!"];
    }
    
    [super viewDidLoad];
    
    
    if ([SUser isNeedLogin]) {
        [self gotoLoginVC];
        return;
    }

    
    // Do any additional setup after loading the view.
        
    [self initView];
    
    [self.tableView headerBeginRefreshing];
    
}
- (void)initView{
    
    [self loadTableView:CGRectMake(0, 0, 320, DEVICE_InNavBar_Height) delegate:self dataSource:self];
    
    self.haveFooter = YES;
    self.haveHeader = YES;
    
    self.contentView.backgroundColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1];
    
    if (_month == 0) {
        UINib *nib = [UINib nibWithNibName:@"tongjiCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"O_cell"];
    }
     if (_month == -1){
        UINib * nib = [UINib nibWithNibName:@"monthCell" bundle:nil];
        [self.tableView registerNib:nib forCellReuseIdentifier:@"m_cell"];
    }
     else if (_month > 0 || _month < 13 ){
         UINib *nib = [UINib nibWithNibName:@"tongjiCell" bundle:nil];
         [self.tableView registerNib:nib forCellReuseIdentifier:@"O_cell"];
     }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark ----顶部刷新数据
- (void)headerBeganRefresh{
    
    self.page = 1;
    [SStatisic getStatisic:_myeaer month:_month page:self.page block:^(SResBase *resb, NSArray *all) {

        [self headerEndRefresh];
        [self.tempArray removeAllObjects];
        
        if (resb.msuccess) {
            [self.tempArray addObjectsFromArray:all];
            MLLog(@"取出来的统计数据是:%@",self.tempArray);
        }
        else{
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
        if (self.tempArray.count == 0) {
            [self addEmptyViewWithImg:nil];
        }
        else{
            [self removeEmptyView];
        }
        
        [self.tableView reloadData];
    }];
}
-(void)footetBeganRefresh
{
    self.page ++;
    
    [SStatisic getStatisic:_myeaer month:_month page:self.page block:^(SResBase *resb, NSArray *all) {
        
        [self footetEndRefresh];
        if (resb.msuccess) {
            
            [self.tempArray addObjectsFromArray:all];
            [self.tableView reloadData];

            
        }
        else{
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
        if (self.tempArray.count == 0) {
            [self addEmptyViewWithImg:nil];
        }
        else{
            [self removeEmptyView];
        }
    }];
}

#pragma mark*--------获取订单id？
- (void)getOrderId{
    
}

#pragma mark ----右侧按月份按钮事件
- (void)rightBtnTouched:(id)sender{

    tongjiVC *monthView = [[tongjiVC alloc]init];
    monthView.month = -1;
    [self pushViewController:monthView];
    
}
#pragma mark ----列表代理方法
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *Rcell = nil;
    
    if( _month == -1 )
    {
        Rcell = @"m_cell";
    }
    else
    {
        Rcell = @"O_cell";
    }
    
    SStatisic* obj = self.tempArray[indexPath.row];
    MLLog(@"%@",obj);
    
    tongjiCell *cell = (tongjiCell *)[tableView dequeueReusableCellWithIdentifier:Rcell];
    
    if ( _month == -1 ) {
        
        cell.myear.text = [NSString stringWithFormat:@"%d年",obj.mYear];
        cell.mMoth.text = [NSString stringWithFormat:@"%d月",obj.mMonth];
        cell.mall.text = [NSString stringWithFormat:@"成交%d笔",obj.mNum];
        cell.mtotal.text = [NSString stringWithFormat:@"¥%.02f元",obj.mTotal];
        
    }
    else
    {
        
    [cell.productNameImg sd_setImageWithURL:[NSURL URLWithString:obj.mImgURL] placeholderImage:[UIImage imageNamed:@"srvname"]];
        cell.productNameLb.text = [NSString stringWithFormat:@"作品:%@",obj.mSrvName];
    cell.timeLb.text = obj.mTimeStr;
    cell.priceLb.text = [NSString stringWithFormat:@"¥%.02f元",obj.mTotal];

    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.productNameImg.layer.masksToBounds = YES;
    cell.productNameImg.layer.cornerRadius = 3;
    return cell;
    
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tempArray.count;
//    return 5;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SStatisic* obj = self.tempArray[indexPath.row];

    MLLog(@"-//////-/-/-/--//--/-/:%@",obj);
    
    if( _month == -1 )
        
    {

        tongjiVC *monthView = [[tongjiVC alloc]init];
        monthView.month = obj.mMonth;
        monthView.myeaer = obj.mYear;
        [self pushViewController:monthView];
        
    }
    else if(_month == 0)
    {///进入统计详情页面
        
        orderMessageVC *orderVC = [[orderMessageVC alloc]init];
        
        orderVC.mtagorder = SOrder.new;
        
        orderVC.mtagorder.mId = obj.mOrderId;
        
        [self pushViewController:orderVC];
    }
}

@end
