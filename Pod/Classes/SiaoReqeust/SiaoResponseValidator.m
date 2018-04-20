//
//  SiaoResponseValidator.m
//  LearnObjective-C
//
//  Created by xiaodong32 on 16/04/2018.
//  Copyright © 2018 SiaoPods. All rights reserved.
//

#import "SiaoResponseValidator.h"
#import "SiaoRequestError.h"

@implementation SiaoResponseValidator {
    NSString *_statusKey;
    NSString *_messageKey;
    NSString *_dataKey;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSAssert(NO, @"The operation is invalidate, instance must be call initWithKeys ini.");
    }
    return self;
}

- (instancetype)initWithKeys:(NSString * __nonnull)statusKey messageKey:(NSString * __nonnull)messageKey dataKey:(NSString * __nonnull)dataKey {
    self = [super init];
    if (self) {
        _statusKey = statusKey;
        _messageKey = messageKey;
        _dataKey = dataKey;
    }
    return self;
}

- (SiaoRequestError *)isAvailbaleJson:(id)json
{
    return nil;//defalut setting
}

- (SiaoRequestError *)isAvailbaleResponse:(id)response
{
    return nil;//defalut setting
}

- (SiaoRequestError *)errorForJson:(id)response
{
    return [[SiaoRequestError alloc] initWithDomain:@"SiaoRequestError" code:-1 userInfo:response];
}

- (id)handleResponseForReturnData:(id)json {
    BOOL status = [json[_statusKey] boolValue];
    if (status) { return json[_dataKey]; }
    return json;
}
@end
