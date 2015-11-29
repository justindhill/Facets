//
//  OZLModelUser.h
//  RedmineMobile
//
//  Created by lizhijie on 7/15/13.

@interface OZLModelUser : NSObject

@property (nonatomic) NSInteger index;
@property (nonatomic, strong) NSString *login;
@property (nonatomic, strong) NSString *firstname;
@property (nonatomic, strong) NSString *lastname;
@property (nonatomic, strong) NSString *mail;
@property (nonatomic, strong) NSString *createdOn;
@property (nonatomic, strong) NSString *lastLoginIn;

@property (nonatomic, strong) NSString *name;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
