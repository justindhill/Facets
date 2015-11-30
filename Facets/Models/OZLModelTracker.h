//
//  OZLModelTracker.h
//  RedmineMobile
//
//  Created by lizhijie on 7/15/13.

#import <Foundation/Foundation.h>

@interface OZLModelTracker : RLMObject

@property (nonatomic) NSInteger index;
@property (nonatomic, strong) NSString *name;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
