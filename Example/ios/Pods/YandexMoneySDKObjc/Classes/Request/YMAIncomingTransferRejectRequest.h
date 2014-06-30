//
// Created by Alexander Mertvetsov on 27.05.14.
// Copyright (c) 2014 Yandex.Money. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMABaseRequest.h"
#import "YMAIncomingTransferRejectResponse.h"

@interface YMAIncomingTransferRejectRequest : YMABaseRequest <YMAParametersPosting>

+ (instancetype)rejectIncomingTransferWithOperationId:(NSString *)operationId;

@end