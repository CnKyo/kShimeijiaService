//
//  dateModel.m
//  YiZanService
//
//  Created by zzl on 15/3/19.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "dateModel.h"
#import "NSObject+myobj.h"
#import "APIClient.h"
#import "Util.h"
#import "OSSClient.h"
#import "OSSTool.h"
#import "OSSData.h"
#import "OSSLog.h"
#import "OSSBucket.h"
#import <CoreLocation/CoreLocation.h>
#import <QMapKit/QMapKit.h>
#import "AppDelegate.h"
#import "AFURLSessionManager.h"
#import "PartnerConfig.h"
#import "DataSigner.h"
#import "AlixPayResult.h"
#import "DataVerifier.h"
#import "AlixPayOrder.h"
#import "AlixLibService.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "APService.h"

@implementation dateModel

@end

@interface SResBase()

@property (nonatomic,strong)    id mcoredat;

@end

@implementation SResBase


-(id)initWithObj:(NSDictionary *)obj
{
    self = [super init];
    if( self && obj != nil )
    {
        [self fetchIt:obj];
        self.mcoredat = obj;
    }
    return self;
}

-(void)fetchIt:(NSDictionary *)obj
{
    _mcode = [[obj objectForKeyMy:@"code"] intValue];
    _msuccess = _mcode == 0;
    self.mmsg = [obj objectForKeyMy:@"msg"];
    self.mdebug = [obj objectForKeyMy:@"debug"];
    self.mdata = [obj objectForKey:@"data"];
}

+(SResBase*)infoWithError:(NSString*)error
{
    SResBase* retobj = SResBase.new;
    retobj.mcode = 1;
    retobj.msuccess = NO;
    retobj.mmsg = error;
    return retobj;
}
@end

@implementation SUserState

-(id)initWithObj:(NSDictionary*)dic
{
    self = [super init];
    if( self )
    {
        self.mbHaveNewMsg = [[dic objectForKeyMy:@"hasNewMessage"] boolValue];
    }
    return self;
}

@end

@interface SUser()

@property (nonatomic,strong)    id  mcoredat;

@end

@implementation SUser

static SUser* g_user = nil;
///返回当前用户
+(SUser*)currentUser
{
    if( g_user ) return g_user;
    @synchronized(self) {
        
        if ( !g_user )
        {
            g_user = [SUser loadUserInfo];
        }
        return g_user;
    }
}

+(void)saveUserInfo:(id)dccat
{
    dccat = [Util delNUll:dccat];
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    [def setObject:dccat forKey:@"userInfo"];
    [def synchronize];
}

+(SUser*)loadUserInfo
{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSDictionary* dat = [def objectForKey:@"userInfo"];
    if( dat )
    {
        SUser* tu = [[SUser alloc]initWithObj:dat];
        return tu;
    }
    return nil;
}
+(NSDictionary*)loadUserJson
{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    return [def objectForKey:@"userInfo"];
}

+(void)cleanUserInfo
{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    [def setObject:nil forKey:@"userInfo"];
    [def synchronize];
}

///判断是否需要登录
+(BOOL)isNeedLogin
{
    return [SUser currentUser] == nil;
}

///退出登陆
+(void)logout
{
    
    [SUser cleanUserInfo];
    g_user = nil;
    
    [[APIClient sharedClient] postUrl:@"user.logout" parameters:nil call:^(SResBase *info) {
        
    }];
    
    [SUser clearTokenWithPush];
    
}
///发送短信
+(void)sendSM:(NSString*)phone block:(void(^)(SResBase* resb))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:phone forKey:@"mobile"];
    
    [[APIClient sharedClient] postUrl:@"user.mobileverify" parameters:param call:^(SResBase *info) {
        block( info );
    }];
}

+(void)loginWithPhoneSMCode:(NSString*)phone smcode:(NSString*)smcode block:(void(^)(SResBase* resb, SUser*user))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:phone forKey:@"mobile"];
    [param setObject:smcode forKey:@"verifyCode"];
    
    [[APIClient sharedClient] postUrl:@"user.verifylogin" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess && info.mdata)
        {
            NSDictionary* tmpdic = info.mdata;
            
            NSMutableDictionary* tdic = [[NSMutableDictionary alloc]initWithDictionary:info.mdata];
            NSString* fucktoken = [info.mcoredat objectForKeyMy:@"token"];
            if( fucktoken )
                [tdic setObject:fucktoken forKey:@"token"];
            SUser* tu = [[SUser alloc]initWithObj:tdic];
            tmpdic = tdic;
            
            if( tu )
            {
                [SUser saveUserInfo: tmpdic];
                [SUser relTokenWithPush];
            }
        }
        
        block( info , [SUser currentUser] );
        
    }];
}


///登录,
+(void)loginWithPhone:(NSString*)phone psw:(NSString*)psw block:(void(^)(SResBase* resb, SUser*user))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:phone forKey:@"mobile"];
    [param setObject:psw forKey:@"pwd"];
    
    [[APIClient sharedClient] postUrl:@"user.login" parameters:param call:^(SResBase *info) {

        if( info.msuccess && info.mdata)
        {
            NSDictionary* tmpdic = info.mdata;
 
            NSMutableDictionary* tdic = [[NSMutableDictionary alloc]initWithDictionary:info.mdata];
            NSString* fucktoken = [info.mcoredat objectForKeyMy:@"token"];
            if( fucktoken )
                [tdic setObject:fucktoken forKey:@"token"];
            SUser* tu = [[SUser alloc]initWithObj:tdic];
            tmpdic = tdic;
            
            if( tu )
            {
                [SUser saveUserInfo: tmpdic];
                [SUser relTokenWithPush];
            }
        }
        
        block( info , [SUser currentUser] );

    }];
}

///注册
+(void)regWithPhone:(NSString*)phone psw:(NSString*)psw smcode:(NSString*)smcode  block:(void(^)(SResBase* resb, SUser*user))block
{
    [SUser RRWithPhone:phone newpsw:psw smcode:smcode breg:YES block:block];
}

///重置密码
+(void)reSetPswWithPhone:(NSString*)phone newpsw:(NSString*)newpsw smcode:(NSString*)smcode  block:(void(^)(SResBase* resb, SUser*user))block
{
    [SUser RRWithPhone:phone newpsw:newpsw smcode:smcode breg:NO block:block];
}
+(void)RRWithPhone:(NSString*)phone newpsw:(NSString*)newpsw smcode:(NSString*)smcode breg:(BOOL)breg block:(void(^)(SResBase* resb, SUser*user))block
{
    
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:phone forKey:@"mobile"];
    [param setObject:newpsw forKey:@"pwd"];
    [param setObject:smcode forKey:@"verifyCode"];
    [param setObject:breg?@"reg":@"repwd" forKey:@"type"];
    
    [[APIClient sharedClient] postUrl:@"user.reg" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            
            NSDictionary* tmpdic = info.mdata;
 
            NSMutableDictionary* tdic = [[NSMutableDictionary alloc]initWithDictionary:info.mdata];
            NSString* fucktoken = [info.mcoredat objectForKeyMy:@"token"];
            if( fucktoken )
                [tdic setObject:fucktoken forKey:@"token"];
            SUser* tu = [[SUser alloc]initWithObj:tdic];
            tmpdic = tdic;
 
            
            if( tu )
            {
                [SUser relTokenWithPush];
                [SUser saveUserInfo:tmpdic];//直接保存就行了,当前肯定是退出登陆状态才可以注册,重置密码
                
                [tu getMyAddress:^(SResBase *resb, NSArray *arr) {
                    
                    
                }];
            }
        }
        block( info , [SUser currentUser] );
    }];
}

-(SAddress*)getDefault
{
    return [SAddress loadDefault];
}

-(id)initWithObj:(NSDictionary *)obj
{
    self = [super init];
    if( self && obj != nil )
    {
        [self fetchIt:obj];
    }
    return self;
}

-(void)fetchIt:(NSDictionary *)obj
{
    NSDictionary* tud = [obj objectForKeyMy:@"user"];
    _mUserId = [[tud objectForKeyMy:@"id"] intValue];
    self.mUserName = [tud objectForKeyMy:@"name"];
    self.mHeadImgURL = [tud objectForKeyMy:@"avatar"];
    self.mPhone = [tud objectForKeyMy:@"mobile"];
    self.mToken = [obj objectForKeyMy:@"token"];
    
    self.mStaff = [[SStaff alloc]initWithObj: [obj objectForKeyMy:@"staff"] ];
    
    self.mUserName = self.mStaff.mName;
    self.mHeadImgURL = self.mStaff.mLogoURL;
    self.mPhone = self.mStaff.mMobile;
    
    
    //self.mSeller = [[SSeller alloc]initWithObj: [obj objectForKeyMy:@"seller"]];
    _mUserId = self.mStaff.mId;
    self.mCity = [[tud objectForKeyMy:@"city"] objectForKeyMy:@"name"];
}

#define APPKEY  @"y9HMbWcxVmhnX0N1"
#define APPSEC  @"2x6zpBZUpeOzJtyn2CisXgPjf8fPQV"

///修改用户信息,修改成功会更新对应属性
-(void)updateUserInfo:(NSString*)name HeadImg:(UIImage*)Head block:(void(^)(SResBase* resb,BOOL bok ,float process))block
{
    NSString* filepath = nil;
    if( Head )
    {//上传头像
        [SVProgressHUD showWithStatus:@"正在保存头像..."];
        OSSClient* _ossclient = [OSSClient sharedInstanceManage];
        NSString *accessKey = APPKEY;
        NSString *secretKey = APPSEC;
        [_ossclient setGenerateToken:^(NSString *method, NSString *md5, NSString *type, NSString *date, NSString *xoss, NSString *resource){
            NSString *signature = nil;
            NSString *content = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@%@", method, md5, type, date, xoss, resource];
            signature = [OSSTool calBase64Sha1WithData:content withKey:secretKey];
            signature = [NSString stringWithFormat:@"OSS %@:%@", accessKey, signature];
            //NSLog(@"here signature:%@", signature);
            return signature;
        }];
        
        OSSBucket* _ossbucket = [[OSSBucket alloc] initWithBucket:@"vso2o"];
        NSData *dataObj = UIImageJPEGRepresentation(Head, 1.0);
        filepath = [SUser makeFileName:@"jpg"];
        OSSData *testData = [[OSSData alloc] initWithBucket:_ossbucket withKey:filepath];
        [testData setData:dataObj withType:@"jpg"];
        [testData uploadWithUploadCallback:^(BOOL bok, NSError *err) {
            if( !bok )
            {
                SResBase* resb = [SResBase infoWithError:err.description];
                block( resb,YES,0.0f );
            }
            else
            {
                [self realUpdate:name file:filepath block:block];
            }
            
        } withProgressCallback:^(float process) {
            
            NSLog(@"process:%f",process);
          //  block(nil,NO,process);
            
        }];
    }
    else
    {
        [self realUpdate:name file:nil block:block];
    }
}
-(void)realUpdate:(NSString*)name file:(NSString*)file block:(void(^)(SResBase* resb,BOOL bok ,float process))block
{
    NSMutableDictionary *param = NSMutableDictionary.new;
    if( name.length )
        [param setObject:name forKey:@"name"];
    if( file.length )
        [param setObject:file forKey:@"avatar"];
    
    [[APIClient sharedClient] postUrl:@"user.info.update" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            self.mUserName = [info.mdata objectForKeyMy:@"name"];
            self.mHeadImgURL = [info.mdata objectForKeyMy:@"avatar"];
            NSDictionary* nowdir = [SUser loadUserJson];
            if( nowdir )
            {
                NSMutableDictionary* n = [[NSMutableDictionary alloc]initWithDictionary:nowdir];
                [n setObject:self.mToken forKey:@"token"];
                NSMutableDictionary* usernode = [[NSMutableDictionary alloc]initWithDictionary:[n objectForKeyMy:@"user"]];
                if( self.mHeadImgURL.length )
                {
                    [usernode setObject:self.mHeadImgURL forKey:@"avatar"];
                }
                if( self.mUserName.length )
                {
                    [usernode setObject:self.mUserName forKey:@"name"];
                }
                [n setObject:usernode forKey:@"user"];
                [SUser saveUserInfo:n];
            }
        }
        block( info,YES,0.0f);
    }];
}


///获取优惠卷 arr ==> SPromotion bgetexp 是否获取过期的,
-(void)getMyPromotion:(BOOL)bgetexp page:(int)page block:(void(^)(SResBase* resb,NSArray* arr))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt( bgetexp?1:0 ) forKey:@"status"];
    [param setObject:NumberWithInt( page ) forKey:@"page"];
    [[APIClient sharedClient]postUrl:@"user.promotion.lists" parameters:param call:^(SResBase *info) {
       
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tar = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                [tar addObject: [[SPromotion alloc]initWithObj:one] ];
            }
            t = tar;
        }
        block( info,t);
    }];
}

///兑换一个优惠卷
-(void)exChangeOnePromotion:(NSString*)sncode block:(void(^)(SResBase* resb,SPromotion* one ))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:sncode forKey:@"sn"];
    [[APIClient sharedClient]postUrl:@"user.promotion.exchange" parameters:param call:^(SResBase *info) {
        SPromotion* oneobj = nil;
        if( info.msuccess )
        {
            oneobj = [[SPromotion alloc] initWithObj: info.mdata];
        }
        block( info , oneobj );
    }];
}

///添加常用地址
-(void)addAddress:(NSString*)address lng:(float)lng lat:(float)lat block:(void(^)(SResBase* resb , SAddress* retobj ))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:address forKey:@"address"];
    [param setObject:[NSString stringWithFormat:@"%.6f,%.6f",lat,lng] forKey:@"mapPoint"];
    [[APIClient sharedClient]postUrl:@"user.address.create" parameters:param call:^(SResBase *info) {
       
        SAddress* retobj = nil;
        if( info.msuccess )
        {
            retobj = [[SAddress alloc]initWithObj:info.mdata];
        }
        block( info , retobj);
        
    }];
}

///获取地址
-(void)getMyAddress:(void(^)(SResBase* resb,NSArray* arr))block
{
    [[APIClient sharedClient]postUrl:@"user.address.lists" parameters:nil call:^(SResBase *info) {
        
        NSArray* reta  = nil;
        if( info.msuccess )
        {
            NSMutableArray* tar = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata  ) {
                [tar addObject: [[SAddress alloc]initWithObj: one] ];
            }
            reta = tar;
        }
        block( info , reta );
    }];
}

-(void)getFavGoodList:(int)page block:(void(^)(SResBase* resb,NSArray* arr))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt( page ) forKey:@"page"];
    [[APIClient sharedClient] postUrl:@"collect.goods.lists" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tmpa = NSMutableArray.new;
            for ( NSDictionary *one in info.mdata ) {
                SGoods* tmpone = [[SGoods alloc]initWithObj:[one objectForKeyMy:@"goods"]];
                tmpone.mFav = YES;
                [tmpa addObject:tmpone ];
            }
            t = tmpa;
        }
        block( info,t);
    }];
}

-(void)getFavSellerList:(int)page block:(void(^)(SResBase* resb,NSArray* arr))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt( page ) forKey:@"page"];
    [[APIClient sharedClient] postUrl:@"collect.seller.lists" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tmpa = NSMutableArray.new;
            for ( NSDictionary *one in info.mdata ) {
                SSeller* tmpone = [[SSeller alloc]initWithObj:[one objectForKeyMy:@"seller"]];
                tmpone.mFav = YES;
                [tmpa addObject:tmpone];
            }
            t = tmpa;
        }
        block( info,t);
    }];
}

-(void)getMyOrdersForSeller:(int)status page:(int)page block:(void(^)(SResBase* resb,NSArray* all))block;
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(status) forKey:@"status"];;
    [param setObject:NumberWithInt(page) forKey:@"page"];
    [[APIClient sharedClient] postUrl:@"order.lists" parameters:param call:^(SResBase *info) {
    
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* retall = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                [retall addObject: [[SOrder alloc]initWithObj:one]];
            }
            t = retall;
        }
        block(info,t);
    }];
}
///获取我的订单,,
///status "0：所有订单 ,1：进行中 ,2：待评价"
-(void)getMyOrders:(int)status page:(int)page block:(void(^)(SResBase* resb,NSArray* all))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(status-1) forKey:@"status"];;
    [param setObject:NumberWithInt(page) forKey:@"page"];
    [[APIClient sharedClient] postUrl:@"order.lists" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tar = NSMutableArray.new;
            for (NSDictionary* one in info.mdata ) {
                [tar addObject: [[SOrder alloc] initWithObj:one] ];
            }
            t = tar;
        }
        block(info,t);
    }];
}

-(void)getMyMsg:(int)page block:(void(^)(SResBase* resb,NSArray* all ))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(page) forKey:@"page"];
    [[APIClient sharedClient] postUrl:@"order.lists" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tar = NSMutableArray.new;
            for (NSDictionary* one in info.mdata ) {
                [tar addObject: [[SOrder alloc] initWithObj:one] ];
            }
            t = tar;
        }
        block(info,t);
    }];
    
}
static int g_index = 0;
+(NSString*)makeFileName:(NSString*)extName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString* t = [dateFormatter stringFromDate:[NSDate date]];
    
    [dateFormatter setDateFormat:@"HH-mm-ss"];
    NSString* s = [dateFormatter stringFromDate:[NSDate date]];
    g_index++;
    
    return [NSString stringWithFormat:@"temp/%@/%d_%u_%@.%@",t,[SUser currentUser].mUserId,g_index,s,extName];
}


+(void)clearTokenWithPush
{
    [APService setTags:[NSSet set]  alias:@"" callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:[UIApplication sharedApplication].delegate];
}
+(void)relTokenWithPush
{
    NSString* t = [NSString stringWithFormat:@"%d", [SUser currentUser].mUserId];
    if( t.length == 0 )
        t = @"0";
    
    t = [@"staff_" stringByAppendingString:t];
    
    //别名
    //1."seller_1"
    //2."buyer_1"
    
    
    //标签
    //1."seller"/"buyer"
    //2."重庆"/...
    NSSet* labelset = nil;
    if( [SUser currentUser].mCity != nil )
        labelset = [[NSSet alloc]initWithObjects:@"staff",[NSString stringWithFormat:@"%@",[SUser currentUser].mCity] , @"ios",nil];
    else
        labelset = [[NSSet alloc]initWithObjects:@"staff", @"ios",nil];
    [APService setTags:labelset alias:t callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:[UIApplication sharedApplication].delegate];
}

-(void)getUserState:(void(^)(SResBase* resb ,SUserState* userstate))block
{
    [[APIClient sharedClient] postUrl:@"user.msgStatus" parameters:nil call:^(SResBase *info) {
       
        if( info.msuccess )
        {
            SUserState* retobj = [[SUserState alloc]initWithObj:info.mdata];
            block(info,retobj);
        }
        else
        {
            block(info,nil);
        }
    }];
}


@end


static GInfo* g_info = nil;
@implementation GInfo
{
}

+(GInfo*)shareClient
{
    if( g_info ) return g_info;
    @synchronized(self) {
        
        if ( !g_info )
        {
            GInfo* t = [GInfo loadGInfo];
            if( [t isGInfoVaild] )
                g_info = t;
        }
        return g_info;
    }
}
-(BOOL)isGInfoVaild
{//这个全局数据是否有效,,目前只判断了,token,应该判断所有的字段,:todo
    return self.mGToken.length > 0;
}
-(id)initWithObj:(NSDictionary *)obj
{
    self = [super init];
    if( self && obj != nil )
    {
        [self fetchIt:obj];
    }
    return self;
}
-(void)fetchIt:(NSDictionary *)obj
{
    self.mGToken = [obj objectForKeyMy:@"token"];
    NSString* sssssss = [obj objectForKeyMy:@"key"];
    if( sssssss.length )
    {
        char keyPtr[10]={0};
        [sssssss getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
        self.mivint  = (int)strtoul(keyPtr,NULL,24);
    }
    
    NSDictionary* data = [obj objectForKeyMy:@"data"];
    NSArray* tt = [data objectForKeyMy:@"citys"];
    NSMutableArray* t = NSMutableArray.new;
    for ( NSDictionary* one in tt ) {
        [t addObject: [[SCity alloc]initWithObj:one] ];
    }
    self.mSupCitys = t;
    
    tt = [data objectForKeyMy:@"payments"];
    t = NSMutableArray.new;
    for (NSDictionary* one in tt ) {
        [t addObject: [[SPayment alloc]initWithObj: one]];
    }
    
    self.mPayments = t;
    
    self.mAppVersion    = [data objectForKeyMy:@"appVersion"];
    self.mForceUpgrade  = [[data objectForKeyMy:@"forceUpgrade"] boolValue];
    self.mAppDownUrl    = [data objectForKeyMy:@"appDownUrl"];
    self.mUpgradeInfo   = [data objectForKeyMy:@"upgradeInfo"];
    self.mServiceTel    = [data objectForKeyMy:@"serviceTel"];
    
    if(  [self.mAppVersion isEqualToString:[Util getAppVersion]] )
    {
        self.mAppDownUrl = nil;
    }
    
}
static bool g_blocked = NO;
static bool g_startlooop = NO;
+(void)getGInfoForce:(void(^)(SResBase* resb, GInfo* gInfo))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:DeviceType()   forKey:@"systemInfo"];
    [param setObject:@"ios"  forKey:@"deviceType"];
    [param setObject:DeviceSys()    forKey:@"systemVersion"];
    NSString *version =  [Util getAppVersion];
    [param setObject:version  forKey:@"appVersion"];
    [[APIClient sharedClient] postUrl:@"app.init" parameters:param call:^(SResBase *info) {
        if( info.msuccess )
        {//如果网络获取成功,并且数据有效,就覆盖本地的,
            GInfo* obj = [[GInfo alloc] initWithObj: info.mcoredat];
            if( [obj isGInfoVaild] )
            {//有效
                [GInfo saveGInfo:info.mcoredat];
                obj = [GInfo shareClient] ;
                if( [obj isGInfoVaild] )
                {
                    block( info, obj);
                    return ;
                }
            }
        }
        
        block(info,nil);
    }];
}
+(void)getGInfo:(void(^)(SResBase* resb, GInfo* gInfo))block
{
    if( !g_startlooop )
    {
        GInfo* s = [GInfo shareClient];
        if( s )
        {
            SResBase* objret = [[SResBase alloc]init];
            objret.msuccess = YES;
            
            block( objret , s );
            g_blocked = YES;
        }
    }
    
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:DeviceType()   forKey:@"systemInfo"];
    [param setObject:@"ios"  forKey:@"deviceType"];
    [param setObject:DeviceSys()    forKey:@"systemVersion"];
    NSString *version =  [Util getAppVersion];
    [param setObject:version  forKey:@"appVersion"];
    [[APIClient sharedClient] postUrl:@"app.init" parameters:param call:^(SResBase *info) {
        if( info.msuccess )
        {//如果网络获取成功,并且数据有效,就覆盖本地的,
            GInfo* obj = [[GInfo alloc] initWithObj: info.mcoredat];
            if( [obj isGInfoVaild] )
            {//有效
                [GInfo saveGInfo:info.mcoredat];
                obj = [GInfo shareClient] ;
                if( [obj isGInfoVaild] )
                {
                    if( !g_blocked )
                    {
                        g_blocked = YES;
                        block( info, obj);
                    }
                    
                    if( g_startlooop )
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserGinfoSuccess" object:nil];
                    return ;//这里就不用再下去了,,
                }
            }
        }
        else
        {
            //这里就是,没有网络或者数据无效了,就本地看看
            GInfo* tmp = [GInfo shareClient];
            if( tmp )
            {//如果本地有也可以
                if( !g_blocked )
                {
                    g_blocked = YES;
                    block(info,tmp);
                }
            }
            else
            {
                //连本地都没得,,,那么要一直循环获取了,,直到成功为止
                if( !g_blocked )
                {
                    g_blocked = YES;
                    
                    block([SResBase infoWithError:@"获取配置信息失败"] ,nil);
                }
                [GInfo loopGInfo];
            }
        }
    }];
}
+(void)loopGInfo
{
    g_startlooop = YES;
    MLLog(@"loopGInfo...");
    int64_t delayInSeconds = 1.0*20;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [GInfo getGInfo:^(SResBase *resb, GInfo *gInfo) {
            
            
        }];
        
    });
}
+(void)saveGInfo:(id)dat
{
    dat = [Util delNUll:dat];
    
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    [def setObject:dat  forKey:@"GInfo"];
    [def synchronize];
}
+(GInfo*)loadGInfo
{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSDictionary* dat = [def objectForKey:@"GInfo"];
    if( dat)
    {
        return [[GInfo alloc]initWithObj:dat];
    }
    return nil;
}

-(SPayment*)geAiPayInfo
{
    
    for ( SPayment* one in _mPayments ) {
        
        if( one.mPartnerId != nil )
            return one;
    }
    return nil;
}

-(SPayment*)geWxPayInfo
{
    for ( SPayment* one in _mPayments ) {
        
        if( one.mAppId != nil )
            return one;
    }
    return nil;
}



@end

@implementation SCity
-(id)initWithObj:(NSDictionary *)obj
{
    self = [super init];
    if( self && obj != nil )
    {
        self.mId = [[obj objectForKeyMy:@"id"] intValue];
        self.mName = [obj objectForKeyMy:@"name"];
        self.mFirstChar = [obj objectForKeyMy:@"firstChar"];
        self.mIsDefault = [[obj objectForKeyMy:@"isDefault"] boolValue];
    }
    return self;
}

@end

@implementation SWxPayInfo
-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self && obj )
    {
        self.mpartnerId = [obj objectForKeyMy:@"partnerid"];//	string	是			商户号
        self.mprepayId = [obj objectForKeyMy:@"prepayid"];//	string	是			预支付交易会话标识
        self.mpackage = [obj objectForKeyMy:@"packages"];//	string	是			扩展字段
        self.mnonceStr = [obj objectForKeyMy:@"noncestr"];//	string	是			随机字符串
        self.mtimeStamp = [[obj objectForKeyMy:@"timestamp"] intValue];//	int	是			时间戳
        self.msign = [obj objectForKeyMy:@"sign"];//	string	是			签名
        
    }
    return self;
}


@end
@implementation SPayment

-(id)initWithObjWX:(NSDictionary *)obj
{
    self = [super init];
    if( self )
    {
        self.mCode = [obj objectForKeyMy:@"code"];
        self.mName = [obj objectForKeyMy:@"name"];
        NSDictionary* cfg = [obj objectForKeyMy:@"config"];
        self.mAppId = [cfg objectForKeyMy:@"appId"];
        self.mAppSecret = [cfg objectForKeyMy:@"appSecret"];
        self.mWxPartnerId = [cfg objectForKeyMy:@"partnerId"];
        self.mWxPartnerkey = [cfg objectForKeyMy:@"partnerKey"];
    }
    return self;
}

-(id)initWithObj:(NSDictionary *)obj
{
    self = [super init];
    if( self && obj != nil )
    {
        self.mCode = [obj objectForKeyMy:@"code"];
        self.mName = [obj objectForKeyMy:@"name"];
        NSDictionary*   objali = [obj objectForKeyMy:@"alipayConfig"];
        NSDictionary*   objwex = [obj objectForKeyMy:@"weixinConfig"];
        if( objali )
        {
            self.mPartnerId = [objali objectForKeyMy:@"partnerId"];
            self.mSellerId  = [objali objectForKeyMy:@"sellerId"];
            self.mPartnerPrivKey = [objali objectForKeyMy:@"partnerPrivKey"];
            self.mAlipayPubKey = [objali objectForKeyMy:@"alipayPubKey"];
            self.mIconName = @"22-1.png";

        }
        else if( objwex )
        {
            self.mAppId = [objwex objectForKeyMy:@"appId"];
            self.mAppSecret = [objwex objectForKeyMy:@"appSecret"];
            self.mIconName = @"22.png";

            self.mWxPartnerId = [objwex objectForKeyMy:@"partnerId"];
            self.mWxPartnerkey = [objwex objectForKeyMy:@"partnerKey"];
        }
        else
            MLLog(@"what pay?");
    }
    return self;
}

@end


@implementation STopAd

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self && obj != nil )
    {
        self.mId = [[obj objectForKeyMy:@"id"] intValue];
        self.mName = [obj objectForKeyMy:@"name"];
        self.mImgURL = [obj objectForKeyMy:@"image"];
        self.mArg = [obj objectForKeyMy:@"arg"];
        self.mType = [[obj objectForKeyMy:@"type"] intValue];
    }
    return self;
}

///获取
+(void)getTopAds:(int)cityid block:(void(^)(SResBase* resb,NSArray* ads))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt( cityid ) forKey:@"cityId"];
    [[APIClient sharedClient] postUrl:@"config.banners" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tar = NSMutableArray.new;
            for ( NSDictionary * one in info.mdata ) {
                [tar addObject: [[STopAd alloc]initWithObj:one] ];
            }
            t = tar;
        }
        block(info,t);
    }];
}




@end



@implementation SMainFunc
-(id)initWithObj:(NSDictionary*)obj
{
    self = [super initWithObj:obj];
    if( self && obj != nil )
    { 
        self.mIconURL = [obj objectForKeyMy:@"icon"];
        NSString* tc = [obj objectForKeyMy:@"bgColor"];
        self.mBgColor = [Util stringToColor:tc];
    }
    return self;
}


+(void)getMainFuncs:(int)cityid block:(void(^)(SResBase* resb,NSArray* funcs))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt( cityid ) forKey:@"cityId"];
    [[APIClient sharedClient] postUrl:@"config.categorys" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tar = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
             //   one1 = one;

                [tar addObject:[[SMainFunc alloc]initWithObj:one]];


                

            }
            t = tar;
        }
        block(info,t);
    }];
}

@end


@implementation SPromotion
/*
{
    expireTime = 0;
    id = 4;
    promotion =     {
        brief = "\U65b0\U624b\U6ce8\U518c\U4f18\U60e0\U5238";
        id = 1;
        money = 50;
        name = "\U6ce8\U518c\U793c\U5238";
        seller = "<null>";
    };
    sendTime = 0;
    sn = 33333333;
    status = 0;
}
*/
-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self && obj != nil )
    {
        self.mSN = [obj objectForKeyMy:@"sn"];
        self.mBused = [obj objectForKeyMy:@"status"];
        
        int lt = [[obj objectForKeyMy:@"expireTime"] intValue];
        if( lt == 0 )
        {
            self.mExpTime = @"永不过期";
        }
        else
        {
            self.mExpTime = [Util getTimeStringWithP:lt];
        }
        NSDictionary* dico = [obj objectForKeyMy:@"promotion"];
        
        self.mName = [dico objectForKeyMy:@"name"];
        self.mDesc = [dico objectForKeyMy:@"brief"];
        self.mMoney =[[dico objectForKeyMy:@"money"] floatValue];
        self.mSeller = [dico objectForKeyMy:@"seller"] != nil;
    }
    return self;
}

@end

@interface SAppInfo()<CLLocationManagerDelegate>

@property (atomic,strong) NSMutableArray*   allblocks;

@end
SAppInfo* g_appinfo = nil;
@implementation SAppInfo
{
    CLLocationManager* _llmgr;
    BOOL            _blocing;
    NSDate*          _lastget;
}

+(void)feedback:(NSString*)content block:(void(^)(SResBase* resb))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:content forKey:@"content"];
    [param setObject:@"ios" forKey:@"deviceType"];
    [[APIClient sharedClient]postUrl:@"feedback.create" parameters:param call:block];
}

+(SAppInfo*)shareClient
{
    if( g_appinfo ) return g_appinfo;
    @synchronized(self) {
        
        if ( !g_appinfo )
        {
            SAppInfo* t = [SAppInfo loadAppInfo];
            g_appinfo = t;
        }
        return g_appinfo;
    }
}

+(SAppInfo*)loadAppInfo
{
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSDictionary* dat = [def objectForKey:@"gappinfo"];
    SAppInfo* tt = SAppInfo.new;
    if( dat )
    {
        tt.mCityId = [[dat objectForKey:@"cityid"] intValue];
        tt.mSelCity = [dat objectForKey:@"selcity"];
    }
    return tt;
}
-(id)init
{
    self = [super init];
    self.allblocks = NSMutableArray.new;
    return self;
}
-(void)updateAppInfo
{
    NSMutableDictionary* dic = NSMutableDictionary.new;
    [dic setObject:self.mSelCity forKey:@"selcity"];
    [dic setObject:NumberWithInt(self.mCityId) forKey:@"cityid"];
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    [def setObject:dic forKey:@"gappinfo"];
    [def synchronize];
}

///定位,
-(void)getUserLocation:(BOOL)bforce block:(void(^)(NSString*err))block
{
    NSDate *nowt = [NSDate date];
    long diff = [nowt timeIntervalSince1970] - [_lastget timeIntervalSince1970];
    if( diff > 60*5 && !bforce && _mlat != 0.0f && _mlng != 0.0f )
    {
        block(nil);
        return;
    }
    
    [_allblocks addObject:block];
    if( _blocing )
    {
        return;
    }
    _blocing = YES;
    _llmgr = [[CLLocationManager alloc] init];
    _llmgr.delegate = self;
    _llmgr.desiredAccuracy = kCLLocationAccuracyBest;
    _llmgr.distanceFilter = kCLDistanceFilterNone;
    if([_llmgr respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [_llmgr  requestWhenInUseAuthorization];
    
    
    [_llmgr startUpdatingLocation];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    CLLocation* location = [locations lastObject];
    
    _mlat = location.coordinate.latitude;
    _mlng = location.coordinate.longitude;
    
    
    [SAppInfo getPointAddress:_mlng lat:_mlat block:^(NSString *address, NSString *err) {
        if( !err )
        {
            self.mAddr = address;
            _lastget = [NSDate date];
        }
        
        for(int j = 0; j < _allblocks.count;j++ )
        {
            void(^block)(NSString*err) = _allblocks[j];
            block(err);
        }
        [_allblocks removeAllObjects];
        _blocing = NO;
        
    }];
    
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString* str = nil;
    if( error.code ==1 )
    {
        str = @"定位权限失败";
    }
    else
    {
        str = @"定位失败";
    }
    for(int j = 0; j < _allblocks.count;j++ )
    {
        void(^block)(NSString*err) = _allblocks[j];
        block(str);
    }
    [_allblocks removeAllObjects];
    _blocing = NO;
}
    

+(void)getPointAddress:(float)lng lat:(float)lat block:(void(^)(NSString* address,NSString*err))block
{
    NSString* requrl =
    [NSString stringWithFormat:@"http://apis.map.qq.com/ws/geocoder/v1/?location=%.6f,%.6f&key=%@&get_poi=1",lat,lng, QQMAPKEY];
    
    [[APIClient sharedClient] GET:requrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString* addr = [[responseObject objectForKey:@"result"] objectForKey:@"address"];
        if( addr == nil )
            block(nil,@"获取位置信息失败");
        else
        {
            block(addr,nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        block(nil,@"获取位置信息失败");
        
    }];
}





@end

@implementation SAddress

+(void)saveDefault:(SAddress*)obj
{
    NSString* fuckkey = [NSString stringWithFormat:@"defaultaddr_%d",[SUser currentUser].mUserId];
    if( obj )
    {
        NSMutableDictionary* dic = NSMutableDictionary.new;
        [dic setObject:NumberWithInt(obj.mId) forKey:@"id"];
        [dic setObject:obj.mAddress forKey:@"address"];
        [dic setObject:NumberWithInt(obj.mDefault) forKey:@"isDefault"];
        NSDictionary* mapp = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:obj.mlat],@"x",[NSNumber numberWithFloat:obj.mlng],@"y", nil];
        [dic setObject:mapp forKey:@"mapPoint"];
        
        NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
        [def setObject:dic forKey:fuckkey];
        [def synchronize];
    }
    else
    {
        NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
        [def setObject:nil forKey:fuckkey];
        [def synchronize];
    }
}
+(SAddress*)loadDefault
{
    NSString* fuckkey = [NSString stringWithFormat:@"defaultaddr_%d",[SUser currentUser].mUserId];
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    NSDictionary* dic =[def objectForKey:fuckkey];
    if( dic )
    {
        return [[SAddress alloc] initWithObj:dic bload:YES];
    }
    return nil;
}

-(id)initWithObj:(NSDictionary*)obj
{
    return    [self initWithObj:obj bload:NO];
}
-(id)initWithObj:(NSDictionary*)obj bload:(BOOL)bload
{
    self = [super init];
    if( self && obj != nil )
    {
        self.mId = [[obj objectForKeyMy:@"id"] intValue];
        self.mAddress = [obj objectForKeyMy:@"address"];
        self.mDefault = [[obj objectForKeyMy:@"isDefault"] boolValue];
        
        NSDictionary* point = [obj objectForKeyMy:@"mapPoint"];
        self.mlng = [[point objectForKeyMy:@"y"] floatValue];
        self.mlat = [[point objectForKeyMy:@"x"] floatValue];
        
        
        if( self.mDefault && !bload )
            [SAddress saveDefault:self];
    }
    return self;
}

-(void)setThisDefault:(void(^)(SResBase* resb))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"addressId"];
    [[APIClient sharedClient]postUrl:@"user.address.setdefault" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            _mDefault = YES;
            
            if( self.mDefault )
                [SAddress saveDefault:self];
        }
        block(info);
    }];
    
}


-(void)delThis:(void(^)(SResBase* resb))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"addressId"];
    [[APIClient sharedClient] postUrl:@"user.address.delete" parameters:param call:^(SResBase *info) {
        
        if( _mDefault )
        {
            [SAddress saveDefault:nil];
        }
        block( info );
        
    }];
}



@end


@implementation SSeller

+(void)getSellerList:(int)order sort:(int)sort keywords:(NSString*)keywords lng:(float)lng lat:(float)lat page:(int)page bdating:(BOOL)bdating block:(void(^)(SResBase* resb,NSArray* all))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(order) forKey:@"order"];
    [param setObject:NumberWithInt(sort) forKey:@"sort"];
    [param setObject:NumberWithInt(page) forKey:@"page"];
    if( keywords )
        [param setObject:keywords forKey:@"keywords"];
    if( bdating )
    {//"预约定位坐标,筛选+排序
//        有此参数不传mapPoint"
        [param setObject:[NSString stringWithFormat:@"%.6f,%.6f",lat,lng] forKey:@"appointMapPoint"];
    }
    else
    {
        if( lng != 0.0f && lat != 0.0f )
            [param setObject:[NSString stringWithFormat:@"%.6f,%.6f",lat,lng] forKey:@"mapPoint"];
    }
    
    
    [[APIClient sharedClient] postUrl:@"seller.lists" parameters:param call:^(SResBase *info) {
       
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* ta = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                [ta addObject: [[SSeller alloc]initWithObj:one] ];
            }
            t = ta;
        }
        block( info , t);
    }];
}

-(void)getSellerDetail:(void(^)(SResBase* resb))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"sellerId"];
    [[APIClient  sharedClient] postUrl:@"seller.detail" parameters:param call:^(SResBase *info) {
        if( info.msuccess )
        {
            [self fetch: info.mdata ball: YES];
        }
        block( info );
    }];
    
}

///添加/删除 收藏,接口自己判断是否已经收藏过了,并且会设置 mFav
-(void)Favit:(void(^)(SResBase*resb))block
{
    NSMutableDictionary * param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"sellerId"];
    [[APIClient sharedClient] postUrl:(_mFav? @"collect.seller.delete" :@"collect.seller.create") parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            _mFav = !_mFav;
        }
        block(info);
        
    }];
    
}
-(void)getDatingInfo:(int)goodsid block:(void(^)(SResBase* resb,NSArray* arr ))block
{
    NSMutableDictionary * param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"sellerId"];
    [param setObject:NumberWithInt(goodsid) forKey:@"goodsId"];
    [[APIClient sharedClient]postUrl:@"seller.appointday" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tmpa = NSMutableArray.new;
            int j =0;
            for ( NSDictionary* one in info.mdata ) {
                SDatingInfo* ff = [[SDatingInfo alloc]initWithObj:one];
                if( j == 0 ) ff.mDay = @"今天";
                else if( j == 1) ff.mDay = @"明天";
                else if( j == 2 ) ff.mDay = @"后天";
                [tmpa addObject:ff];
                j++;
            }
            t = tmpa;
        }
        block(info,t);
        
    }];
}

///获取评价
///typ 0 全部, 1 好评 2 中评 3差评 ; arr => SComments
-(void)getComments:(int)type page:(int)page block:(void(^)(SResBase* resb,NSArray* arr))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(type) forKey:@"type"];
    [param setObject:NumberWithInt(page) forKey:@"page"];
    [param setObject:NumberWithInt(_mId) forKey:@"sellerId"];
    
    [[APIClient sharedClient] postUrl:@"rate.seller.lists" parameters:param call:^(SResBase *info) {
       
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tmpa = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                [tmpa addObject:[[SComments alloc] initWithObj: one]];
            }
            t = tmpa;
        }
        
        block(info,t);
        
    }];
}


-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    
    if( self && obj )
    {
        [self fetch:obj ball: YES];
    }
    
    return self;
}
-(void)fetch:(NSDictionary*)obj ball:(BOOL)ball
{
    if( ball )
    {
    self.mId = [[obj objectForKeyMy:@"id"] intValue];
    self.mName = [obj objectForKeyMy:@"name"];
    self.mLogoURL =[obj objectForKeyMy:@"logo"];
    self.mLogoURL = [self.mLogoURL stringByAppendingString:@"@120w_120h_1e_1c_1o.jpg"];
    
    
    self.mBannerURL = [obj objectForKeyMy:@"banner"];
    self.mDesc = [obj objectForKeyMy:@"brief"];
    self.mAddress = [obj objectForKeyMy:@"address"];
    NSDictionary* point = [obj objectForKeyMy:@"mapPoint"];
    self.mLat = [[point objectForKeyMy:@"x"] floatValue];
    self.mLng = [[point objectForKeyMy:@"y"] floatValue];
    self.mSArea = [[obj objectForKeyMy:@"serviceArea"] intValue];
    //self.mDist = [[obj objectForKeyMy:@"distance"] intValue];
    
    QMapPoint ap = QMapPointForCoordinate(CLLocationCoordinate2DMake( self.mLat, self.mLng));
    
    QMapPoint bp = QMapPointForCoordinate(CLLocationCoordinate2DMake( [SAppInfo shareClient].mlat, [SAppInfo shareClient].mlng));
    int _diss = QMetersBetweenMapPoints(ap,bp);
    self.mDist = [Util getDistStr: _diss];
    
    self.mIsAuth = [[obj objectForKeyMy:@"isAuthenticate"] boolValue];
    self.mIsCer = [[obj objectForKeyMy:@"isCertification"] boolValue];
    NSArray* al = [obj objectForKeyMy:@"photos"];
    NSMutableArray* tmpa = NSMutableArray.new;
    NSMutableArray* tmpabig = NSMutableArray.new;
    for ( NSString* one in al ) {
        [tmpa addObject: one];
        [tmpabig addObject: one];
    }
    self.mPhots = tmpa;
    self.mPhotoBigs = tmpabig;
    
    
    self.mFav = [obj objectForKeyMy:@"collect"] != nil;
        
    }
    
    //extend
    NSDictionary* objext = [obj objectForKeyMy:@"extend"];
    if( objext == nil )//如果没有,就向上获取次
        objext = obj;
    self.mGoodsAvgPrice = [[objext objectForKeyMy:@"goodsAvgPrice"] floatValue];
    self.mOrderCount = [[objext objectForKeyMy:@"orderCount"] intValue];
    self.mCreditRank = [[objext objectForKeyMy:@"creditRank"] objectForKeyMy:@"icon"];
    self.mCommentTotalCount = [[objext objectForKeyMy:@"commentTotalCount"] intValue];
    self.mCommentGoodCount = [[objext objectForKeyMy:@"commentGoodCount"] intValue];
    self.mCommentNeutralCount = [[objext objectForKeyMy:@"commentNeutralCount"] intValue];
    self.mCommentBadCount = [[objext objectForKeyMy:@"commentBadCount"] intValue];
    self.mCommentSpecialtyAvgScore = [[objext objectForKeyMy:@"commentSpecialtyAvgScore"] floatValue];
    self.mCommentCommunicateAvgScore = [[objext objectForKeyMy:@"commentCommunicateAvgScore"] floatValue];
    self.mCommentPunctualityAvgScore = [[objext objectForKeyMy:@"commentPunctualityAvgScore"] floatValue];
    
}
-(void)getCmmStatisic:(void(^)(SResBase* resb))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"sellerId"];
    [[APIClient sharedClient]postUrl:@"rate.statistics" parameters:param call:^(SResBase *info) {
       if( info.msuccess )
       {
           [self fetch:info.mdata ball: NO];
       }
        block(info);
        
        
    }];
    
}


@end



@implementation SGoods
-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    
    if( self && obj != nil )
    {
        [self fetch:obj];
    }
    
    return self;
}
-(void)fetch:(NSDictionary*)obj
{
    self.mId = [[obj objectForKeyMy:@"id"] intValue];
    self.mSellerId = [[obj objectForKeyMy:@"sellerId"] intValue];
    self.mName = [obj objectForKeyMy:@"name"];
    self.mImgURL =[obj objectForKeyMy:@"image"];
    self.mImgURL = [self.mImgURL stringByAppendingString:@"@292w_292h_1e_1c_1o.jpg"];
    ///
    
    ///
    NSMutableArray* ta = NSMutableArray.new;
    NSMutableArray* tabig = NSMutableArray.new;
    self.mImgs = [obj objectForKeyMy:@"images"];
    for (NSString* one in self.mImgs ) {
        [ta addObject:[one stringByAppendingString:@"@640w_640h_1e_1c_1o.jpg"]];
        [tabig addObject:one];
        
    }
    self.mImgs = ta;
    self.mImgsBig = tabig;
    
    self.mPrice = [[obj objectForKeyMy:@"price"] floatValue];
    self.mMrketPrice = [[obj objectForKeyMy:@"marketPrice"] floatValue];
    self.mDesc = [obj objectForKeyMy:@"brief"];
    self.mDuration = [[obj objectForKeyMy:@"duration"] intValue];
    
    NSDictionary* tdic = [obj objectForKeyMy:@"collect"];
    self.mFav= tdic != nil;
    
    self.mSeller = [[SSeller alloc]initWithObj:[obj objectForKeyMy:@"seller"]];
    
}
-(void)getDetails:(void(^)(SResBase* resb))block
{
    NSMutableDictionary * param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"goodsId"];
    [[APIClient sharedClient]postUrl:@"goods.detail" parameters:param call:^(SResBase *info) {
    
        if( info.msuccess )
        {
            [self fetch: info.mdata];
        }
        block( info );
    }];
}

-(void)Favit:(void(^)(SResBase*err))block
{
    NSMutableDictionary * param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"goodsId"];
    [[APIClient sharedClient] postUrl:(_mFav? @"collect.goods.delete" :@"collect.goods.create") parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            _mFav = !_mFav;
        }
        block(info);
        
    }];
    
}





+(void)getGoods:(int)catlogid order:(int)order sort:(int)sort page:(int)page keywords:(NSString*)keywords
       sellerid:(int)sellerid  aptime:(NSDate*)aptime lng:(float)lng lat:(float)lat  block:(void(^)(SResBase* resb,NSArray* all))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(order) forKey:@"order"];
    [param setObject:NumberWithInt(sort) forKey:@"sort"];
    if( keywords )
        [param setObject:keywords forKey:@"keywords"];
    [param setObject:NumberWithInt(sellerid) forKey:@"sellerId"];
    [param setObject:NumberWithInt(catlogid) forKey:@"categoryId"];
    [param setObject:NumberWithInt(page) forKey:@"page"];
    if( lng != 0.0f && lat != 0.0f )
        [param setObject:[NSString stringWithFormat:@"%.6f,%.6f",lat,lng] forKey:@"mapPoint"];
    //appointTime
    if( aptime )
        [param setObject:[Util getTimeStringHour:aptime] forKey:@"appointTime"];
    
    [[APIClient sharedClient]postUrl:@"goods.lists" parameters:param call:^(SResBase *info) {
       
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tmpa = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                [tmpa addObject: [[SGoods alloc]initWithObj:one]];
            }
            t = tmpa;
        }
        
        block(info,t);
        
    }];
    
}






@end

@implementation SDatingInfo

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self && obj )
    {
        self.mDay = [obj objectForKeyMy:@"day"];
        self.mIsBusy = [[obj objectForKeyMy:@"isDusy"] boolValue];
        NSMutableArray* tar = NSMutableArray.new;
        for ( NSDictionary*one in [obj objectForKeyMy:@"hours"] ) {
            
            [tar addObject:[[STimeItem alloc]initWithObj:one] ];
            
        }
        self.mTimeInfos  = tar;
    }
    return self;
}

@end



@implementation STimeItem

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self && obj )
    {
        self.mHour = [obj objectForKeyMy:@"hour"];
        self.mCan = [[obj objectForKeyMy:@"appointStatus"] intValue] == 1;
        self.mDate = [Util dateWithInt:[[obj objectForKeyMy:@"time"] intValue] ];
    }
    return self;
}
@end

@implementation SOrder
{
    float   _gotopayMoney;
}

-(BOOL)isPayed
{
    return _mPayState == 1;
}
-(BOOL)isCommented
{
    return _mBComment;
}


-(UIShowBt)getUIShowbt
{
//    if( _mOrderState == E_OS_WaitPay && ![self isPayed] )
//    {
//        return E_UIShow_Cancle_Pay;
//    }
//    else if( _mOrderState == E_OS_WaitSeller && [self isPayed ])
//    {
//        return E_UIShow_Cancle_ConTa;
//    }
//    else if( _mOrderState == E_OS_SellerOut )
//    {
//        return E_UIShow_ConTa_ConKf;
//    }
//    else if( _mOrderState == E_OS_SRVing )
//    {
//        return E_UIShow_ConKf;
//    }
//    else if( _mOrderState == E_OS_WaitConfim )
//    {
//        return E_UIShow_Confim;
//    }
//    else if ( _mOrderState == E_OS_WaitComment )
//    {
//        return E_UIShow_Comment;
//    }
//    else if( _mOrderState == E_OS_SRVComplete  ||  _mOrderState ==  E_OS_WaitComment   )
//    {
//        return E_UIShow_Del;
//    }
//    else if ( _mOrderState == E_OS_Cacle )
//    {
//        return E_UIShow_Del_ConKf;
//    }
    
    if( _mOrderState == E_OS_WaitSeller && [self isPayed] )
    {
        return E_UIShow_StartSrv;
    }
    else if( _mOrderState == E_OS_SRVing )
    {
        return E_UIShow_CompleteSrv;
    }
    
    MLLog(@"what fuck state!");
    return E_UIShow_NON;

}

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self )
    {
        [self fetch:obj];
    }
    return self;
}
-(void)fetch:(NSDictionary*)obj
{
    self.mSn= [obj objectForKeyMy:@"sn"]                ;//订单号
    self.mId= [[obj objectForKeyMy:@"id"] intValue]                 ;//编号
    int second = [[obj objectForKeyMy:@"appointTime"] intValue];
    self.mApptime= [Util getTimeStringHourSecond:second];//当初预约的时间
    self.mPromStr= [[obj objectForKeyMy:@"promotion"] objectForKeyMy:@"promotionName"]                  ;//优惠描述
    self.mPromMoney= [[obj objectForKeyMy:@"discountFee"] floatValue]                ;//优惠了多少钱
    self.mUserName=  [obj objectForKeyMy:@"userName"]                ;//下单的人
    self.mPhoneNum= [obj objectForKeyMy:@"mobile"]                 ;//下单的电话
    self.mAddress= [obj objectForKeyMy:@"address"]                 ;//地址
    self.mTotalMoney= [[obj objectForKeyMy:@"totalFee"] floatValue]                 ;//总价
    self.mPayMoney= [[obj objectForKeyMy:@"payFee"] floatValue]                 ;//支付金额
    self.mReMark= [obj objectForKeyMy:@"buyRemark"]                 ;//备注
    self.mOrderStateStr = [obj objectForKeyMy:@"orderStatusStr"];
    self.mServiceScope = [obj objectForKeyMy:@"serviceScope"];
    self.mServiceBrief = [[obj objectForKeyMy:@"goods"]objectForKeyMy:@"brief"];///服务内容
    
    self.mOrderState = [[obj objectForKeyMy:@"orderStatus"] intValue];
    self.mPayState = [[obj objectForKeyMy:@"payStatus"] intValue];
    self.mBComment= [[obj objectForKeyMy:@"isRate"] boolValue]                 ;//是否已经评价过了
    self.mSeller = [[SSeller alloc]initWithObj: [obj objectForKeyMy:@"seller"]];
    self.mGooods = [[SGoods alloc] initWithObj: [obj objectForKeyMy:@"goods"]];
    self.mUser = [[SUser alloc]initWithObj: [obj objectForKeyMy:@"user"]];

    _mLongit =[[[obj objectForKeyMy:@"mapPoint"] objectForKeyMy:@"y"] floatValue];
    _mLat =[[[obj objectForKeyMy:@"mapPoint"] objectForKeyMy:@"x"] floatValue];
    
    _mServiceStartTime = [[obj objectForKeyMy:@"serviceStartTime"] intValue];
    _mServiceFinishTime = [[obj objectForKeyMy:@"serviceFinishTime"]intValue];
    
    second = [[obj objectForKeyMy:@"createTime"] intValue];
    self.mCreateOrderTime =[Util getTimeStringHourSecond:second];
    
    self.mCreateOrderTimeWithWeek = self.mCreateOrderTime;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger unitFlags = NSWeekdayCalendarUnit;
    
    NSDateComponents *comps = [calendar components:unitFlags fromDate:[Util dateWithInt:second]];
    NSInteger wkd = [comps weekday];
    
    NSString* wdkstr = @"";
    switch (wkd) {
        case 1:
            wdkstr = @"(周日) ";
            break;
        case 2:
            wdkstr = @"(周一) ";
            break;
        case 3:
            wdkstr = @"(周二) ";
            break;
        case 4:
            wdkstr = @"(周三) ";
            break;
        case 5:
            wdkstr = @"(周四) ";
            break;
        case 6:
            wdkstr = @"(周五) ";
            break;
        case 7:
            wdkstr = @"(周六) ";
            break;
        default:
            break;
    }
    
    self.mCreateOrderTimeWithWeek = [self.mCreateOrderTimeWithWeek stringByReplacingOccurrencesOfString:@" " withString:wdkstr];
    self.mApptime = [self.mApptime stringByReplacingOccurrencesOfString:@" " withString:wdkstr];
    
}

-(void)caclePrice:(NSString*)sn block:(void(^)( NSString* err,float totalMoney,float promMoney,float payMoney))block
{
    NSMutableDictionary* param =    NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"goodsId"];
    if( sn )
        [param setObject:sn forKey:@"promotionSn"];
    
    [[APIClient sharedClient] postUrl:@"order.moneycompute" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            
            float   tot = [[info.mdata objectForKey:@"totalMoeny"] floatValue];
            float   pro = [[info.mdata objectForKey:@"promotionMoney"] floatValue];
            float   pay = [[info.mdata objectForKey:@"payMoney"] floatValue];
            
            block(nil,tot,pro,pay);
        }
        else
            block( info.mmsg,0.0f,0.0f,0.0f );
        
    }];
}

-(void)getDetail:(void(^)(SResBase* retobj))block
{
    NSMutableDictionary* param =    NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
    [[APIClient sharedClient] postUrl:@"order.detail" parameters:param call:^(SResBase *info) {
    
        if( info.msuccess )
        {
            [self fetch:info.mdata];
        }
        block( info );
        
    }];
}

-(void)payIt:(int)paytype block:(void(^)(SResBase* retobj))block;
{
#ifdef WX_PAY
    if( paytype == 0 )
        [self wxPay:block];
#endif
}


#ifdef WX_PAY

//=======================微信支付===================================
-(void)wxPay:(void(^)(SResBase* retobj))block;
{
    NSMutableDictionary* param =    NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
    [param setObject:@"weixin" forKey:@"payment"];
    [[APIClient sharedClient] postUrl:@"order.pay" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            self.mPayedSn = [info.mdata objectForKeyMy:@"sn"];
            self.mPayMoney = [[info.mdata objectForKeyMy:@"money"] floatValue];
            
            NSString* typestr = [info.mdata objectForKeyMy:@"paymentType"];
            if( [typestr isEqualToString:@"weixin"] )
            {
                
                SWxPayInfo* wxpayinfo = [[SWxPayInfo alloc]initWithObj:[info.mdata objectForKeyMy:@"payRequest"]];
                [SAppInfo shareClient].mPayBlock = ^(SResBase *retobj) {
                    
                    if( retobj.msuccess )
                    {//如果成功了,就更新下
                        _mOrderState = E_OS_WaitSeller;//等待服务
                        _mOrderStateStr = @"等待服务";
                        _mPayState = 1;
                    }
                    block(retobj);//再回调获取
                    [SAppInfo shareClient].mPayBlock = nil;
                    
                };
                [self gotoWXPayWithSRV:wxpayinfo];
            }
            else if( [typestr isEqualToString:@"alipay"] )
            {
                //payment = [[SPayment alloc]initWithObjWX:[info.mdata objectForKeyMy:@"payment"]];
            }
            else
            {
                SResBase* itretobj = [SResBase infoWithError:@"支付出现异常,请稍后再试"];
                block(itretobj);//再回调获取
            }
        }
        else
            block( info );
    }];
}

-(void)gotoWXPayWithSRV:(SWxPayInfo*)payinfo
{
    PayReq * payobj = [[PayReq alloc]init];
    payobj.partnerId = payinfo.mpartnerId;
    payobj.prepayId = payinfo.mprepayId;
    payobj.nonceStr = payinfo.mnonceStr;
    payobj.timeStamp = payinfo.mtimeStamp;
    payobj.package = @"Sign=WXPay";
    payobj.sign = payinfo.msign;
    [WXApi sendReq:payobj];
    
}

-(void)gotoWXpay:(SPayment*)payemnt block:(void(^)(SResBase* retobj))block;
{
    NSString* requrl = @"https://api.mch.weixin.qq.com/pay/unifiedorder";
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:payemnt.mAppId  forKey:@"appid"];
    [param setObject:payemnt.mWxPartnerId forKey:@"mch_id"];
    [param setObject:[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] forKey:@"nonce_str"];
    [param setObject:[self getOrderDesc] forKey:@"body"];
    [param setObject:_mPayedSn forKey:@"out_trade_no"];
    [param setObject:[NSString stringWithFormat:@"%d",(int)(_mPayMoney*100)] forKey:@"total_fee"];
    [param setObject:@"192.168.1.1" forKey:@"spbill_create_ip"];
    [param setObject:WXPAYURL forKey:@"notify_url"];
    [param setObject:@"APP" forKey:@"trade_type"];
    [param setObject:[NSString stringWithFormat:@"%d",(_mGooods.mId)] forKey:@"product_id"];
    NSString* sigstr = [Util genWxSign:param parentkey:payemnt.mWxPartnerkey];
    [param setObject:sigstr forKey:@"sign"];
    
    NSURL *url = [NSURL URLWithString:requrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSString* paraxml = [Util makeXML:param];
    [request setHTTPBody:[paraxml dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    
    NSOperationQueue *queue= [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSString* string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSRange loc = [string rangeOfString:@"<prepay_id><![CDATA["];
        NSRange locc = [string rangeOfString:@"]]></prepay_id>"];
        if( [string rangeOfString:@"SUCCESS"].location == NSNotFound || loc.location == NSNotFound || locc.location == NSNotFound )
        {
            SResBase* rrrrrr = [SResBase infoWithError:@"获取支付信息失败"];
            block(rrrrrr);
        }
        else
        {
            
            NSString* prid = [string substringWithRange:NSMakeRange( loc.location + loc.length ,  locc.location - (loc.location + loc.length)   )];
            
            MLLog(@"prid:%@",prid);
            PayReq * payobj = [[PayReq alloc]init];
            payobj.partnerId = payemnt.mWxPartnerId;
            payobj.prepayId = prid;
            payobj.nonceStr = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
            payobj.timeStamp = [[NSDate date] timeIntervalSince1970];
            payobj.package = @"Sign=WXPay";
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:payemnt.mAppId forKey:@"appid"];
            [params setObject:payobj.nonceStr  forKey:@"noncestr"];
            [params setObject:payobj.package forKey:@"package"];
            [params setObject:payobj.partnerId  forKey:@"partnerid"];
            [params setObject:payobj.prepayId  forKey:@"prepayid"];
            [params setObject:[NSString stringWithFormat:@"%d",(int)payobj.timeStamp]  forKey:@"timestamp"];
            payobj.sign = [Util genWxSign:params parentkey:payemnt.mWxPartnerkey];
            [WXApi sendReq:payobj];
        }
    }];
}

//===============================================================

-(NSString*)getOrderDesc
{
    return [NSString stringWithFormat:@"%@",_mGooods.mName];
}

#endif

-(void)cancle:(void(^)(SResBase* retobj))block
{
    
    NSMutableDictionary* param =    NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
    [[APIClient sharedClient]postUrl:@"order.cancel" parameters:param call:^(SResBase *info) {
       
        if( info.msuccess )
        {
            _mOrderState = E_OS_Cacle;
            _mOrderStateStr = @"已取消";
        }
        block( info );
        
    }];
}

-(void)delThis:(void(^)(SResBase* retobj))block
{
    
    NSMutableDictionary* param =    NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
    [[APIClient sharedClient]postUrl:@"order.delete" parameters:param call:^(SResBase *info) {
        
        block( info );
        
    }];
}

//确定订单
-(void)confirmThis:(void(^)(SResBase* retobj))block
{
    NSMutableDictionary* param =    NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
    [[APIClient sharedClient]postUrl:@"order.confirm" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            _mOrderState = E_OS_WaitComment;
            _mOrderStateStr = @"待评价";
        }
        block( info );
        
    }];
}

//评论
//sc 专业得分1-5分
//cc 沟通得分1-5分
//pc 守时得分1-5分
-(void)commentThis:(NSString*)content imgs:(NSArray*)imgs sc:(int)sc cc:(int)cc pc:(int)pc block:(void(^)(SResBase* retobj))block
{
    if( imgs.count )
    {
        [SVProgressHUD showWithStatus:@"正在上传文件" maskType:SVProgressHUDMaskTypeClear];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            
            OSSClient* _ossclient = [OSSClient sharedInstanceManage];
            NSString *accessKey = APPKEY;
            NSString *secretKey = APPSEC;
            [_ossclient setGenerateToken:^(NSString *method, NSString *md5, NSString *type, NSString *date, NSString *xoss, NSString *resource){
                NSString *signature = nil;
                NSString *content = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@%@", method, md5, type, date, xoss, resource];
                signature = [OSSTool calBase64Sha1WithData:content withKey:secretKey];
                signature = [NSString stringWithFormat:@"OSS %@:%@", accessKey, signature];
                //NSLog(@"here signature:%@", signature);
                return signature;
            }];
            
            OSSBucket* _ossbucket = [[OSSBucket alloc] initWithBucket:@"vso2o"];
            NSMutableArray* allfiles = NSMutableArray.new;
            for ( UIImage* oneimg in imgs ) {
                
                NSData *dataObj = UIImageJPEGRepresentation(oneimg, 1.0);
                NSString* filepath = [SUser makeFileName:@"jpg"];
                OSSData *testData = [[OSSData alloc] initWithBucket:_ossbucket withKey:filepath];
                [testData setData:dataObj withType:@"jpg"];
                NSError* error = nil;
                [testData upload:&error];
                if( error )
                {
                    MLLog(@"upload comment err:%@",error.description);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [SVProgressHUD showErrorWithStatus:@"上传文件失败"];
                        block(nil);
                        
                    });
                    return ;
                }
                
                [allfiles addObject:filepath];
            }
            
            NSMutableDictionary* param = NSMutableDictionary.new;
            if( content )
            [param setObject:content forKey:@"content"];
            [param setObject:allfiles forKey:@"images"];
            [param setObject:NumberWithInt(sc) forKey:@"specialtyScore"];
            [param setObject:NumberWithInt(cc) forKey:@"communicateScore"];
            [param setObject:NumberWithInt(pc) forKey:@"punctualityScore"];
            [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[APIClient sharedClient] postUrl:@"rate.order.create" parameters:param call:^(SResBase *info) {
                    
                    if( info.msuccess )
                    {
                        _mOrderState = E_OS_SRVComplete;
                        _mOrderStateStr = @"服务完成";
                        [SVProgressHUD showSuccessWithStatus:info.mmsg];
                    }
                    else
                        [SVProgressHUD showErrorWithStatus:info.mmsg];
                    block(info);
                    
                }];
            });
        });
    }
    else
    {
       [SVProgressHUD showWithStatus:@"正在评价" maskType:SVProgressHUDMaskTypeClear];
        NSMutableDictionary* param = NSMutableDictionary.new;
        if( content )
        [param setObject:content forKey:@"content"];
        [param setObject:NumberWithInt(sc) forKey:@"specialtyScore"];
        [param setObject:NumberWithInt(cc) forKey:@"communicateScore"];
        [param setObject:NumberWithInt(pc) forKey:@"punctualityScore"];
        [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
        [[APIClient sharedClient] postUrl:@"rate.order.create" parameters:param call:^(SResBase *info) {
            
            if( info.msuccess )
            {
                _mOrderState = E_OS_SRVComplete;
                _mOrderStateStr = @"服务完成";
                [SVProgressHUD showSuccessWithStatus:info.mmsg];
            }
            else
                [SVProgressHUD showErrorWithStatus:info.mmsg];
            block(info);
        }];
    }
}

-(void)startSrv:(void(^)(SResBase* resb))block
{
    NSMutableDictionary* param =    NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
    [param setObject:NumberWithInt(4) forKey:@"status"];
    [[APIClient sharedClient] postUrl:@"order.updatestatus" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            [self fetch:info.mdata];
        }
        block(info);
    }];
}

//完成服务
-(void)completeSrv:(void(^)(SResBase* resb))block
{
    NSMutableDictionary* param =    NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"orderId"];
    [param setObject:NumberWithInt(5) forKey:@"status"];
    [[APIClient sharedClient] postUrl:@"order.updatestatus" parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            [self fetch:info.mdata];
        }
        block(info);
    }];
}



///下单
+(void)dealOne:(int)goodsId promsn:(NSString*)promSN userName:(NSString*)userName appTime:(NSDate*)appTime phoneNu:(NSString*)phoneNu addr:(NSString*)addr lng:(float)lng lat:(float)lat reMark:(NSString*)reMark bloc:(void(^)(SResBase* info,SOrder* obj))block
{
    NSMutableDictionary* param =    NSMutableDictionary.new;
    [param setObject:NumberWithInt(goodsId) forKey:@"goodsId"];
    if( promSN )
        [param setObject:promSN forKey:@"promotionSn"];
    if( userName )
        [param setObject:userName forKey:@"userName"];
    if( appTime )
        [param setObject:[Util getTimeStringHour:appTime] forKey:@"appointTime"];
    if( phoneNu )
        [param setObject:phoneNu forKey:@"mobile"];
    if( addr )
        [param setObject:addr forKey:@"address"];
    [param setObject:[NSString stringWithFormat:@"%.6f,%.6f",lat,lng] forKey:@"mapPoint"];
    if( reMark )
        [param setObject:reMark forKey:@"remark"];
    
    [[APIClient sharedClient] postUrl:@"order.create" parameters:param call:^(SResBase *info) {
       
        SOrder* retobj = nil;
        if( info.msuccess )
        {
            retobj = [[SOrder alloc] initWithObj:info.mdata];
        }
        block( info, retobj);
        
    }];
}



@end



@implementation SComments

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self && obj )
    {
        self.mContent = [obj objectForKeyMy:@"content"];
        self.mPhone = [[obj objectForKeyMy:@"user"] objectForKeyMy:@"mobile"];
        NSDate* tt = [Util dateWithInt: [[obj objectForKeyMy:@"createTime"] intValue]];
        self.mTimeStr = [Util FormartTime: tt ];
        self.mUserHeadURL = [[obj objectForKeyMy:@"user"] objectForKeyMy:@"avatar"];
        
        NSMutableArray* tas = NSMutableArray.new;
        NSMutableArray* tasbig = NSMutableArray.new;
        NSArray* tarrrr = [obj objectForKeyMy:@"images"];
        for( NSString* one in tarrrr )
        {
            if( one.length == 0 ) continue;
            
            [tas addObject:[one stringByAppendingString:@"@130w_130h_1e_1c_1o.jpg"] ];
            [tasbig addObject:one ];
            
        }
        self.mAllImgs = tas;
        self.mAllBigImgs = tasbig;
        
        
        NSString* str = [obj objectForKeyMy:@"result"];
        if( [str isEqualToString:@"good"] )
            self.mLevel = @"好评";
        else if( [str isEqualToString:@"neutral"])
            self.mLevel = @"中评";
        else if( [str isEqualToString:@"bad"])
            self.mLevel = @"差评";
        
        SOrder * torder = [[SOrder alloc]initWithObj:[obj objectForKeyMy:@"order"]];
        if( torder.mGooods.mName.length )
            self.mSrvName = [torder.mGooods.mName copy];
        
    }
    return self;
}

@end


@implementation SStatisic

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self )
    {
        NSString* tt = [obj objectForKeyMy:@"month"];
        if( tt.length == 6 )
        {
            self.mMonth = [[tt substringFromIndex:4] intValue];
            self.mYear = [[tt substringToIndex:4] intValue];
        }
        self.mNum = [[obj objectForKeyMy:@"num"] intValue];
        self.mTotal = [[obj objectForKeyMy:@"total"] floatValue];
    }
    return self;
}
-(id)initWtihOrderDic:(NSDictionary*)order
{
    self = [super init];
    if( self )
    {
        SOrder* or = [[SOrder alloc]initWithObj: order];
        self.mImgURL = [or.mGooods.mImgURL copy];
        self.mSrvName = [or.mGooods.mName copy];
        self.mTimeStr = [or.mCreateOrderTime copy];
        self.mTotal = or.mTotalMoney;
        self.mOrderId = or.mId;
        
    }
    return self;
}

+(void)getStatisic:(int)yeaer month:(int)month page:(int)page block:(void(^)(SResBase* resb,NSArray* all))block
{
    if( month == -1 )
    {//按照月份统计
        NSMutableDictionary* param =    NSMutableDictionary.new;
        [param setObject:NumberWithInt(page) forKey:@"page"];
        [[APIClient sharedClient]postUrl:@"statistics.month" parameters:param call:^(SResBase *info) {
            //这个返回的是订单,,,
            NSArray* t  = nil;
            if( info.msuccess )
            {
                NSMutableArray* ta = NSMutableArray.new;
                for ( NSDictionary* one in info.mdata ) {
                    [ta addObject: [[SStatisic alloc]initWithObj:one]];
                }
                t = ta;
            }
            block(info,t);
        }];
        
    }
    else
    {
        NSMutableDictionary* param =    NSMutableDictionary.new;
        [param setObject:NumberWithInt(month) forKey:@"month"];
        [param setObject:NumberWithInt(page) forKey:@"page"];
        if( month > 0 )
        {
            if( month < 10 )
                [param setObject:[NSString stringWithFormat:@"%d0%d",yeaer,month] forKey:@"month"
                 ];
            else
                [param setObject:[NSString stringWithFormat:@"%d%d",yeaer,month] forKey:@"month"
                 ];
        }
        
        [[APIClient sharedClient] postUrl:@"statistics.detail" parameters:param call:^(SResBase *info) {
            NSArray* t  = nil;
            if( info.msuccess )
            {
                NSMutableArray* ta = NSMutableArray.new;
                for ( NSDictionary* one in info.mdata ) {
                    [ta addObject: [[SStatisic alloc]initWtihOrderDic:one]];
                }
                t = ta;
            }
            block(info,t);
        }];
    }
    
}





@end

@implementation SScheduleItem

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self )
    {
        self.mTimeStr   = [obj objectForKeyMy:@"hour"];
        self.mStatus    = [[obj objectForKeyMy:@"status"] intValue];
        if( _mStatus == 0 )//0：暂无安排 1：有单子 2：停止接单"
        {
            self.mStr = @"暂无安排";
            self.mbStringInfo = YES;
        }
        else if( _mStatus ==  -1 )
        {
            self.mStr = @"停止接单";
            self.mbStringInfo = YES;
        }
        else if( _mStatus == 1 )
        {
            self.mbStringInfo = NO;
            
            self.mAddress = [obj objectForKeyMy:@"address"];
            self.mPhone = [obj objectForKeyMy:@"mobile"];
            self.mSrvName = [obj objectForKeyMy:@"goodName"];
            self.mUserName = [obj objectForKeyMy:@"userName"];
            
            self.mOrder = SOrder.new;
            self.mOrder.mId = [[obj objectForKeyMy:@"orderId"] intValue];
            
        }
        else
        {
            self.mStr = @"未知安排";
            self.mbStringInfo = YES;
        }
    }
    return self;
}


//开启接单,返回所有的数据
+(void)starSrv:(NSArray*)items block:(void(^)(SResBase* resb ,NSArray* all ))block
{
    [SScheduleItem realupdate:1 items:items block:block];
}
//停止接单,返回所有的数据

+(void)stopSrv:(NSArray*)items block:(void(^)(SResBase* resb ,NSArray* all ))block
{
    [SScheduleItem realupdate:0 items:items block:block];
}

+(void)realupdate:(int)i items:(NSArray*)items block:(void(^)(SResBase* resb ,NSArray* all ))block
{
    NSMutableArray* all = NSMutableArray.new;
    for( SScheduleItem* one in items )
    {
        NSString* s = [one.mDateStr stringByAppendingString:one.mTimeStr];
        s = [s stringByReplacingOccurrencesOfString:@":" withString:@""];
        [all addObject:s];
    }
    
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:all forKey:@"hours"];
    [param setObject:NumberWithInt(i) forKey:@"status"];
    [[APIClient sharedClient]postUrl:@"schedule.update" parameters:param call:^(SResBase *info){
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* ta = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                
                [ta addObject:[[SSchedule alloc]initWithObj:one]];
                
            }
            t = ta;
        }
        block( info,t);
    }];
}


@end

@implementation SSchedule

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    
    if( self )
    {
        self.mDateStr = [obj objectForKeyMy:@"day"];
        
        self.mStringDate = [Util convdatestr:_mDateStr];
        
        self.mWeek = [obj objectForKeyMy:@"week"];
        
        NSArray* t = [obj objectForKeyMy:@"hour"];
        NSMutableArray* ta = NSMutableArray.new;
        for ( NSDictionary* one in t ) {
            SScheduleItem* temp = [[SScheduleItem alloc]initWithObj:one];
            temp.mDateStr = self.mDateStr;
            [ta addObject: temp];
            
        }
        self.mSubInfo = ta;
        
    }
    
    return self;
}


+(void)getSchedules:(void(^)(SResBase* resb ,NSArray* all ))block
{
    [[APIClient sharedClient] postUrl:@"schedule.lists" parameters:nil call:^(SResBase *info) {
       
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* ta = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                
                [ta addObject:[[SSchedule alloc]initWithObj:one]];
                
            }
            t = ta;
        }

        block( info, t);
    }];
}

@end


@implementation SMessage

-(id)initWithAPN:(NSDictionary*)objapn
{
    self = [super init];
    if( self )
    {
        self.mTitle = [objapn objectForKeyMy:@"title"];
        self.mContent = [objapn objectForKeyMy:@"content"];
        self.mDateStr = [Util dateForint:[[objapn objectForKeyMy:@"createTime"] floatValue] bfull:NO];
        self.mArgs = [objapn objectForKeyMy:@"args"];
        self.mType = [[objapn objectForKeyMy:@"type"] intValue];
        self.mBread = [[objapn objectForKeyMy:@"status"] intValue];
    }
    
    return self;
}

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    
    if( self )
    {
        self.mTitle = [obj objectForKeyMy:@"title"];
        self.mContent = [obj objectForKeyMy:@"content"];
        self.mDateStr = [Util dateForint:[[obj objectForKeyMy:@"sendTime"] floatValue] bfull:NO];
        self.mArgs = [obj objectForKeyMy:@"args"];
        self.mType = [[obj objectForKeyMy:@"type"] intValue];
        self.mBread = [[obj objectForKeyMy:@"status"] intValue];
    }
    
    return self;
}

-(void)readit
{
    if ( _mBread ) return;
    
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"id"];
    [[APIClient sharedClient] postUrl:@"msg.read" parameters:param call:^(SResBase *info) {
        
        _mBread = info.msuccess ? !_mBread :_mBread;
        
    }];
}

+(void)getMsgList:(int)page block:(void(^)( SResBase* resb , NSArray* all ))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(page) forKey:@"page"];
    
    [[APIClient sharedClient]postUrl:@"msg.lists" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* ta = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                [ta addObject: [[SMessage alloc]initWithObj:one]];
            }
            t = ta;
        }
        block(info,t);
        
    }];
}
+(void)readAllMessage:(void(^)(SResBase* retobj))block{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(0) forKey:@"id"];
    [[APIClient sharedClient] postUrl:@"msg.read" parameters:param call:^(SResBase *info) {
        
        block( info );
        
        
    }];
}


@end





@implementation SStaff

-(id)initWithObj:(NSDictionary*)obj
{
    self = [super init];
    if( self )
    {
        [self fetch:obj];
    }
    return self;
}
-(void)fetch:(NSDictionary*)obj
{
    NSDictionary* sellerobj = [obj objectForKeyMy:@"seller"];
    if( sellerobj )
    {
        self.mSellerObj = [[SSeller alloc]initWithObj: sellerobj];
    }
    else
    {
        self.mSellerObj = nil;
    }
    
    
    self.mId = [[obj objectForKeyMy:@"id"] intValue];
    self.mName = [obj objectForKeyMy:@"name"];
    self.mLogoURL =[obj objectForKeyMy:@"avatar"];
    self.mLogoURL = [self.mLogoURL stringByAppendingString:@"@120w_120h_1e_1c_1o.jpg"];
    
    self.mDesc = [obj objectForKeyMy:@"brief"];
    self.mMobile = [obj objectForKeyMy:@"mobile"];
    self.mSex = [[obj objectForKeyMy:@"sex"] intValue];
    self.mAge = [[obj objectForKeyMy:@"age"] intValue];
    
    
    self.mDist = self.mSellerObj.mDist;
    
    
    NSArray* al = [obj objectForKeyMy:@"photos"];
    NSMutableArray* tmpa = NSMutableArray.new;
    NSMutableArray* tmpabig = NSMutableArray.new;
    for ( NSString* one in al ) {
        [tmpa addObject: one];
        [tmpabig addObject: one];
    }
    self.mPhots = tmpa;
    self.mPhotoBigs = tmpabig;
    
    
    self.mFav = [obj objectForKeyMy:@"collect"] != nil;
    
    //extend
    NSDictionary* objext = [obj objectForKeyMy:@"extend"];
    [self fetchExt:objext];
    
}
-(void)fetchExt:(NSDictionary*)objext
{
    self.mGoodsAvgPrice = [[objext objectForKeyMy:@"goodsAvgPrice"] floatValue];
    self.mOrderCount = [[objext objectForKeyMy:@"orderCount"] intValue];
    self.mCommentTotalCount = [[objext objectForKeyMy:@"commentTotalCount"] intValue];
    self.mCommentGoodCount = [[objext objectForKeyMy:@"commentGoodCount"] intValue];
    self.mCommentNeutralCount = [[objext objectForKeyMy:@"commentNeutralCount"] intValue];
    self.mCommentBadCount = [[objext objectForKeyMy:@"commentBadCount"] intValue];
    self.mCommentSpecialtyAvgScore = [[objext objectForKeyMy:@"commentSpecialtyAvgScore"] floatValue];
    self.mCommentCommunicateAvgScore = [[objext objectForKeyMy:@"commentCommunicateAvgScore"] floatValue];
    self.mCommentPunctualityAvgScore = [[objext objectForKeyMy:@"commentPunctualityAvgScore"] floatValue];
}


//order "1：距离排序2：人气排序3：好评排序"
//sort "0：正序 1：倒序"
+(void)getStaffList:(int)order sort:(int)sort keywords:(NSString*)keywords lng:(float)lng lat:(float)lat page:(int)page bdating:(BOOL)bdating
            goodsid:(int)goodsid sellerid:(int)sellerid block:(void(^)(SResBase* resb,NSArray* all))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(order) forKey:@"order"];
    [param setObject:NumberWithInt(sort) forKey:@"sort"];
    [param setObject:NumberWithInt(page) forKey:@"page"];
    [param setObject:NumberWithInt(goodsid) forKey:@"goodsId"];
    [param setObject:NumberWithInt(sellerid) forKey:@"sellerId"];
    
    if( keywords )
        [param setObject:keywords forKey:@"keywords"];
    if( bdating )
    {//"预约定位坐标,筛选+排序
        //        有此参数不传mapPoint"
        [param setObject:[NSString stringWithFormat:@"%.6f,%.6f",lat,lng] forKey:@"appointMapPoint"];
    }
    else
    {
        if( lng != 0.0f && lat != 0.0f )
            [param setObject:[NSString stringWithFormat:@"%.6f,%.6f",lat,lng] forKey:@"mapPoint"];
    }
    
    
    [[APIClient sharedClient] postUrl:@"staff.lists" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* ta = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                [ta addObject: [[SStaff alloc]initWithObj:one] ];
            }
            t = ta;
        }
        block( info , t);
    }];
}

-(void)getDetail:(void(^)(SResBase* resb))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt( _mId) forKey:@"staffId"];
    [[APIClient sharedClient] postUrl:@"staff.detail" parameters:param call:^(SResBase *info) {
        if( info.msuccess )
        {
            [self fetch:info.mdata];
        }
        block( info );
    }];
}

//添加/删除 收藏,接口自己判断是否已经收藏过了,并且会设置 mFav
-(void)Favit:(void(^)(SResBase*resb))block
{
    NSMutableDictionary * param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"staffId"];
    [[APIClient sharedClient] postUrl:(_mFav? @"collect.staff.delete" :@"collect.staff.create") parameters:param call:^(SResBase *info) {
        
        if( info.msuccess )
        {
            _mFav = !_mFav;
        }
        block(info);
        
    }];
    
}

-(BOOL)bshowGroup
{
    //return self.mSellerObj.mSellerType == E_ST_group ||  self.mSellerObj.mSellerType == E_ST_myself;
    return NO;
}



//获取卖家的预约时间信息
-(void)getDatingInfo:(int)goodsid duration:(int)duration block:(void(^)(SResBase* resb,NSArray* arr ))block
{
    NSMutableDictionary * param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(_mId) forKey:@"staffId"];
    [param setObject:NumberWithInt(goodsid) forKey:@"goodsId"];
    [param setObject:NumberWithInt(duration) forKey:@"duration"];
    
    [[APIClient sharedClient]postUrl:@"goods.appointday" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tmpa = NSMutableArray.new;
            int j =0;
            for ( NSDictionary* one in info.mdata ) {
                SDatingInfo* ff = [[SDatingInfo alloc]initWithObj:one];
                if( j == 0 ) ff.mDay = @"今天";
                else if( j == 1) ff.mDay = @"明天";
                else if( j == 2 ) ff.mDay = @"后天";
                [tmpa addObject:ff];
                j++;
            }
            t = tmpa;
        }
        block(info,t);
        
    }];
}


-(void)getStaffComments:(int)type page:(int)page block:(void(^)(SResBase* resb,NSArray* arr))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    [param setObject:NumberWithInt(type) forKey:@"type"];
    [param setObject:NumberWithInt(page) forKey:@"page"];
    //[param setObject:NumberWithInt(_mId) forKey:@"sellerId"];
    
    [[APIClient sharedClient] postUrl:@"rate.staff.lists" parameters:param call:^(SResBase *info) {
        
        NSArray* t = nil;
        if( info.msuccess )
        {
            NSMutableArray* tmpa = NSMutableArray.new;
            for ( NSDictionary* one in info.mdata ) {
                [tmpa addObject:[[SComments alloc] initWithObj: one]];
            }
            t = tmpa;
        }
        
        block(info,t);
        
    }];
}

//获取评价统计
-(void)getStaffCmmStatisic:(void(^)(SResBase* resb))block
{
    NSMutableDictionary* param = NSMutableDictionary.new;
    //[param setObject:NumberWithInt(_mId) forKey:@"sellerId"];
    [[APIClient sharedClient]postUrl:@"rate.statistics" parameters:param call:^(SResBase *info) {
        if( info.msuccess )
        {
            [self fetchExt:info.mdata];
        }
        block(info);
    }];
    
}

@end











