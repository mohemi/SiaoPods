//
//  SiaoRequestValidator.m
//  LearnObjective-C
//
//  Created by xiaodong32 on 16/04/2018.
//  Copyright © 2018 SiaoTun. All rights reserved.
//

#import "SiaoRequestValidator.h"
#import "SiaoRequestError.h"

@implementation SiaoRequestValidator

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
@end
