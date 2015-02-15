//
//  CheckMobiService.h
//  CheckMobi
//
//  Created by CheckMobi on 7/31/14.
//  Copyright (c) 2014 CheckMobi.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^OnSuccess) (NSHTTPURLResponse *response, NSData *body);
typedef void (^OnFailure) (NSHTTPURLResponse *response, NSData *body, NSError *error);

@interface AsyncHTTPConnection : NSObject

- (id) initWithRequest:(NSURLRequest *)urlRequest;
- (bool) executeRequestOnSuccess:(OnSuccess)onsuccess failure:(OnFailure)onfailure;

@end
