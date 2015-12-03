//
//  cmmtopview.m
//  com.yizan.vso2o.business
//
//  Created by zzl on 15/4/15.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "cmmtopview.h"
#import "myProcessView.h"

@interface cmmtopview ()

@end

@implementation cmmtopview

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _mhead.layer.cornerRadius = _mhead.frame.size.height/2;
    _mhead.layer.borderColor = [[UIColor clearColor] CGColor];
    _mhead.layer.borderWidth = 0.5f;
}


-(void)updatePageInfo
{
    SUser* nowuser = [SUser currentUser];
    if( nowuser )
    {
        [_mhead sd_setImageWithURL:[NSURL URLWithString:nowuser.mHeadImgURL] placeholderImage:[UIImage imageNamed:@"defultHead.png"]];
        _mname.text = nowuser.mUserName;
        
        if( nowuser.mStaff )
        {
            int allcount = nowuser.mStaff.mCommentTotalCount;
            if( allcount )
            {
                float gv = nowuser.mStaff.mCommentGoodCount / (float)allcount ;
               
                _mgoodtxt.text = [NSString stringWithFormat:@"%.1f%%",gv*100];
                [_mgoodpr setProcessValue:gv an:YES];
                gv = nowuser.mStaff.mCommentNeutralCount / (float)allcount;
                
                _mmidtxt.text = [NSString stringWithFormat:@"%.1f%%", gv*100];
                [_mmidpr setProcessValue:gv an:YES];
                gv =nowuser.mStaff.mCommentBadCount / (float)allcount;
                
                _mlowtxt.text = [NSString stringWithFormat:@"%.1f%%", gv*100];
                [_mlowpr setProcessValue:gv an:YES];
            }
        }
        
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
