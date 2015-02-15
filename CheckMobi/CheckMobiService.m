//
//  CheckMobiService.m
//  CheckMobi
//
//  Created by CheckMobi on 7/31/14.
//  Copyright (c) 2014 CheckMobi.com. All rights reserved.
//

#import "CheckMobiService.h"
#import "AsyncHTTPConnection.h"

#pragma mark Public Urls

NSString* const kDefaultBaseUrl = @"https://api.checkmobi.com/v1/";
NSString* const kRequestValidationUrl = @"validation/request";
NSString* const kValidationStatusUrl = @"validation/status";
NSString* const kValidationPinVerifyUrl = @"validation/verify";
NSString* const kValidationCheckNumberUrl = @"checknumber";

#pragma mark HTTP methods

NSString* const kMethodGet = @"GET";
NSString* const kMethodPost = @"POST";

#pragma mark HTTP status codes

const NSInteger kStatusSuccessWithContent = 200;
const NSInteger kStatusSuccessNoContent = 204;
const NSInteger kStatusBadRequest = 400;
const NSInteger kStatusUnauthorised = 401;
const NSInteger kStatusNotFound = 404;
const NSInteger kStatusInternalServerError = 500;

#pragma mark Auth Header

NSString* const kAuthrizationHeader = @"Authorization";

#pragma mark Validation type strings

NSString* const kValidationStringSMS  = @"sms";
NSString* const kValidationStringCLI  = @"cli";
NSString* const kValidationStringIVR  = @"ivr";
NSString* const kValidationStringRCLI = @"reverse_cli";

#pragma mark Private definitions

typedef void (^httpResponseBlock)(NSInteger, NSDictionary*, NSError*);

@interface CheckMobiService ()

- (id) init;
- (NSString*) GetUrl:(const NSString*) resource;
+ (NSString*) ValidationTypeToString:(enum ValidationType) type;
+ (NSString*) EncodeString:(NSString*) string;
- (NSDictionary*) ParseResponseBody:(NSData*) data;
- (void) PerformRequest:(NSString*) url method:(NSString*) method params:(NSDictionary*) params response:(httpResponseBlock) response;

@end

@implementation CheckMobiService

#pragma mark Internal Operations

-(id)init
{
    if ( self = [super init] )
    {
        self.baseUrl = kDefaultBaseUrl;
    }
    
    return self;
}

- (NSString*) GetUrl:(NSString* const) resource
{
    if(self.baseUrl != nil)
        return [self.baseUrl stringByAppendingString:resource];

    return [kDefaultBaseUrl stringByAppendingString:resource];
}

+ (NSString*) EncodeString:(NSString*) string
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}

+ (NSString*) ValidationTypeToString:(enum ValidationType) type
{
    switch (type)
    {
        case ValidationTypeCLI:
            return kValidationStringCLI;
            
        case ValidationTypeSMS:
            return kValidationStringSMS;
            
        case ValidationTypeIVR:
            return kValidationStringIVR;
            
        case ValidationTypeReverseCLI:
            return kValidationStringRCLI;
    }
    
    NSLog(@"Invalid validation type:%d", type);
    return @"";
}

-(NSDictionary*) ParseResponseBody:(NSData*) data
{
    if(!data)
        return nil;
    
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

- (void) PerformRequest:(NSString*) urlStr method:(NSString*) method params:(NSDictionary*) params response:(httpResponseBlock) response
{
    NSData *jsonData = nil;
    
    if(params)
        jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [urlRequest setTimeoutInterval:10];
    [urlRequest setHTTPMethod:method];
    [urlRequest setAllHTTPHeaderFields:[NSDictionary dictionaryWithObject:self.secretKey forKey:@"Authorization"]];
    
    if(jsonData)
        [urlRequest setHTTPBody:jsonData];
    
    AsyncHTTPConnection *connection = [[AsyncHTTPConnection alloc] initWithRequest:urlRequest];
    [connection executeRequestOnSuccess:^(NSHTTPURLResponse *http_resp, NSData *body) {
        
        NSDictionary * body_dict = [self ParseResponseBody:body];
        //NSLog(@"Success Response:%ld body: %@", (long)http_resp.statusCode, body_dict);
        response(http_resp.statusCode, body_dict, nil);
        
    } failure:^(NSHTTPURLResponse *http_resp, NSData *body, NSError *error) {
        
        NSDictionary * body_dict = [self ParseResponseBody:body];
        NSLog(@"Failed Response:%ld body: %@ error: %@ ", (long)http_resp.statusCode, body_dict, [error description]);
        response(http_resp.statusCode, body_dict, error);
        
    }];
}

#pragma mark Public methods

+ (id)sharedInstance
{
    static CheckMobiService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ instance = [[self alloc] init]; });
    return instance;
}

- (void) RequestValidation:(enum ValidationType) type forNumber:(NSString*) e164_number withResponse:(CheckMobiServiceResponse) response
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[CheckMobiService ValidationTypeToString:type] forKey:@"type"];
    [params setObject:e164_number forKey:@"number"];
    
    if(self.notificationURL != nil)
        [params setObject:self.notificationURL forKey:@"notification_callback"];
    
    if(type == ValidationTypeIVR && self.ivrLanguage != nil)
        [params setObject:self.ivrLanguage forKey:@"language"];
    else if(type == ValidationTypeSMS && self.smsLanguage != nil)
        [params setObject:self.smsLanguage forKey:@"language"];
    
    NSString *url = [self GetUrl:kRequestValidationUrl];
    
    [self PerformRequest:url method:kMethodPost params:params response:^(NSInteger code, NSDictionary* dict, NSError* error) {
        response(code, dict, error);
    }];
}

- (void) CheckValidationStatus:(NSString*) requestId withResponse:(CheckMobiServiceResponse) response
{
    NSString *url = [NSString stringWithFormat:@"%@/%@",[self GetUrl:kValidationStatusUrl], requestId];
    
    [self PerformRequest:url method:kMethodGet params:nil response:^(NSInteger code, NSDictionary* dict, NSError* error) {
         response(code, dict, error);
    }];
}

- (void) VerifyPin:(NSString*) requestId withPin:(NSString*) pin withResponse:(CheckMobiServiceResponse) response;
{
    NSString *url = [self GetUrl:kValidationPinVerifyUrl];
    NSDictionary *params = @{ @"id" : requestId, @"pin": pin };
    
    [self PerformRequest:url method:kMethodPost params:params response:^(NSInteger code, NSDictionary* dict, NSError* error) {
        response(code, dict, error);
    }];
}

- (void) CheckNumberInfo:(NSString*) e164_number withResponse:(CheckMobiServiceResponse) response
{
    NSString *url = [self GetUrl:kValidationCheckNumberUrl];
    NSDictionary *params = @{ @"number": e164_number };
    
    [self PerformRequest:url method:kMethodPost params:params response:^(NSInteger code, NSDictionary* dict, NSError* error) {
        response(code, dict, error);
    }];
}

@end
