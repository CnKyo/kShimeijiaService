//
//  NavBar.h
//  gameInfo
//
//  Created by lijiangang on 14-1-22.
//  Copyright (c) 2014年 lijiangang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NavBarDelegate <NSObject>

-(void)leftBtnTouched:(id)sender;
-(void)rightBtnTouched:(id)sender;
@end



@interface NavBar : UIView
@property (nonatomic,strong) UIButton *rightBtn;
@property (nonatomic,strong) UIButton *leftBtn;
@property (weak, nonatomic) id<NavBarDelegate>NavDelegate;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIImage *bgImage;
@property (nonatomic,strong) UIColor *bgColor;
-(void)setBgImage:(UIImage *)bgImage;
-(void)setBgColor:(UIColor *)bgColor;

@end

