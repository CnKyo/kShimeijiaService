//
//  messageCell.h
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/16.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface messageCell : UITableViewCell
///消息标签
@property (weak, nonatomic) IBOutlet UILabel *msgtitleLb;
///消息内容
@property (weak, nonatomic) IBOutlet UILabel *msgContentLb;
///发送的消息时间
@property (weak, nonatomic) IBOutlet UILabel *msgTimeLb;

@property (weak, nonatomic) IBOutlet UIImageView *msgPoint;

@end
