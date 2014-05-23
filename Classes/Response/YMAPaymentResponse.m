//
// Created by Alexander Mertvetsov on 21.05.14.
// Copyright (c) 2014 Yandex.Money. All rights reserved.
//

#import "YMAPaymentResponse.h"
#import "YMAPaymentInfo.h"
#import "YMAMoneySources.h"
#import "YMAWalletSourceGroup.h"
#import "YMAMoneySource.h"
#import "YMACardsSourceGroup.h"

static NSString *const kParameterRequestId = @"request_id";
static NSString *const kParameterMoneySource = @"money_source";
static NSString *const kParameterContractAmount = @"contract_amount";
static NSString *const kParameterBalance = @"balance";
static NSString *const kParameterRecipientAccountStatus = @"recipient_account_status";
static NSString *const kParameterRecipientAccountType = @"recipient_account_type";
static NSString *const kParameterProtectionCode = @"protection_code";
static NSString *const kParameterExtActionUri = @"ext_action_uri";
static NSString *const kParameterMoneySourceWallet = @"wallet";
//static NSString *const kParameterMoneySourceCard = @"card";
static NSString *const kParameterMoneySourceCards = @"сards";
static NSString *const kParameterMoneySourceItems = @"items";
static NSString *const kParameterMoneySourceId = @"id";
static NSString *const kParameterMoneySourcePanFragment = @"pan_fragment";
static NSString *const kParameterMoneySourceType = @"type";
static NSString *const kParameterMoneySourceAllowed = @"allowed";
static NSString *const kParameterMoneySourceCscRequired = @"csc_required";

@implementation YMAPaymentResponse

+ (YMAMoneySources *)moneySourcesFromModel:(id)moneySourcesModel {
    if (!moneySourcesModel)
        return nil;

    YMAWalletSourceGroup *walletSourceGroup = nil;

    id walletModel = [moneySourcesModel objectForKey:kParameterMoneySourceWallet];

    if (walletModel) {
        BOOL walletAllowed = [[walletModel objectForKey:kParameterMoneySourceAllowed] boolValue];
        walletSourceGroup = [YMAWalletSourceGroup walletMoneySourceWithAllowed:walletAllowed];
    }

    YMACardsSourceGroup *cardsSourceGroup = nil;

    id cardsModel = [moneySourcesModel objectForKey:kParameterMoneySourceCards];

    if (!cardsModel)
        return [YMAMoneySources moneySourcesWithWallet:walletSourceGroup cardsSource:nil];

    NSMutableArray *cards = nil;
    YMAMoneySource *defaultCard = nil;

    BOOL cardsAllowed = [[cardsModel objectForKey:kParameterMoneySourceAllowed] boolValue];
    BOOL isCscRequired = [[cardsModel objectForKey:kParameterMoneySourceCscRequired] boolValue];

    NSArray *cardsModelItems = [cardsModel objectForKey:kParameterMoneySourceItems];

    if (cardsModelItems) {
        cards = [NSMutableArray array];

        for (id cardModel in cardsModelItems) {
            NSString *cardId = [cardModel objectForKey:kParameterMoneySourceId];
            NSString *panFragment = [cardModel objectForKey:kParameterMoneySourcePanFragment];
            NSString *cardTypeString = [cardModel objectForKey:kParameterMoneySourceType];
            YMAPaymentCardType cardType = [YMAMoneySource paymentCardTypeByString:cardTypeString];
            cardsAllowed = [[cardModel objectForKey:kParameterMoneySourceAllowed] boolValue];
            isCscRequired = [[cardModel objectForKey:kParameterMoneySourceCscRequired] boolValue];
            YMAMoneySource *card = [YMAMoneySource moneySourceWithType:YMAMoneySourcePaymentCard cardType:cardType panFragment:panFragment moneySourceToken:cardId];
            [cards addObject:card];
        }

        defaultCard = cards.count ? cards[0] : nil;
    }

    cardsSourceGroup = [YMACardsSourceGroup cardsSourceWithCards:cards defaultCard:defaultCard cscRequired:isCscRequired allowed:cardsAllowed];

    return [YMAMoneySources moneySourcesWithWallet:walletSourceGroup cardsSource:cardsSourceGroup];
}


#pragma mark -
#pragma mark *** Overridden methods ***
#pragma mark -

- (void)parseJSONModel:(id)responseModel error:(NSError * __autoreleasing *)error {
    [super parseJSONModel:responseModel error:error];

    if (error && *error) return;

    NSString *requestId = [responseModel objectForKey:kParameterRequestId];
    NSString *contractAmount = [[responseModel objectForKey:kParameterContractAmount] stringValue];
    NSString *balance = [[responseModel objectForKey:kParameterBalance] stringValue];

    NSString *accountStatusString = [responseModel objectForKey:kParameterRecipientAccountStatus];
    YMAAccountStatus accountStatus = [YMAAccountInfo accountStatusByString:accountStatusString];

    NSString *accountTypeString = [responseModel objectForKey:kParameterRecipientAccountType];
    YMAAccountType accountType = [YMAAccountInfo accountTypeByString:accountTypeString];

    NSString *protectionCode = [responseModel objectForKey:kParameterProtectionCode];
    NSString *extActionUriString = [responseModel objectForKey:kParameterExtActionUri];
    NSURL *extActionUri = [NSURL URLWithString:extActionUriString];

    id moneySourcesModel = [responseModel objectForKey:kParameterMoneySource];
    YMAMoneySources *moneySources = [YMAPaymentResponse moneySourcesFromModel:moneySourcesModel];

    _paymentInfo = [YMAPaymentInfo paymentInfoWithMoneySources:moneySources requestId:requestId contractAmount:contractAmount balance:balance recipientAccountStatus:accountStatus recipientAccountType:accountType protectionCode:protectionCode extActionUri:extActionUri];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, %@>", [self class], (__bridge void *) self,
                                      @{
                                              @"paymentInfo" : self.paymentInfo.description
                                      }];
}

@end