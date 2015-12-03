//
//  updataView.h
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/17.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface updataView : UIView
@property (weak, nonatomic) IBOutlet UIView *bgkVC;
@property (weak, nonatomic) IBOutlet UIView *alertbgkVc;
@property (weak, nonatomic) IBOutlet UIButton *updataRightNowBtn;
@property (weak, nonatomic) IBOutlet UIButton *hulueUpdataBtn;
@property (weak, nonatomic) IBOutlet UILabel *updataMsg;

+(updataView *)share;
@end
