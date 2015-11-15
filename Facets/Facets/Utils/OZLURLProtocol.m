//
//  OZLURLProtocol.m
//  Facets
//
//  Created by Justin Hill on 11/14/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLURLProtocol.h"
#import "OZLNetwork.h"
#import <AFNetworking/AFNetworking.h>

NSString * const OZLURLProtocolBypassKey = @"OZLURLProtocolBypassKey";

@interface OZLURLProtocol ()

@property (strong) NSURLConnection *connection;

@end

@implementation OZLURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([NSURLProtocol propertyForKey:OZLURLProtocolBypassKey inRequest:request]) {
        return NO;
    }
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:OZLURLProtocolBypassKey inRequest:newRequest];
    
    NSString *credentials = [OZLNetwork encodedCredentialStringWithUsername:[OZLSingleton sharedInstance].redmineUserName password:[OZLSingleton sharedInstance].redminePassword];
    
    [newRequest setValue:[NSString stringWithFormat:@"Basic %@", credentials] forHTTPHeaderField:@"Authorization"];
    
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
}

- (void)stopLoading {
    [self.connection cancel];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse *hr = (NSHTTPURLResponse *)response;
    
    if ([hr.allHeaderFields[@"Content-Type"] isEqualToString:@"application/mp4"]) {
        NSMutableDictionary *mutableHeaders = [hr.allHeaderFields mutableCopy];
        mutableHeaders[@"Content-Type"] = @"video/x-m4v";
        
        NSHTTPURLResponse *r = [[NSHTTPURLResponse alloc] initWithURL:hr.URL statusCode:hr.statusCode HTTPVersion:nil headerFields:mutableHeaders];
        NSLog(@"response: %@", r);
        
        [self.client URLProtocol:self didReceiveResponse:r cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    } else {
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

@end
