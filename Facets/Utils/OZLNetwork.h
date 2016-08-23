//
//  OZLNetwork.h
//  Facets
//
//  Created by Lee Zhijie on 7/14/13.

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const OZLNetworkErrorDomain;

typedef NS_ENUM(NSInteger, OZLNetworkError) {
    OZLNetworkErrorInvalidCredentials,
    OZLNetworkErrorCouldntParseTokens,
    OZLNetworkErrorUnacceptableStatusCode,
    OZLNetworkErrorInvalidResponse,
    OZLNetworkErrorInvalidRequestBody
};

@interface OZLNetwork : NSObject

@property NSURL *baseURL;
@property (readonly) NSURLSession *urlSession;

/**
 *  @brief If >0, the system network activity indicator becomes active. Be very careful when adjusting this value;
 *         typically, a change should only require a +1 or -1 to it.
 */
@property (nonatomic, assign) NSInteger activeRequestCount;

+ (instancetype)sharedInstance;
+ (NSString *)encodedCredentialStringWithUsername:(NSString *)username password:(NSString *)password;

@end

NS_ASSUME_NONNULL_END