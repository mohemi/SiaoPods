//
//  SiaoModelParser.h
//  LearnObjective-C
//
//  Created by xiaodong32 on 17/04/2018.
//  Copyright © 2018 SiaoPods. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

@interface SiaoModelParser : NSObject
+ (id _Nullable )parseWithResponse:(__nonnull id)response targetClass:(Class _Nonnull )targetClass;
+ (id _Nullable )operation:(__nonnull id)returnData targetClass:(Class _Nonnull )targetClass;
@end
