//
//  DatingCell.h
//  com.yizan.vso2o.business
//
//  Created by zzl on 15/4/16.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *mtime;
@property (weak, nonatomic) IBOutlet UILabel *msrvname;
@property (weak, nonatomic) IBOutlet UILabel *muserphone;
@property (weak, nonatomic) IBOutlet UILabel *madress;
@property (weak, nonatomic) IBOutlet UILabel *mtextS;

@property (weak, nonatomic) IBOutlet UIImageView *mcheckimg;
@end
