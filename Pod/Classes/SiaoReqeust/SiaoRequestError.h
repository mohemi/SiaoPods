//
//  SiaoRequestError.h
//  LearnObjective-C
//
//  Created by xiaodong32 on 16/04/2018.
//  Copyright © 2018 SiaoPods. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    RequestErrorTypeNone = 0,
    RequestErrorTypeDataError,
} RequestErrorType;

extern NSString * const kSiaoErrorDomain;

@interface SiaoRequestError : NSError
@property (nonatomic, assign, readonly) RequestErrorType errorType;
@end
