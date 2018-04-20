//
//  SiaoResponseValidator.h
//  LearnObjective-C
//
//  Created by xiaodong32 on 16/04/2018.
//  Copyright © 2018 SiaoPods. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SiaoRequestError.h"

@interface SiaoResponseValidator : NSObject
@property (nonatomic, strong, readonly, nonnull) NSString *statusKey;
@property (nonatomic, strong, readonly, nonnull) NSString *messageKey;
@property (nonatomic, strong, readonly, nonnull) NSString *dataKey;

//唯一构造器，不能使用默认构造器
- (instancetype _Nonnull )initWithKeys:(NSString * __nonnull)statusKey messageKey:(NSString * __nonnull)messageKey dataKey:(NSString * __nonnull)dataKey;//
- (SiaoRequestError *_Nonnull)isAvailbaleJson:(id __nonnull)json;//验证是否是有效的json
- (SiaoRequestError * __nonnull)isAvailbaleResponse:(id __nonnull)response;//验证response是否有效
- (SiaoRequestError * __nonnull)errorForJson:(id __nonnull)response;//错误码码表
- (id __nonnull)handleResponseForReturnData:(id __nonnull)response;//处理不同的response 返回处理完后的response
@end
