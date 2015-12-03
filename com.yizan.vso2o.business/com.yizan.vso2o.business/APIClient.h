

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFURLResponseSerialization.h"

//#define ENC

//static NSString* const  kAFAppDotNetAPIBaseURLString    = @"http://192.168.1.116/staff/v1/";

//static NSString* const  kAFAppDotNetAPIBaseURLString    = @"http://api2.vso2o.jikesoft.com/staff/v1/";

static NSString* const  kAFAppDotNetAPIBaseURLString    = @"http://api.shimeijiavip.com/staff/v1/";


@class SResBase;

@interface APIClient : AFHTTPRequestOperationManager

+ (APIClient *)sharedClient;

-(void)getUrl:(NSString *)URLString parameters:(id)parameters call:(void (^)( SResBase* info))callback;

-(void)postUrl:(NSString *)URLString parameters:(id)parameters call:(void (^)( SResBase* info))callback;

- (void)cancelHttpOpretion:(AFHTTPRequestOperation *)http;

-(NSString*)getmToken;

-(NSString*)getUserId;

@end
