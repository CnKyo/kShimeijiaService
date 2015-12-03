//
//  PartnerConfig.h
//  AlipaySdkDemo
//
//  Created by ChaoGanYing on 13-5-3.
//  Copyright (c) 2013年 RenFei. All rights reserved.
//
//  提示：如何获取安全校验码和合作身份者id
//  1.用您的签约支付宝账号登录支付宝网站(www.alipay.com)
//  2.点击“商家服务”(https://b.alipay.com/order/myorder.htm)
//  3.点击“查询合作者身份(pid)”、“查询安全校验码(key)”
//

#ifndef MQPDemo_PartnerConfig_h
#define MQPDemo_PartnerConfig_h

//合作身份者id，以2088开头的16位纯数字
//#define PartnerID @"2088511169981548"
#define PartnerID [[GInfo shareClient] geAiPayInfo].mPartnerId

//收款支付宝账号
//#define SellerID  @"cw@zywl.com"
#define SellerID    [[GInfo shareClient] geAiPayInfo].mSellerId

//安全校验码（MD5）密钥，以数字和字母组成的32位字符
#define MD5_KEY @"rfxmxvu2p0ctpikblf9ey7vc30xiqn2l"

//商户私钥，自助生成
/*
#define PartnerPrivKey @"MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBANXH7PgNjpdkuav7Lrpi1yMifPVsiq8JBTx0FcCCxN8u2WmLWolKsAKvG/lb3rCFnAUHYBaP4pZa/ZxvkZ9jTsciw1upPiXbQyCG0UW8wX64/c96CWZB5Jh19i4dbkFWrwlwwz0gImeWk1xFE9MBaHjXAuA6GxEYOKnssedfssQNAgMBAAECgYEAvo1l+/SZlPiDR3itPhW8DeU/3MLTGxG/SRNwEBh/wy/POvSrzpR0LvBGzw3EgTOWziS00WePYNXaGQaZlqi+HcA8lgKeUP0igrzgB1a71e714ZBqY7PPZI3ZYgSLTQ6a4/p12tOqBW2ZcNDYmVBIno42cN8+Hb/IHHVaidT360ECQQD5zQl4uEE5E/Fwbaxnk+OvWq39Jog4XExDWRLvgxRvWKd3A+nkWnVZ1t/eBxjS+74COdOlYrN9XlP5k8Ep3WAnAkEA2xYOmXhqKF/YoorYsIcXKz3y1PjL0INaTbAtxQjCEiUCK9ams7s3DzwbdGak050dvMh+AbAI6W3hSOlItdxmqwJBAM8gUPs1JHe0bpy/g5W6za7HrL7cZVT+SwoI4KeSc65Dv0/zAcwjqWxdu/B4x/+hV5K26iQXLCcGwPCPsDoLYj8CQGgK0oYZhDiGQ+f1DjDPBra3ZaG0QX5VUsZAG4xNu3RIdP6CoooKJ3ypq9QchrwkCiJECGsewSyxzOIGP0x2TZ8CQQCWpsyXPnKLuvT2bpCpZLWGMAOCMXFqMe63HyzgdBT/0QPSy2/mWmKZdKjG/qoAxHtd68Ko3ZdXxsOLA9VMc8Oo"
 */

#define PartnerPrivKey [[GInfo shareClient] geAiPayInfo].mPartnerPrivKey

/*
//支付宝公钥
#define AlipayPubKey   @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB"
*/

#define AlipayPubKey    [[GInfo shareClient] geAiPayInfo].mAlipayPubKey


#define NotifURL @"http://vso2o.jikesoft.com/pay/callback/alipay"

#endif

/*
 
 合作者身份（PID） 2088511169981548
 安全校验码（Key） rfxmxvu2p0ctpikblf9ey7vc30xiqn2l
 
 */
