//
//  SiaoRequest.h
//  SiaoPods
//
//  Created by xiaodong32 on 2017/4/7.
//  Copyright © 2017年 SiaoPods. All rights reserved.
//

#import "SiaoRequest.h"

SiaoDefineValue(kSiaoRequestServerAddress, NSString *);
SiaoImpValue(kSiaoRequestServerAdrress, NSString *);
SiaoImpValue(kSiaoRequestBaseInfoDict, NSDictionary *);
SiaoImpValue(kSiaoRequestCacheDir, NSString *);
SiaoImpValue(kSiaoRequestTimeOut, NSInteger);

NSString * const kSiaoValidator = @"kSiaoValidator";
NSString * const kCachedKeyEnvironment = @"kCachedEnvironment";
NSString * _baseURL;

@implementation SiaoRequest

+ (void)seteEnvironment:(NSString *)baseURL {
    @synchronized(self){
        _baseURL = baseURL;
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        [userdefault setObject:baseURL forKey:kCachedKeyEnvironment];
        [userdefault synchronize];
    }
}

+ (NSString *)environment {
    NSString *baseURL ;
    @synchronized(self){
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        baseURL = [userdefault objectForKey:kCachedKeyEnvironment];
    }
    return baseURL;
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

    AFHTTPSessionManager *manager = [self requestManager];
    NSDictionary *param = params();
    SiaoRequestValidator *validator = [self reqeustValidatorFromParams:param];
    
    NSString *urlPath = nil;
    if ([path hasPrefix:@"http"] || [path hasPrefix:@"https"]) {
        urlPath = path;
    }else{
        urlPath = [environment stringByAppendingString:path];
    }
    
    NSMutableDictionary *queryParams = nil;
    NSDictionary *commonParams = [self commonParams];
    if (commonParams) {
        queryParams = [NSMutableDictionary dictionaryWithDictionary:commonParams];
        [queryParams addEntriesFromDictionary:param];
    }else {
        queryParams = [commonParams mutableCopy];
    }
    
    void (^SuccessBlock)(NSURLSessionTask *, id) = ^(NSURLSessionTask *operation, id responseObject){
        NSDictionary *jsonDict = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            jsonDict = responseObject;
        }
        NSLog(@"Request path: %@ jsonDict:%@", path, jsonDict);
        
        SiaoRequestError *error = [validator isAvailbaleJson:jsonDict];
        if (error) {
            if (failure) { failure(manager, error); }
        }else{
            if (success) { success(manager, [self dealWithOriginData:jsonDict]); }
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
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", @"text/html", nil];
    return manager;
}

+ (SiaoRequestValidator *)reqeustValidatorFromParams:(NSDictionary *)params {
    SiaoRequestValidator *validator = params[kSiaoValidator];
    if (validator && [validator isKindOfClass:[SiaoRequestValidator class]]) {
        return validator;
    }
    validator = [SiaoRequestValidator new];//default
    return validator;
}

#pragma mark -
+ (NSDictionary *)commonParams {
    return nil;
}

+ (id)dealWithOriginData:(id)json {
    return json;
}

#pragma mark - OOP
- (HttpMethod)requestMethod
{
    return HttpMethodGet;
}

- (NSString *)requestPath
{
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

#pragma mark - Deprecated

- (NSString *)queryStrAddSaltForQueryParam:(NSMutableDictionary *)queryParams {
    if (queryParams.count == 0) {
        return nil;
    }
    NSString *queryStr = AFQueryStringFromParameters(queryParams);
    return queryStr;
}
@end
