//
//  Util.h
//  WeiDianApp
//
//  Created by zzl on 14/12/5.
//  Copyright (c) 2014年 allran.mine. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _RelDic
{
    E_dic_l = 1,    //左边
    E_dic_r = 2,    //右边
    E_dic_t = 3,    //上面
    E_dic_b = 4,    //下面
    
}RelDic;




@interface Util : NSObject

+(BOOL)checkSFZ:(NSString *)numStr;                         //验证身份证


+(UIImage*)scaleImg:(UIImage*)org maxsize:(CGFloat)maxsize; //缩放图片

+(NSDate*)dateWithInt:(double)second;

+(NSString*)getTimeStringHourSecond:(double)second;

+(NSString*)getTimeStringWithP:(double)time;//获取时间 2015.04.15

+(NSString*)getTimeString:(NSDate*)dat bfull:(BOOL)bfull;   //date转字符串

+(NSString*)getTimeStringHour:(NSDate*)dat;   //date转字符串 2015-03-23 08:00

+(void)relPosUI:(UIView*)base dif:(CGFloat)dif tag:(UIView*)tag tagatdic:(RelDic)dic;

+(NSString *)dateForint:(double)time bfull:(BOOL)bfull;       //时间戳转字符串

+(NSString *) FormartTime:(NSDate*) compareDate;            //格式化时间

+ (BOOL)isMobileNumber:(NSString *)mobileNum;               //检测是否是手机号
+(BOOL)checkPasswdPre:(NSString *)passwd;                    //检测密码合法性

+ (NSString *)md5:(NSString *)str;

+ (NSString *)md5_16:(NSString *)str;

+(void)md5_16_b:(NSString*)str outbuffer:(char*)outbuffer;

//把nsnull字段干掉
+(NSDictionary*)delNUll:(NSDictionary*)dic;

//把nsnull字段干掉
+(NSArray*)delNullInArr:(NSArray*)arr;

//#87fd74 ==> UIColor
+(UIColor*)stringToColor:(NSString*)str;

//距离描述   dist:米
+(NSString*)getDistStr:(int)dist;

//生成微信签名
+ (NSString *)genWxSign:(NSDictionary *)signParams parentkey:(NSString*)parentkey;

+ (NSString *)genWXClientSign:(NSDictionary *)signParams;

    
+ (NSString *)sha1:(NSString *)input;

+ (NSString *)getIPAddress:(BOOL)preferIPv4;

+ (NSDictionary *)getIPAddresses;

//requrl http://api.fun.com/getxxxx
//
+(NSString*)makeURL:(NSString*)requrl param:(NSDictionary*)param;

//生成XML
+(NSString*)makeXML:(NSDictionary*)param;

+(NSString*)getAppVersion;

+(int)gettopestV:(int)v;

+(NSString*)URLEnCode:(NSString*)str;

+(NSString*)URLDeCode:(NSString*)str;


//20150416 => 4月16日
+(NSString*)convdatestr:(NSString*)str;






@end
