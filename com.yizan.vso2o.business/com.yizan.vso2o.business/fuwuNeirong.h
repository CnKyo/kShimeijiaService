//
//  fuwuNeirong.h
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/15.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CunsomLabel.h"
@interface fuwuNeirong : UIView
@property (weak, nonatomic) IBOutlet UIView *lineBgkVC;
///内容
@property (weak, nonatomic) IBOutlet CunsomLabel *contentLb;

+(fuwuNeirong *)shareView;
@end
