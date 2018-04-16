//
//  SiaoRequestValidator.h
//  LearnObjective-C
//
//  Created by xiaodong32 on 16/04/2018.
//  Copyright © 2018 SiaoTun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SiaoRequestError.h"

@interface SiaoRequestValidator : NSObject

- (SiaoRequestError *)isAvailbaleJson:(id)json;
- (SiaoRequestError *)isAvailbaleResponse:(id)response;
- (SiaoRequestError *)errorForJson:(id)response;
@end
