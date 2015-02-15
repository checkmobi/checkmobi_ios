//
//  CheckMobiService.h
//  CheckMobi
//
//  Created by CheckMobi on 7/31/14.
//  Copyright (c) 2014 CheckMobi.com. All rights reserved.
//

#import "AsyncHTTPConnection.h"

#define kIgnoreInvalidCertificates 1

@interface AsyncHTTPConnection ()

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSMutableData *data;

@property (nonatomic, copy) OnSuccess onsuccess;
@property (nonatomic, copy) OnFailure onfailure;

@end

@implementation AsyncHTTPConnection

- (id)initWithRequest:(NSURLRequest *)urlRequest
{
    if (self = [super init])
    {
        self.request = urlRequest;
    }
    
    return self;
}

- (bool) executeRequestOnSuccess:(OnSuccess)onsuccess failure:(OnFailure)onfailure
{
    self.onsuccess = onsuccess;
    self.onfailure = onfailure;
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    return connection != nil;
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = (NSHTTPURLResponse*) response;
    self.data = [NSMutableData data];
    [self.data setLength:0];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)bytes
{
    [self.data appendData:bytes];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.onfailure)
        self.onfailure(self.response, self.data, error);
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.onsuccess)
        self.onsuccess(self.response, self.data);
}

-(NSCachedURLResponse *) connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

#if kIgnoreInvalidCertificates

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        if([self.request.URL.host isEqualToString:challenge.protectionSpace.host])
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

#endif

@end
