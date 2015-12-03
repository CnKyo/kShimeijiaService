//
//  messageDetailView.m
//  com.yizan.vso2o.business
//
//  Created by 密码为空！ on 15/4/17.
//  Copyright (c) 2015年 zy. All rights reserved.
//

#import "messageDetailView.h"
@interface messageDetailView ()<UIWebViewDelegate>

@end

@implementation messageDetailView
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([SUser isNeedLogin]) {
        [self gotoLoginVC];
        return;
    }
}
- (void)loadView{
    [super loadView];
    self.mPageName = @"消息";
    self.Title = self.mPageName;
    
    self.hiddenTabBar = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view from its nib.
}
#pragma mark----普通消息页面
- (void)initView{
    _msgTitle.text = _msgObj.mTitle;
    _msgContentLb.text = _msgObj.mContent;
    _msgTimeLb.text = _msgObj.mDateStr;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark----webview的代理方法
- (void)webViewDidStartLoad:(UIWebView *)webView{
    MLLog(@"开始加载");
    
}

- (void)webViewDidFinishLoad:(UIWebView *)web{
    
    MLLog(@"结束加载");

}

-(void)webView:(UIWebView*)webView  DidFailLoadWithError:(NSError*)error{
    MLLog(@"加载错误");

    
}

@end
