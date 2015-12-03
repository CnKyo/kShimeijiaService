//
//  orderMessageVC.m
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/15.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "orderMessageVC.h"
#import "orderMsg.h"

#import "verifyOrder.h"
#import "fuwuNeirong.h"
#import "customAlertView.h"
#import <MapKit/MapKit.h>

@interface orderMessageVC ()<UIScrollViewDelegate>
{
    UIButton *tempBtn;
    UIImageView *lineImage;
    int nowSelect;

    orderMsg *customOderMsgVC;
    verifyOrder *verifyOrderVC;
    fuwuNeirong *fuwuVC;
    customAlertView *alertVC;
    ///是否已经点击了服务按钮
    BOOL isselected;
    UIView * _topView;
    
    NSDate* _lastget;
    
    BOOL    _bdoing;
    
    int         _userid;

}
@end

@implementation orderMessageVC{
    
    CGFloat _Rightheight;
    
    CGFloat _Leftheight;
    
}
@synthesize msgStr;
@synthesize servceBtn;
- (void)loadView{
    self.hiddenTabBar = YES;
    [super loadView];
    self.contentView.needFix = YES;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   
}
- (void)viewDidLoad {
    
    MLLog(@"--------%@",_mtagorder);
    
    self.mPageName = @"订单详情";
    self.Title = self.mPageName;
    
    [super viewDidLoad];
    
    if ([SUser isNeedLogin]) {
        [self gotoLoginVC];
        return;
    }
    [self loadData];

}
- (void)loadData{
    
    [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeClear];
    
    [self.mtagorder getDetail:^(SResBase *retobj) {
        MLLog(@"retobj这是个什么玩意儿：%@",retobj);
        if( retobj.msuccess)
        {
            [SVProgressHUD dismiss];
            [self updatePageinfo];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:retobj.mmsg];
        }

    }];
 
}
-(void)updatePageinfo
{
    self.contentView.backgroundColor = [UIColor colorWithRed:0.957 green:0.933 blue:0.918 alpha:1];
    
    customOderMsgVC = [orderMsg shareView];
    [customOderMsgVC setFrame:CGRectMake(0, 0, 320, 95)];
    
    customOderMsgVC.productImg.layer.masksToBounds = YES;
    customOderMsgVC.productImg.layer.cornerRadius = 5;
    [customOderMsgVC.productImg sd_setImageWithURL:[NSURL URLWithString:_mtagorder.mGooods.mImgURL] placeholderImage:[UIImage imageNamed:@"img_def"]];
    customOderMsgVC.serviceNameLb.text = [NSString stringWithFormat:@"作品:%@",_mtagorder.mGooods.mName];
    customOderMsgVC.priceLb.text = [NSString stringWithFormat:@"计价方式:¥%.02f元/次",_mtagorder.mGooods.mPrice];
    
    int i;
    i = _mtagorder.mGooods.mDuration/60;
    if (i>60) {
        customOderMsgVC.serviceTimeLb.text = [NSString stringWithFormat:@"服务时长:%d小时/次",i/60];

    }
    else{
        customOderMsgVC.serviceTimeLb.text = [NSString stringWithFormat:@"服务时长:%d分钟/次",i];
    }
    
    [self.contentView addSubview:customOderMsgVC];
    
    verifyOrderVC = [verifyOrder share];
    [verifyOrderVC setFrame:CGRectMake(0, 140, 320, 391)];
    verifyOrderVC.topImgView.frame = CGRectMake(0, 8, 320, 0.4);
    
    verifyOrderVC.telphoneBtn.layer.masksToBounds = YES;
    verifyOrderVC.telphoneBtn.layer.cornerRadius = 3;
    verifyOrderVC.telphoneBtn.layer.borderColor = M_CO.CGColor;
    verifyOrderVC.telphoneBtn.layer.borderWidth = 1;
    
    verifyOrderVC.mapNavigationBtn.layer.masksToBounds = YES;
    verifyOrderVC.mapNavigationBtn.layer.cornerRadius = 3;
    verifyOrderVC.mapNavigationBtn.layer.borderColor = M_CO.CGColor;
    verifyOrderVC.mapNavigationBtn.layer.borderWidth = 1;
    
    [verifyOrderVC.mapNavigationBtn addTarget:self action:@selector(BtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [verifyOrderVC.telphoneBtn addTarget:self action:@selector(BtnAction:) forControlEvents:UIControlEventTouchUpInside];

    verifyOrderVC.serviceTimeLb.text = _mtagorder.mApptime;
    
    verifyOrderVC.userNmaeLb.text = _mtagorder.mUserName;
    verifyOrderVC.phoneNumLb.text = _mtagorder.mPhoneNum;
    verifyOrderVC.addressLb.text = _mtagorder.mAddress;
    verifyOrderVC.orderNumCodeLb.text = _mtagorder.mSn;
    verifyOrderVC.noteLb.text = _mtagorder.mReMark;
    verifyOrderVC.pricrLb.text = [NSString stringWithFormat:@"¥%.02f元",_mtagorder.mTotalMoney];
    if (_mtagorder.mPayState == 0) {
        verifyOrderVC.zhifuStatusLb.text = @"未支付";
    }
    else if(_mtagorder.mPayState == 1){
        verifyOrderVC.zhifuStatusLb.text = @"已支付";

    }
    [self.contentView addSubview:verifyOrderVC];
    
    fuwuVC = [fuwuNeirong shareView];
    
    fuwuVC.contentLb.numberOfLines = 0;
    fuwuVC.contentLb.text = _mtagorder.mServiceBrief;
 
    
    CGSize sss =  [fuwuVC.contentLb.text sizeWithFont:fuwuVC.contentLb.font constrainedToSize:CGSizeMake(fuwuVC.contentLb.frame.size.width, CGFLOAT_MAX)];
    
    CGFloat ffff = sss.height;
    if( ffff < fuwuVC.contentLb.frame.size.height )
        ffff = fuwuVC.contentLb.frame.size.height;
    else{
        ffff+=31;
    }
    CGRect rectFrame = fuwuVC.contentLb.frame;
    rectFrame.size.height = sss.height;
    fuwuVC.contentLb.frame = rectFrame;
    [fuwuVC setFrame:CGRectMake(0, 140, DEVICE_Width, ffff)];
    
    _Rightheight = fuwuVC.frame.origin.y+fuwuVC.frame.size.height;
    
    _Leftheight = 600;
    if (_Leftheight > _Rightheight) {
        
        _Rightheight = _Leftheight;
    }
    

    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 470, 320, 62)];
    view.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:view];
    
    servceBtn = [[UIButton alloc]initWithFrame:CGRectMake(25, verifyOrderVC.frame.size.height+10+145, 270, 45)];
    [servceBtn setBackgroundColor:M_CO];
    servceBtn.layer.masksToBounds = YES;
    servceBtn.layer.cornerRadius = 5;
    [servceBtn setTitle:@"开始服务" forState:UIControlStateNormal];
    [servceBtn addTarget:self action:@selector(serviceAcion:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:servceBtn];
    switch ([_mtagorder getUIShowbt]) {
        case E_UIShow_StartSrv:
        {
            [servceBtn setTitle:@"开始服务" forState:UIControlStateNormal];

        }
            break;
        case E_UIShow_CompleteSrv:
        {
            [servceBtn setTitle:@"服务完成" forState:UIControlStateNormal];

        }
            break;
            
        default:
            servceBtn.hidden = YES;
            break;
    }
    [self loadTopView];
    self.contentView.contentSize = CGSizeMake(280, _Leftheight);

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)tabAction:(UIGestureRecognizer *)sender{
    [alertVC removeFromSuperview];
}

#pragma mark－－－－顶部按钮事件
-(void)loadTopView
{

    if( !_topView )
    {
        _topView  = [[UIView alloc]initWithFrame:CGRectMake(0, 95, 320, 45)];
        
        _topView.backgroundColor = [UIColor whiteColor];
        float x = 0;
        for (int i =0; i<2; i++) {
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(x, 0, 160, 45)];
            [btn setTitle:@"订单确认" forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
            [btn setTitleColor:M_CO forState:UIControlStateNormal];
            [_topView addSubview:btn];
        

            if (i==1) {
                [btn setTitle:@"服务内容" forState:UIControlStateNormal];
                [btn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
            }
            else
            {
                tempBtn = btn;
                lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 70, 3)];
                lineImage.backgroundColor = M_CO;
                lineImage.center = btn.center;
                CGRect rect = lineImage.frame;
                rect.origin.y = 42;
                lineImage.frame = rect;
                [_topView addSubview:lineImage];
                nowSelect = 1;
            }
            btn.tag = 10+i;
            [btn addTarget:self action:@selector(topbtnTouched:) forControlEvents:UIControlEventTouchUpInside];
            x+=160;
        }
        
        UIImageView *xianimg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 44, 320, 1)];
        xianimg.backgroundColor  = COLOR(232, 232, 232);
        [_topView addSubview:xianimg];
        [self.contentView addSubview:_topView];
    }
    
}
-(void)topbtnTouched:(UIButton *)sender
{

    if (tempBtn == sender) {
        return;
    }
    else
    {
        if (sender.tag ==10) {
            NSLog(@"left");
            nowSelect = 1;
            [fuwuVC removeFromSuperview];
            [self.contentView addSubview:verifyOrderVC
             ];
            self.contentView.contentSize = CGSizeMake(280, _Leftheight);
            
            switch ([_mtagorder getUIShowbt]) {
                case E_UIShow_StartSrv:
                {
                    servceBtn.hidden = NO;
                    
                }
                    break;
                case E_UIShow_CompleteSrv:
                {
                    servceBtn.hidden = NO;
                    
                }
                    break;
                    
                default:
                    servceBtn.hidden = YES;

                    break;
            }


        }
        else
        {
            nowSelect = 2;
            NSLog(@"right");
            [verifyOrderVC removeFromSuperview];
            [self.contentView addSubview:fuwuVC];
            self.contentView.contentSize = CGSizeMake(280, _Rightheight);
            switch ([_mtagorder getUIShowbt]) {
                case E_UIShow_StartSrv:
                {
                    servceBtn.hidden = YES;
                }
                    break;
                case E_UIShow_CompleteSrv:
                {
                    servceBtn.hidden = YES;
                    
                }
                    break;
                default:
                    break;
            }

        }
        
        [self.tableView headerBeginRefreshing];
        
        [tempBtn setTitleColor:COLOR(126, 121, 124) forState:UIControlStateNormal];
        [sender setTitleColor:M_CO forState:UIControlStateNormal];
        tempBtn = sender;
        [UIView animateWithDuration:0.2 animations:^{
            lineImage.center = sender.center;
            CGRect rect = lineImage.frame;
            rect.origin.y = 42;
            lineImage.frame = rect;
            
        }];
        
    }
}
#pragma mark----服务按钮
#warning 服务完成不可再点击服务按钮
- (void)serviceAcion:(UIButton *)sender{
    
    switch ([_mtagorder getUIShowbt]) {
        case E_UIShow_StartSrv:
        {
            [SVProgressHUD showWithStatus:@"正在操作中..." maskType:SVProgressHUDMaskTypeClear];
            
            [_mtagorder startSrv:^(SResBase *resb) {
                if (resb.msuccess) {
                    [servceBtn setTitle:@"服务完成" forState:UIControlStateNormal];
                    [SVProgressHUD dismiss];
                }
                else{
                    [SVProgressHUD showErrorWithStatus:resb.mmsg];
                }
                
            }];
            
        }
            break;
        case E_UIShow_CompleteSrv:
        {
            [SVProgressHUD showWithStatus:@"正在操作中..." maskType:SVProgressHUDMaskTypeClear];
            [_mtagorder completeSrv:^(SResBase *resb) {
                if (resb.msuccess) {
                    servceBtn.hidden = YES;
                    [self initAlertView];
                    [SVProgressHUD showSuccessWithStatus:resb.mmsg];
                    
                }else{
                    [SVProgressHUD showErrorWithStatus:resb.mmsg];
                }
            }];
        }
            break;
            
        default:
            servceBtn.hidden = YES;
            break;
    }

 }
- (void)initAlertView{
    alertVC = [customAlertView shareView];
    
    [alertVC setFrame:CGRectMake(0, 0, 320, 480)];
    alertVC.bgView.backgroundColor = [UIColor colorWithRed:0.141 green:0.149 blue:0.184 alpha:0.4];
    alertVC.bgkVC.layer.masksToBounds = YES;
    alertVC.bgkVC.layer.cornerRadius = 5;
    alertVC.btn.layer.masksToBounds = YES;
    alertVC.btn.layer.cornerRadius = 5;
    [alertVC.btn addTarget:self action:@selector(okBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    int startTime = _mtagorder.mServiceStartTime;
    MLLog(@"开始时间%d",startTime);
    int endTime  = _mtagorder.mServiceFinishTime;
    MLLog(@"结束时间%d",endTime);

    int num = (endTime - startTime)/60;
    MLLog(@"最后的时间%d",num);

    if (num>60) {
        alertVC.contentLb.text = [NSString stringWithFormat:@"本次服务用时:%.1f小时",num/60.0f];
        
    }
    else{
        alertVC.contentLb.text = [NSString stringWithFormat:@"本次服务用时:%d分钟",num];
        
    }
    
    UITapGestureRecognizer *tapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tabAction:)];
    [self.contentView addGestureRecognizer:tapAction];
    [self.contentView addSubview:alertVC];
}
#pragma mark----自定义弹框消失
- (void)okBtn:(UIButton *)sender{
    
    [alertVC removeFromSuperview];
}
#pragma mark----拨打和导航按钮事件 1为拨打按钮 2为导航按钮
- (void)BtnAction:(UIButton *)sender{
    switch (sender.tag) {
        case 1:
        {
            NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",_mtagorder.mPhoneNum];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            
            
        }
            break;
        case 2:
        {
            
            
            SOrder *order =  self.mtagorder;
            
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
            break;
        default:
            break;
    }
}
@end
