//
//  DatingVC.m
//  com.yizan.vso2o.business
//
//  Created by zzl on 15/4/13.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "DatingVC.h"
#import "DatingCell.h"
#import "botomview.h"

#import "orderMessageVC.h"
@interface DatingVC ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@end

@implementation DatingVC
{
    UIView* _topselev;
    UIView* _lineview;
    UIButton* _lastcliecke;
    NSDate* _lastget;
    
    BOOL    _bdoing;
    
    int         _userid;

    
    BOOL    _nowseleted;
    
}

-(void)loadView
{
    if( _mbedit )
    {
        self.hiddenTabBar = YES;
    }
    [super loadView];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( [SUser isNeedLogin] )
    {
        [self gotoLoginVC];
        return;
    }
    
    if( !_mbedit ){
        
        if( _mSref )
            [self sReflush];
        else
            [self loadDat];
    }
    
}
-(void)sReflush
{
    [self updatePageInfo];
    [self.tableView reloadData];
}
-(void)loadDat
{
    if( _bdoing ) return;
    if( self.tempArray.count && _lastget && [_lastget timeIntervalSinceNow] < 60*5 &&
       _userid == [SUser currentUser].mUserId
       )
    {
        return;
    }
    
    _userid = [SUser currentUser].mUserId;
    
    _bdoing = YES;
    
    [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeClear];
    [SSchedule getSchedules:^(SResBase *resb, NSArray *all) {
        
        _bdoing = NO;
        _lastget = [NSDate date];
        if( resb.msuccess )
        {
            [SVProgressHUD dismiss];
            [self.tempArray addObjectsFromArray:all];
            [self updatePageInfo];
            [self.tableView headerBeginRefreshing];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
    }];
}
-(void)rightBtnTouched:(id)sender
{
    if( !_mbedit )
    {
        DatingVC* vc = [[DatingVC alloc]init];
        vc.mbedit = YES;
        vc.tempArray = [NSMutableArray arrayWithArray:self.tempArray];
        vc.mprevc = self;
        [self pushViewController:vc];
    }
}

- (void)viewDidLoad {
    self.Title = self.mPageName = @"日程安排";
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    if( !_mbedit )
    {
        self.rightBtnTitle = @"编辑";
        self.hiddenBackBtn = YES;
    }
    
    
    _topselev = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEVICE_Width, 60)];
    _topselev.backgroundColor = [UIColor whiteColor];
    
    
    float x = 0;
    UIButton* btall = [[UIButton alloc]initWithFrame:CGRectMake(x, 5, _topselev.frame.size.width/4, 50)];
    btall.titleLabel.numberOfLines = 2;
    btall.titleLabel.textAlignment = NSTextAlignmentCenter;
    //[btall setTitle:[NSString stringWithFormat:@"全部%d",tempsell.mCommentTotalCount] forState:UIControlStateNormal];
    [btall addTarget:self action:@selector(topclicked:) forControlEvents:UIControlEventTouchUpInside];
    btall.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    btall.tag = 50;
    [_topselev addSubview:btall];
    
    x +=_topselev.frame.size.width/4;
    
    UIView* vline = [[UIView alloc]initWithFrame:CGRectMake(x-0.5f, 0, 0.5, 60)];
    vline.backgroundColor = [UIColor colorWithRed:0.906 green:0.902 blue:0.898 alpha:1.000];
    [_topselev addSubview:vline];
    
    UIButton* good = [[UIButton alloc]initWithFrame:CGRectMake(x+0.5, 5, _topselev.frame.size.width/4, 50)];
    good.titleLabel.numberOfLines = 2;
    good.titleLabel.textAlignment = NSTextAlignmentCenter;
    //[good setTitle:[NSString stringWithFormat:@"好评%d",tempsell.mCommentGoodCount] forState:UIControlStateNormal];
    [good addTarget:self action:@selector(topclicked:) forControlEvents:UIControlEventTouchUpInside];
    good.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    good.tag = 51;
    [good setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_topselev addSubview:good];
    
    x +=_topselev.frame.size.width/4;
    vline = [[UIView alloc]initWithFrame:CGRectMake(x, 0, 0.5, 60)];
    vline.backgroundColor = [UIColor colorWithRed:0.906 green:0.902 blue:0.898 alpha:1.000];
    [_topselev addSubview:vline];
    
    UIButton* mid = [[UIButton alloc]initWithFrame:CGRectMake(x+0.5, 5, _topselev.frame.size.width/4, 50)];
    mid.titleLabel.numberOfLines = 2;
    mid.titleLabel.textAlignment = NSTextAlignmentCenter;
    //[mid setTitle:[NSString stringWithFormat:@"中评%d",tempsell.mCommentNeutralCount] forState:UIControlStateNormal];
    [mid addTarget:self action:@selector(topclicked:) forControlEvents:UIControlEventTouchUpInside];
    mid.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    mid.tag = 52;
    [mid setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_topselev addSubview:mid];
    
    
    x +=_topselev.frame.size.width/4;
    vline = [[UIView alloc]initWithFrame:CGRectMake(x, 0, 0.5, 60)];
    vline.backgroundColor = [UIColor colorWithRed:0.906 green:0.902 blue:0.898 alpha:1.000];
    [_topselev addSubview:vline];
    
    UIButton* bad = [[UIButton alloc]initWithFrame:CGRectMake(x+0.5f, 5, _topselev.frame.size.width/4, 50)];
    bad.titleLabel.numberOfLines = 2;
    bad.titleLabel.textAlignment = NSTextAlignmentCenter;
    //[bad setTitle:[NSString stringWithFormat:@"差评%d",tempsell.mCommentBadCount] forState:UIControlStateNormal];
    [bad addTarget:self action:@selector(topclicked:) forControlEvents:UIControlEventTouchUpInside];
    bad.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    bad.tag = 53;
    [bad setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_topselev addSubview:bad];
    x +=_topselev.frame.size.width/4;
    
    vline = [[UIView alloc]initWithFrame:CGRectMake(x, 0, 0.5, 60)];
    vline.backgroundColor = [UIColor colorWithRed:0.906 green:0.902 blue:0.898 alpha:1.000];
    [_topselev addSubview:vline];
    
    _lineview = [[UIView alloc]initWithFrame:CGRectMake(0, 57,_topselev.frame.size.width/4, 2)];
    _lineview.backgroundColor = M_CO;
    
    UIView* vv =[[UIView alloc]initWithFrame:CGRectMake(0, 59, _topselev.frame.size.width, 0.5f)];
    vv.backgroundColor = [UIColor colorWithRed:0.867 green:0.859 blue:0.859 alpha:1.000];
    [_topselev addSubview:vv];
    [_topselev addSubview:_lineview];
    
    _lastcliecke = nil;
    [self topclicked:btall];
    
    [self loadTableView:self.contentView.bounds delegate:self dataSource:self];
    self.haveHeader = YES;
    
    UINib* nib = [UINib nibWithNibName:@"DatingCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    nib = [UINib nibWithNibName:@"DatingCellS" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cellS"];
    
    if( _mbedit )
    {
        CGRect f = self.tableView.frame;
        f.size.height -= 65.0f;
        self.tableView.frame = f;
        
        botomview* tvc = [[botomview alloc]initWithNibName:@"botomview" bundle:nil];
       [self addChildViewController:tvc];
        
        f = tvc.view.frame;
        f.origin.x = 0;
        f.origin.y = self.contentView.bounds.size.height - 65.0f;
        tvc.view.frame = f;
        [self.contentView addSubview:tvc.view];
        tvc.msel = @selector(editblicked:);
        tvc.mtag = self;
        
    }
    
    [self updatePageInfo];
    [self.tableView reloadData];
    
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if( self.navigationController.viewControllers.count == 1 )  return NO;
    return YES;
}



-(void)editblicked:(UIButton*)sender
{
    NSInteger  j = _lastcliecke.tag - 50 ;
    SSchedule* one = self.tempArray[j];
    NSMutableArray* alllll = NSMutableArray.new;
    for (SScheduleItem* oneobj  in one.mSubInfo ) {
        if( sender.tag == 3 )
        {
            if( oneobj.mbStringInfo )
            {
                if( _nowseleted )
                {
                    [sender setTitle:@"全选" forState:UIControlStateNormal];
                    oneobj.mChecked = NO;
                }
                else
                {
                    [sender setTitle:@"取消全选" forState:UIControlStateNormal];
                    oneobj.mChecked = YES;
                }
            }
        }
        else
        {
            if( oneobj.mChecked )
            {
                [alllll addObject:oneobj];
            }
        }
    }
    
    if( sender.tag == 3 )
        _nowseleted = !_nowseleted;
    
    void(^itblock)(SResBase *resb, NSArray *all) = ^(SResBase *resb, NSArray *all){
        
        if( resb.msuccess )
        {
            [SVProgressHUD showSuccessWithStatus:resb.mmsg];
            [self.tempArray removeAllObjects];
            [self.tempArray addObjectsFromArray:all];
            
            _mprevc.mSref = YES;
            _mprevc.tempArray = [NSMutableArray arrayWithArray:self.tempArray];
            
            [self updatePageInfo];
            [self.tableView reloadData];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:resb.mmsg];
        }
        
    };
    
    if( sender.tag == 1 )
    {
        [SVProgressHUD showWithStatus:@"操作中..." maskType:SVProgressHUDMaskTypeClear];
        [SScheduleItem stopSrv:alllll block:itblock];
    }
    else if( sender.tag == 2 )
    {
        [SVProgressHUD showWithStatus:@"操作中..." maskType:SVProgressHUDMaskTypeClear];
        [SScheduleItem starSrv:alllll block:itblock];
    }
    else
    {
        [self.tableView reloadData];
    }
}


-(void)updatePageInfo
{
    for (int j  = 0; j < self.tempArray.count; j++) {
        
        SSchedule* oneobj = self.tempArray[j];
        
        UIButton* bt = (UIButton*)[_topselev viewWithTag:50+j];
        [bt setTitle:[NSString stringWithFormat:@"%@\n%@",oneobj.mStringDate,oneobj.mWeek] forState:UIControlStateNormal];
    }
    
}

-(void)topclicked:(UIButton*)sender
{
    if( _lastcliecke == sender) return;
    
    [_lastcliecke setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sender setTitleColor:_lineview.backgroundColor forState:UIControlStateNormal];
    _lastcliecke = sender;
    _lineview.tag = sender.tag - 50;
    
    [UIView animateWithDuration:0.15 animations:^{
        
        CGRect f = _lineview.frame;
        f.origin.x = _lastcliecke.frame.origin.x;
        _lineview.frame = f;
        
    }];
    
    
    [self.tableView headerBeginRefreshing];
}

-(void)headerBeganRefresh
{
    [SSchedule getSchedules:^(SResBase *resb, NSArray *all) {
        
        [self.tableView headerEndRefreshing];
        
        [self.tempArray removeAllObjects];
        if( resb.msuccess )
        {
            [self.tempArray addObjectsFromArray:all];
            [self updatePageInfo];
            [self.tableView reloadData];
        }
        
        if ( self.tempArray.count == 0 ) {
            
            [self addEmptyViewWithImg:nil];
        }
        else
        {
            [self removeEmptyView];
        }
        
    }];
    
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger  j = _lastcliecke.tag - 50 ;
    if( j < self.tempArray.count )
    {
        SSchedule* one = self.tempArray[j];
        return one.mSubInfo.count;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _topselev.bounds.size.height;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _topselev;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* Rcell = nil;
    NSInteger  j = _lastcliecke.tag - 50 ;
    SSchedule* one = self.tempArray[j];
    SScheduleItem* onesub = one.mSubInfo[indexPath.row];
    if( onesub.mbStringInfo )
    {
        Rcell = @"cellS";
    }
    else
    {
        Rcell = @"cell";
    }
    
    DatingCell* cell = [tableView dequeueReusableCellWithIdentifier:Rcell];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.mtime.text = onesub.mTimeStr;
    
    if( onesub.mbStringInfo )
    {
        cell.mtextS.text = onesub.mStr;
    }
    else
    {
        if( onesub.mSrvName.length != 0 )
            cell.msrvname.text = onesub.mSrvName;
        else
            cell.msrvname.text = @"";
        
        if( onesub.mUserName.length != 0 )
            cell.muserphone.text = [NSString stringWithFormat:@"%@%@",onesub.mUserName,onesub.mPhone ];
        else
            cell.muserphone.text = @"";
        
        if( onesub.mAddress.length != 0 )
            cell.madress.text = [NSString stringWithFormat:@"%@",onesub.mAddress];
        else
            cell.madress.text = @"";
    }
    
    
    if( onesub.mChecked )
    {
        cell.mcheckimg.image = [UIImage imageNamed:@"paychoose"];
    }
    else
    {
        cell.mcheckimg.image = [UIImage imageNamed:@"paynotchoos"];
    }
    
    if( _mbedit )
        cell.mcheckimg.hidden = NO;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger  j = _lastcliecke.tag - 50 ;
    SSchedule* one = self.tempArray[j];
    
    SScheduleItem* onesub = one.mSubInfo[indexPath.row];

    if (_mbedit) {
        onesub.mChecked = !onesub.mChecked;
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
    else if(!onesub.mbStringInfo){
        
        orderMessageVC *oderMsgVC = [[orderMessageVC alloc]init];
        oderMsgVC.mtagorder = SOrder.new;
        oderMsgVC.mtagorder.mId = onesub.mOrder.mId;
        
        [self pushViewController:oderMsgVC];
    }




    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
