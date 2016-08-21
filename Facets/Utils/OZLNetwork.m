//
//  OZLNetwork.m
//  Facets
//
//  Created by Lee Zhijie on 7/14/13.

@import RaptureXML_Frankly;

#import "OZLNetwork.h"
#import "OZLSingleton.h"

#import "NSString+OZLURLEncoding.h"
#import "Facets-Swift.h"

NSString * const OZLNetworkErrorDomain = @"OZLNetworkErrorDomain";

@interface OZLNetwork () <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (strong) NSURLSession *urlSession;
@property NSOperationQueue *taskCallbackQueue;
@property NSObject *requestCountSyncToken;

@end

@implementation OZLNetwork

+ (instancetype)sharedInstance {
    static OZLNetwork  * _sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

+ (NSString *)encodedCredentialStringWithUsername:(NSString *)username password:(NSString *)password {
    NSString *credentials = [NSString stringWithFormat:@"%@:%@", username, password];
    NSData *credentialData = [credentials dataUsingEncoding:NSUTF8StringEncoding];
    
    return [credentialData base64EncodedStringWithOptions:0];
}

- (instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
        
        self.taskCallbackQueue = [[NSOperationQueue alloc] init];
        self.urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:self.taskCallbackQueue];
        self.requestCountSyncToken = [[NSObject alloc] init];
    }
    
    return self;
}

- (void)setActiveRequestCount:(NSInteger)activeRequestCount {
    @synchronized(self.requestCountSyncToken) {
        _activeRequestCount = activeRequestCount;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = (activeRequestCount > 0);
    }
}

@end
