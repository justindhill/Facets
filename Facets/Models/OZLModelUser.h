//
//  OZLModelUser.h
//  Facets
//
//  Created by lizhijie on 7/15/13.

@import Realm;

@protocol OZLEnumerationFormFieldValue;

@interface OZLModelUser : RLMObject <OZLEnumerationFormFieldValue>

@property (nonatomic, strong, nullable) NSString *userId;
@property (nonatomic, strong, nullable) NSString *login;
@property (nonatomic, strong, nullable) NSString *name;
@property (nonatomic, strong, nullable) NSString *mail;
@property (nonatomic, strong, nullable) NSString *gravatarURL;

@property (nonatomic, strong, nullable) NSDate *creationDate;
@property (nonatomic, strong, nullable) NSDate *lastLoginDate;
@property (nonatomic, strong, nullable) NSDate *lastFetchedDate;

- (_Nonnull id)initWithAttributeDictionary:(NSDictionary * _Nonnull)attributes;
- (NSURL * _Nullable)sizedGravatarURL:(NSInteger)sideLen;

@end
