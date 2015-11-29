//
//  OZLModelProject.h
//  RedmineMobile
//
//  Created by Lee Zhijie on 7/15/13.

#import <Foundation/Foundation.h>

@interface OZLModelProject : RLMObject

@property (nonatomic) NSInteger index;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSInteger parentId;
@property (nonatomic) BOOL isPublic;
@property (nonatomic, strong) NSString *homepage;
@property (nonatomic, strong) NSString *createdOn;
@property (nonatomic, strong) NSString *updatedOn;

- (id)initWithDictionary:(NSDictionary *)dic;
- (NSMutableDictionary *)toParametersDic;

@end
