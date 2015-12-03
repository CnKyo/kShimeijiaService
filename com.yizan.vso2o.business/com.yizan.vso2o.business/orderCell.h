//
//  orderCell.h
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/15.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CunsomLabel.h"
@interface orderCell : UITableViewCell
///日期时间标签
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLb;
///确认状态标签
@property (weak, nonatomic) IBOutlet UILabel *querenLb;
///产品标签
@property (weak, nonatomic) IBOutlet UILabel *productNameLb;

///订单编号标签
@property (weak, nonatomic) IBOutlet UILabel *orderCodeLb;
///客户姓名标签
@property (weak, nonatomic) IBOutlet UILabel *nameLb;
/////地址标签
@property (weak, nonatomic) IBOutlet CunsomLabel *address;


//@property (weak, nonatomic) IBOutlet UILabel *addressLb;
///价格标签
@property (weak, nonatomic) IBOutlet UILabel *priceLb;
///电话号码标签
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLb;

///路径导航按钮
@property (weak, nonatomic) IBOutlet UIButton *navgationBtn;
///联系顾客按钮
@property (weak, nonatomic) IBOutlet UIButton *connectionBtn;

@property (weak, nonatomic) IBOutlet UIView *lineView;

@property (weak, nonatomic) IBOutlet UIView *payStatusBgkVc;
@property (weak, nonatomic) IBOutlet UILabel *payStatusLb;
@property (weak, nonatomic) IBOutlet UIView *toplinebgkVC;
@property (weak, nonatomic) IBOutlet UIView *firstLine;
@property (weak, nonatomic) IBOutlet UIView *secondLine;

@end
