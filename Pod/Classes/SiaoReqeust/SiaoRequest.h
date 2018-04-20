//
//  SiaoRequest.h
//  SiaoPods
//
//  Created by xiaodong32 on 2017/4/7.
//  Copyright © 2017年 SiaoPods. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "SiaoDefine.h"
#import "SiaoResponseValidator.h"
#import "SiaoModelParser.h"

/* 使用文档
 零. 类说明
 1. 此类为抽象类，必须继承使用，继承后重写如下方法，定义环境；
 2. 在app初始化时，必须设置online和test环境的URL；
    eg:
     SiaoSetValue(kSiaoRequestOnlineURL, @"http://10.79.40.81:8133/");
     SiaoSetValue(kSiaoRequestTestURL, @"http://10.79.40.81:8133/");
 一. path
 1. path为完整路径(http://www.weibo.com/)则直接不用默认的网络环境(Online, Test)做请求(不拼接)
 2. path为资源路径(timeline/category) 使用网络环境做拼接后请求
 二. params
 此为一个Block，需要返回一个字典，使用规范为, { retrun @{"title" : "weibo"}
 三. finsh
 此为一个回调Block，请求结束后不管成功与否都会调用这个回调
 四.校验器
 + (SiaoResponseValidator *)requestValidator
 返回一个默认的校验器，当有特殊reponse处理时，通过请求参数params的block里传入实例化的对象，key为 kRequestValidator
 注意：当参数里有校验器的时候会使用传入的构造器，没有的时候使用默认校验器；
 五. 集约型请求，子类需要重写的方法
 //1.请求方法，默认为get
 - (HttpMethod)requestMethod;
 //2.请求路径，请参考文档第一套
 - (NSString *)requestPath;
 //3.请求参数, 返回一个字典
 - (NSDictionary *)generateParams;
 六. 网络状态
 1. + (NetworkReachabilityStatus)currentNetworkStatus; 返回枚举
 + (NSString *)networkStatusString; 返回文字
 **/
typedef NSDictionary*(^RequestParamsBlock)(void);
typedef void(^RequestSuccessBlock)(AFHTTPSessionManager *manager,  id jsonDict);
typedef void(^RequestFailureBlock)(AFHTTPSessionManager *manager, NSError *error);
typedef void(^RequestFinishBlock)(void);

typedef NS_ENUM(NSInteger, NetworkReachabilityStatus) {
    NetworkReachabilityStatusUnknown = -2,
    NetworkReachabilityStatusNotReachable = -1,
    NetworkReachabilityStatusReachableVia2G = 0,
    NetworkReachabilityStatusReachableVia3G = 1,
    NetworkReachabilityStatusReachableVia4G = 2,
    NetworkReachabilityStatusReachableViaWiFi = 3,
};

typedef enum : NSUInteger {
    HttpMethodGet,
    HttpMethodPost,
} HttpMethod;

typedef enum : NSUInteger {
    SiaoRequestEnvironmentOnline = 1,
    SiaoRequestEnvironmentTest,
    SiaoRequestEnvironmentTemp,
} SiaoRequestEnvironment;

SiaoDefineValue(kSiaoRequestTestURL, NSString *);
SiaoDefineValue(kSiaoRequestOnlineURL, NSString *);
SiaoDefineValue(kSiaoRequestTempURL, NSString *);
SiaoDefineValue(kSiaoRequestTimeOut, NSInteger);

extern NSString * const kRequestValidator;

@interface SiaoRequest : NSObject
+ (NSString *)environment;//调用次方法，请先设置online和test环境的URL；获取保存网络环境，没有保存的环境返回nil，
//----公共初始化数据 Require----//
+ (void)seteEnvironment:(SiaoRequestEnvironment)environment;//自定义当前环境映射的URL

//----公共初始化数据 Optional----//
+ (NSDictionary *)commonParams;//自定义公共参数
+ (SiaoResponseValidator *)requestValidator;//自定义默认校验器
+ (SiaoRequestEnvironment)getVironmentFromCache;//获取缓存 0为无缓存 >0为有缓存

//----Custom special request----//
- (HttpMethod)requestMethod;
- (NSString *)requestPath;
- (NSDictionary *)generateParams;

//----request----//
- (NSURLSessionTask *)start:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure finish:(RequestFinishBlock)finish;
- (void)cancel;
//
+ (NSURLSessionTask *)get:(NSString *)path params:(RequestParamsBlock)params success:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure;
+ (NSURLSessionTask *)post:(NSString *)path params:(RequestParamsBlock)params success:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure;
+ (NSURLSessionTask *)requestWithMethod:(HttpMethod)method path:(NSString *)path params:(RequestParamsBlock)params success:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure finish:(RequestFinishBlock)finish;

//-----NetworkStatus-------//
+ (NetworkReachabilityStatus)currentNetworkStatus;
+ (NSString *)networkStatusString;
@end
