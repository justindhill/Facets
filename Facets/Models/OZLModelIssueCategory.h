//
//  OZLModelIssueCategory.h
//  RedmineMobile
//
//  Created by lizhijie on 7/16/13.

@interface OZLModelIssueCategory : NSObject

@property (nonatomic) NSInteger index;
@property (nonatomic, strong) NSString *name;

- (id)initWithDictionary:(NSDictionary *)dic;
- (NSMutableDictionary *)toParametersDic;

@end
