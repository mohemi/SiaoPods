//
//  SiaoRequest.h
//  SiaoPods
//
//  Created by xiaodong32 on 2017/4/7.
//  Copyright © 2017年 SiaoPods. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "SiaoDefine.h"
#import "SiaoRequestValidator.h"

typedef NSDictionary*(^RequestParamsBlock)(void);
typedef void(^RequestSuccessBlock)(AFHTTPSessionManager *manager,  id jsonDict);
typedef void(^RequestFailureBlock)(AFHTTPSessionManager *manager, NSError *error);
typedef void(^RequestFinishBlock)(void);

typedef enum : NSUInteger {
    HttpMethodGet,
    HttpMethodPost,
} HttpMethod;

typedef enum : NSUInteger {
    SiaoRequestEnvironmentOnline,
    SiaoRequestEnvironmentTest,
    SiaoRequestEnvironmentTemp,
} SiaoRequestEnvironment;

SiaoDefineValue(kSiaoRequestBaseInfoDict, NSDictionary *);
SiaoDefineValue(kSiaoRequestCacheDir, NSString *);
SiaoDefineValue(kSiaoRequestTimeOut, NSInteger);

extern NSString * const kSiaoValidator;

@interface SiaoRequest : NSObject
//----公共初始化数据----//
+ (void)seteEnvironment:(NSString *)baseURL;//自定义当前环境映射的URL
+ (NSDictionary *)commonParams;//自定义公共参数
+ (SiaoRequestValidator *)reqeustValidatorFromParams:(NSDictionary *)params;//自定义校验器
+ (id)dealWithOriginData:(id)json;//自定义处理不同的response返回 比如，只取data的值、取json里所有的值 etc.. 默认返回原数据

//----Custom special request----//
- (HttpMethod)requestMethod;
- (NSString *)requestPath;
- (NSDictionary *)generateParams;

//----request----//
- (NSURLSessionTask *)start:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure finish:(RequestFinishBlock)finish;
- (void)cancel;

+ (NSURLSessionTask *)get:(NSString *)path params:(RequestParamsBlock)params success:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure;
+ (NSURLSessionTask *)post:(NSString *)path params:(RequestParamsBlock)params success:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure;
+ (NSURLSessionTask *)requestWithMethod:(HttpMethod)method path:(NSString *)path params:(RequestParamsBlock)params success:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure finish:(RequestFinishBlock)finish;
@end
