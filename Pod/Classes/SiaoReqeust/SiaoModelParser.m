//
//  SiaoModelParser.m
//  LearnObjective-C
//
//  Created by xiaodong32 on 17/04/2018.
//  Copyright © 2018 SiaoPods. All rights reserved.
//

#import "SiaoModelParser.h"

@implementation SiaoModelParser

+ (id _Nullable )parseWithResponse:(__nonnull id)response targetClass:(Class _Nonnull )targetClass;
{
    id returnData;
    if ([response isKindOfClass:[NSArray class]]) {
        returnData = [NSArray yy_modelArrayWithClass:targetClass json:response];
    }else {
        id ClassType = NSClassFromString(NSStringFromClass(targetClass));
        returnData = [ClassType yy_modelWithJSON:response];
    }
    if (returnData) { returnData = [self operation:returnData targetClass:targetClass]; }
    return returnData;
}

+ (id _Nullable )operation:(__nonnull id)returnData targetClass:(Class _Nonnull )targetClass {
    return returnData;
}
@end
