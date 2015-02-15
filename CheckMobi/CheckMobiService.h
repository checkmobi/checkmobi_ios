//
//  CheckMobiService.h
//  CheckMobi
//
//  Created by CheckMobi on 7/31/14.
//  Copyright (c) 2014 CheckMobi.com. All rights reserved.
//

#import <Foundation/Foundation.h>

//validation type

enum ValidationType
{
    ValidationTypeCLI,
    ValidationTypeSMS,
    ValidationTypeIVR,
    ValidationTypeReverseCLI
};

enum ErrorCode
{
    ErrorCodeInvalidApiKey = 1,
    ErrorCodeInvalidPhoneNumber = 2,
    ErrorCodeInvalidRequestId = 3,
    ErrorCodeInvalidValidationType = 4,
    ErrorCodeInsufficientFounds = 5,
    ErrorCodeInsufficientCliValidations = 6,
    ErrorCodeInvalidRequestPayload = 7,
    ErrorCodeValidationMehodNotAvailableInRegion = 8,
    ErrorCodeInvalidNotificationURL = 9
};

//returned http codes

extern const NSInteger kStatusSuccessWithContent;
extern const NSInteger kStatusSuccessNoContent;
extern const NSInteger kStatusBadRequest;
extern const NSInteger kStatusUnauthorised;
extern const NSInteger kStatusNotFound;
extern const NSInteger kStatusInternalServerError;

extern NSString* const kValidationStringSMS;
extern NSString* const kValidationStringCLI;
extern NSString* const kValidationStringIVR;

//validation service

typedef void (^CheckMobiServiceResponse)(NSInteger status, NSDictionary* result, NSError* error);

@interface CheckMobiService : NSObject

@property (nonatomic, strong) NSString* baseUrl;
@property (nonatomic, strong) NSString* secretKey;
@property (nonatomic, strong) NSString* ivrLanguage;
@property (nonatomic, strong) NSString* smsLanguage;
@property (nonatomic, strong) NSString* notificationURL;

+ (id) sharedInstance;

- (void) RequestValidation:(enum ValidationType) type forNumber:(NSString*) e164_number withResponse:(CheckMobiServiceResponse) response;
- (void) CheckValidationStatus:(NSString*) requestId withResponse:(CheckMobiServiceResponse) response;
- (void) VerifyPin:(NSString*) requestId withPin:(NSString*) pin withResponse:(CheckMobiServiceResponse) response;
- (void) CheckNumberInfo:(NSString*) e164_number withResponse:(CheckMobiServiceResponse) response;

@end
