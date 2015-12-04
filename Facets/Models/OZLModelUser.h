//
//  OZLModelUser.h
//  RedmineMobile
//
//  Created by lizhijie on 7/15/13.

@interface OZLModelUser : RLMObject

@property (nonatomic) NSInteger userId;
@property (nonatomic, strong) NSString *login;
@property (nonatomic, strong) NSString *firstname;
@property (nonatomic, strong) NSString *lastname;
@property (nonatomic, strong) NSString *mail;
@property (nonatomic, strong) NSDate*creationDate;
@property (nonatomic, strong) NSDate *lastLoginDate;

@property (nonatomic, strong) NSString *name;

- (id)initWithAttributeDictionary:(NSDictionary *)attributes;

@end
