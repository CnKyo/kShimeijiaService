//
//  UILabel+myLabel.m
//  tour
//
//  Created by zzl on 14-10-6.
//  Copyright (c) 2014年 zzl. All rights reserved.
//

#import "UILabel+myLabel.h"

@implementation UILabel (myLabel)

-(void)autoReSizeWidthForContent:(CGFloat)maxW
{
    CGSize s = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(CGFLOAT_MAX, self.frame.size.height)];
    
    CGFloat w = s.width + self.alignmentRectInsets.left + self.alignmentRectInsets.right;
    CGRect f = self.frame;
    f.size.width = w > maxW ? maxW : w;
    self.frame = f;
    
}

@end
