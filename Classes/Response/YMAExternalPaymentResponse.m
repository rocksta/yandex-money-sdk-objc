//
// Created by Alexander Mertvetsov on 28.01.14.
// Copyright (c) 2014 Yandex.Money. All rights reserved.
//

#import "YMAExternalPaymentResponse.h"
#import "YMAExternalPaymentInfo.h"

static NSString *const kParameterRequestId = @"request_id";
static NSString *const kParameterContractAmount = @"contract_amount";
static NSString *const kParameterTitle = @"title";

@implementation YMAExternalPaymentResponse

#pragma mark -
#pragma mark *** Overridden methods ***
#pragma mark -

- (void)parseJSONModel:(id)responseModel error:(NSError * __autoreleasing *)error {
    [super parseJSONModel:responseModel error:error];

    if (error && *error) return;

    NSString *requestId = [responseModel objectForKey:kParameterRequestId];
    NSString *contractAmount = [[responseModel objectForKey:kParameterContractAmount] stringValue];
    NSString *title = [responseModel objectForKey:kParameterTitle];

    _paymentRequestInfo = [YMAExternalPaymentInfo paymentRequestInfoWithId:requestId amount:contractAmount andTitle:title];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, %@>", [self class], (__bridge void *) self,
                                      @{
                                              @"requestId" : self.paymentRequestInfo.requestId,
                                              @"contract amount" : self.paymentRequestInfo.amount,
                                              @"title" : self.paymentRequestInfo.title
                                      }];
}

@end