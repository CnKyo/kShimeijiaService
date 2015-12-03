

#import "APIClient.h"
#import "dateModel.h"
#import "AppDelegate.h"
#import "CBCUtil.h"
#pragma mark -
#pragma mark APIClient

@interface APIClient ()

@end

#pragma mark -

@implementation APIClient
+ (instancetype)sharedClient {
    static APIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:kAFAppDotNetAPIBaseURLString]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    });
    _sharedClient.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"text/html",@"charset=UTF-8",@"text/plain",@"application/json",nil];;
    _sharedClient.requestSerializer.timeoutInterval = 10;
    return _sharedClient;
}

- (void)cancelHttpOpretion:(AFHTTPRequestOperation *)http
{
    for (NSOperation *operation in [self.operationQueue operations]) {
        if (![operation isKindOfClass:[AFHTTPRequestOperation class]]) {
            continue;
        }
        if ([operation isEqual:http]) {
            [operation cancel];
            break;
        }
    }
}


#pragma mark -

/**
 *  Get链接总方法
 *
 *  @param URLString  请求链接
 *  @param parameters 参数
 *  @param callback   返回网络数据
 */

-(NSString*)getmToken
{
    if( [SUser currentUser].mToken.length == 0 )
        return [GInfo shareClient].mGToken;
    return [SUser currentUser].mToken;
}

-(NSString*)getUserId
{
    if( [SUser currentUser].mUserId )
        return [NSString stringWithFormat:@"%d",[SUser currentUser].mUserId];
    return nil;
}


-(void)getUrl:(NSString *)URLString parameters:(id)parameters call:(void (^)(  SResBase* info))callback
{
    assert(@"oh ,,,no...");
    NSMutableDictionary* tparam = NSMutableDictionary.new;
    if( [self getmToken].length == 0 )
    {//如果没有tonken,,那么返回特定的错误
        if( ![URLString isEqualToString:@"app.init"] )
        {
            SResBase* itbase = [SResBase infoWithError:@"获取配置信息失败,正在重新获取"];
            callback( itbase );
            return;
        }
    }
    else
        [tparam setObject:[self getmToken] forKey:@"token"];
    
    if( [self getUserId].length )
    {
        [tparam setObject:[self getUserId] forKey:@"staffId"];
    }
    ///这2个参数是带再外面的
    
    if( parameters )//真正的参数需要弄到 Data里面
    {
        NSData* jj = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil
                      ];
        NSString *str = [[NSString alloc] initWithData:jj encoding:NSUTF8StringEncoding];
        [tparam setObject:str forKey:@"data"];
    }
    
    [self GET:URLString parameters:tparam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        MLLog(@"URL%@ data:%@",operation.response.URL,responseObject);
        
        SResBase* retob = [[SResBase alloc]initWithObj:responseObject];
        
        if( retob.mcode == 99996 )
        {//需要登陆
            [((AppDelegate*)[UIApplication sharedApplication].delegate) performSelector:@selector(gotoLogin) withObject:nil afterDelay:0.4f];
        }
        
        callback(  retob );
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        MLLog(@"error:%@",error.description);
        callback( [SResBase infoWithError: @"网络请求错误"] );
        
    }];
}




/**
 *  Post链接总方法
 *
 *  @param apiType    请求链接
 *  @param parameters 参数
 *  @param callback   返回网络数据
 */
-(void)postUrl:(NSString *)URLString parameters:(id)parameters call:(void (^)(  SResBase* info))callback
{
    BOOL binit = [URLString isEqualToString:@"app.init"];
    NSString* token = [self getmToken];
    
    NSMutableDictionary* tparam = NSMutableDictionary.new;
    if( token.length == 0 )
    {//如果没有tonken,,那么返回特定的错误
        if( !binit )
        {
            SResBase* itbase = [SResBase infoWithError:@"获取配置信息失败,正在重新获取"];
            callback( itbase );
            return;
        }
    }
    else
        [tparam setObject:token forKey:@"token"];
    
    if( [self getUserId].length )
    {
        [tparam setObject:[self getUserId] forKey:@"staffId"];
    }
    ///这2个参数是带再外面的
    
    if( parameters )//真正的参数需要弄到 Data里面
    {
        NSData* jj = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil
                      ];
        NSString *str = [[NSString alloc] initWithData:jj encoding:NSUTF8StringEncoding];
#ifdef ENC
        if( !binit )
        {
            int iv = [GInfo shareClient].mivint;
            NSString* key = token;//[Util URLDeCode:token];
            NSString* userid = [self getUserId];
            if( userid.length == 0 )
                userid = @"0";
            key = [Util md5:[key stringByAppendingString:userid]];
            
            iv = [Util gettopestV:iv];
            str = [CBCUtil CBCEncrypt:str key:key index:iv];
            if( str == nil )
            {
                SResBase* itbase = [SResBase infoWithError:@"程序处理错误"];
                callback( itbase );
                return;
            }
        }
#endif
        [tparam setObject:str forKey:@"data"];
    }
    
    [self POST:URLString parameters:tparam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        MLLog(@"URL%@ data:%@",operation.response.URL,responseObject);
#ifdef ENC
        
        NSString* getnewtoken = [responseObject objectForKeyMy:@"token"];
        int newuserid = [[responseObject objectForKeyMy:@"userId"] intValue];
        NSString* getnewuserid = nil;
        if( newuserid > 0 )
            getnewuserid = [NSString stringWithFormat:@"%d",newuserid];
        
        
        id fuckdata = [responseObject objectForKeyMy:@"data"];
        if( responseObject && fuckdata && [fuckdata isKindOfClass:[NSString class]] )
        {
            NSMutableDictionary* tresb = [[NSMutableDictionary alloc]initWithDictionary:responseObject];
            int ivint = 0;
            NSString* key = @"";
            if( binit )
            {
                NSString* tmpss = [tresb objectForKey:@"key"];
                char keyPtr[10]={0};
                [tmpss getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
                ivint  = (int)strtoul(keyPtr,NULL,24);
                key = [tresb objectForKey:@"token"];//[Util URLDeCode:[tresb objectForKey:@"token"]];
                NSString* userid = [self getUserId];
                if( 0 == userid.length )
                    userid = @"0";
                key = [Util md5:[key stringByAppendingString:userid]];
                
            }
            else
            {
                ivint = [GInfo shareClient].mivint;
                if( getnewtoken == nil )
                    key = [self getmToken];//[Util URLDeCode: [self getmToken]];
                else
                    key = getnewtoken;
                
                NSString* userid = @"0";
                if( getnewuserid == nil )
                    userid = [self getUserId];
                else
                    userid = getnewuserid;
                
                if( userid.length == 0  )
                    userid = @"0";
                key = [Util md5:[key stringByAppendingString:userid]];
            }
            
            ivint = [Util gettopestV:ivint];
            
            NSString* dat = [CBCUtil CBCDecrypt:fuckdata key:key index:ivint];
            
            NSError* jsonerrr = nil;
            id datobj = nil;
            if( dat )
            {
                datobj = [NSJSONSerialization JSONObjectWithData:[dat dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonerrr];
            }
            
            if( datobj )
            {
                [tresb setObject:datobj forKey:@"data"];
            }
            else
            {
                [tresb setObject:[NSNumber numberWithInt:9997] forKey:@"code"];
                [tresb setObject:@"程序处理错误" forKey:@"msg"];
                [tresb removeObjectForKey:@"data"];
                NSLog(@"json err:%@",jsonerrr.description);
            }
            responseObject = tresb;
        }
#endif
        SResBase* retob = [[SResBase alloc]initWithObj:responseObject];
        
        if( retob.mcode == 99996 )
        {//需要登陆
            [((AppDelegate*)[UIApplication sharedApplication].delegate) performSelector:@selector(gotoLogin) withObject:nil afterDelay:0.4f];
        }
        callback(  retob );
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        MLLog(@"url:%@ error:%@",operation.response.URL, error.description);
        callback( [SResBase infoWithError:@"网络请求错误"] );
        
    }];
}







@end





