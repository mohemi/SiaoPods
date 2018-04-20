//
//  SiaoRequest.h
//  SiaoPods
//
//  Created by xiaodong32 on 2017/4/7.
//  Copyright © 2017年 SiaoPods. All rights reserved.
//

#import "SiaoRequest.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

SiaoImpValue(kSiaoRequestTestURL, NSString *);
SiaoImpValue(kSiaoRequestOnlineURL, NSString *);
SiaoImpValue(kSiaoRequestTempURL, NSString *);
SiaoImpValue(kSiaoRequestTimeOut, NSInteger);

NSString * const kRequestValidator = @"kSiaoValidator";
NSString * const kCachedKeyEnvironment = @"kCachedEnvironment";
NSString * const kTempIdentify = @"kTempIdentify";

@implementation SiaoRequest

#pragma mark - Environment
+ (void)seteEnvironment:(SiaoRequestEnvironment)environment {
    @synchronized(self){
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        [userdefault setInteger:environment forKey:kCachedKeyEnvironment];
        [userdefault synchronize];
    }
}

+ (SiaoRequestEnvironment)getVironmentFromCache
{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    SiaoRequestEnvironment environment = [userdefault integerForKey:kCachedKeyEnvironment];//Don't be afraid problem of safety-thread
    return environment;
}

+ (NSString *)environment {
    @synchronized(self){
        SiaoRequestEnvironment environment = [self getVironmentFromCache];
        switch (environment) {
            case SiaoRequestEnvironmentTest:
                return SiaoValue(kSiaoRequestTestURL, nil);
                break;
            case SiaoRequestEnvironmentOnline:
                return SiaoValue(kSiaoRequestOnlineURL, nil);
                break;
            default:
                return nil;
                break;
        }
    }
}

#pragma mark - Request
+ (NSURLSessionTask *)get:(NSString *)path params:(RequestParamsBlock)params success:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure {
    return [self requestWithMethod:HttpMethodGet path:path params:params success:success failure:failure finish:nil];
}

+ (NSURLSessionTask *)post:(NSString *)path params:(RequestParamsBlock)params success:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure {
    return [self requestWithMethod:HttpMethodPost path:path params:params success:success failure:failure finish:nil];
}

+ (NSURLSessionTask *)requestWithMethod:(HttpMethod)method path:(NSString *)path params:(RequestParamsBlock)params success:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure finish:(RequestFinishBlock)finish {
    if (finish) { finish(); }
    
    NSString *environment = [self environment];
    NSAssert(environment.length > 0, @"Pls init the environment for requests.");

    NSString *urlPath = nil;
    if ([path hasPrefix:@"http"] || [path hasPrefix:@"https"]) {
        urlPath = path;
    }else{
        urlPath = [environment stringByAppendingString:path];
    }
    AFHTTPSessionManager *manager = [self requestManager];
    NSDictionary *param = params();
    SiaoResponseValidator *validator = [self reqeustValidatorFromParams:param];
    
    NSDictionary *commonParams = [self commonParams];
    NSMutableDictionary *queryParams = commonParams ? [NSMutableDictionary dictionaryWithDictionary:commonParams] : [NSMutableDictionary dictionary];
    if (param) { [queryParams addEntriesFromDictionary:param]; }
    
    DefineWeak(validator);
    void (^SuccessBlock)(NSURLSessionTask *, id) = ^(NSURLSessionTask *operation, id responseObject){
        DefineStrong(weak_validator);
        NSDictionary *jsonDict = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            jsonDict = responseObject;
        }
        NSLog(@"Request url%@ path: %@ jsonDict:%@", urlPath, path, jsonDict);
        
        SiaoRequestError *error = [validator isAvailbaleJson:jsonDict];
        if (error) {
            if (failure) { failure(manager, error); }
        }else{
            if (success) { success(manager, [strong_weak_validator handleResponseForReturnData:jsonDict]); }
        }
    };
    
    void (^FailureBlock)(NSURLSessionTask *, NSError *) = ^(NSURLSessionTask *task, NSError *error){
        NSLog(@"Request error:%@", error);
        if (failure) { failure(manager, error); }
    };
    
    NSURLSessionTask *task = nil;
    switch (method) {
        case HttpMethodPost:{
            task = [manager POST:urlPath parameters:queryParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                SuccessBlock(task, responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                FailureBlock(task, error);
            }];
        }
            break;
        default:{
            task = [manager GET:urlPath parameters:queryParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                SuccessBlock(task, responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                FailureBlock(task, error);
            }];
        }
            break;
    }
    return task;
}

#pragma mark -

+ (AFHTTPSessionManager *)requestManager {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval:SiaoValue(kSiaoRequestTimeOut, 60)];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"application/javascript", @"text/json", @"text/javascript", @"text/plain", @"text/html", nil];
    return manager;
}

+ (SiaoResponseValidator *)reqeustValidatorFromParams:(NSDictionary *)params {
    static SiaoResponseValidator *validator;
    SiaoResponseValidator *newValidator = params[kRequestValidator];
    if (newValidator && [newValidator isKindOfClass:[SiaoResponseValidator class]]) { return newValidator; }
    if (validator) { return validator; }
    newValidator = [self requestValidator];
    return newValidator;
}

+ (SiaoResponseValidator *)requestValidator
{
    return [[SiaoResponseValidator alloc] initWithKeys:@"status" messageKey:@"messages" dataKey:@"data"];//default
}

#pragma mark -
+ (NSDictionary *)commonParams {
    return nil;
}

#pragma mark - OOP
- (HttpMethod)requestMethod {
    return HttpMethodGet;
}

- (NSString *)requestPath {
    return nil;
}

- (NSDictionary *)generateParams {
    return nil;
}

- (NSURLSessionTask *)start:(RequestSuccessBlock)success failure:(RequestFailureBlock)failure finish:(RequestFinishBlock)finish {
    HttpMethod method = [self requestMethod];
    NSString *path = [self requestPath];
    
    NSDictionary *parapms = [self generateParams];
    NSDictionary* (^paramsBlock)(void) = ^(){
        return parapms;
    };
    return [[self class] requestWithMethod:method path:path params:paramsBlock success:success failure:failure finish:finish];
}

- (void)cancel {
    [self cancel];
}

#pragma mark - Network Statu
+ (NetworkReachabilityStatus)currentNetworkStatus {
    NetworkReachabilityStatus status = NetworkReachabilityStatusUnknown;
    
    struct sockaddr_storage zeroAddress;//创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.ss_len = sizeof(zeroAddress);
    zeroAddress.ss_family = AF_INET;
    
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;// Recover reachability flags
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);//获得连接的标志
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags){ return status; }//如果不能获取连接标志，则不能连接网络，直接返回
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0){ status = NetworkReachabilityStatusReachableViaWiFi; }
    
    if (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0){
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0){
            status = NetworkReachabilityStatusReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN){
        CTTelephonyNetworkInfo * info = [[CTTelephonyNetworkInfo alloc] init];
        NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;
        
        if (currentRadioAccessTechnology){
            if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]){
                status = NetworkReachabilityStatusReachableVia4G;
            }else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]){
                status = NetworkReachabilityStatusReachableVia2G;
            }else{
                status = NetworkReachabilityStatusReachableVia3G;
            }
        }
    }
    
    return status;
}

+ (NSString *)networkStatusString {
    NSString *statusString = nil;
    NetworkReachabilityStatus netStatus = [self currentNetworkStatus];
    switch (netStatus) {
        case NetworkReachabilityStatusReachableVia2G:
            statusString = @"2G";
            break;
        case NetworkReachabilityStatusReachableVia3G:
            statusString = @"3G";
            break;
        case NetworkReachabilityStatusReachableVia4G:
            statusString = @"4G";
            break;
        case NetworkReachabilityStatusReachableViaWiFi:
            statusString = @"Wi-Fi";
            break;
        case NetworkReachabilityStatusUnknown:
        default:
            statusString = @"UnReachable";
            break;
    }
    return statusString;
}
@end
