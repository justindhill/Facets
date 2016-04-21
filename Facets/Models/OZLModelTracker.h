//
//  OZLModelTracker.h
//  Facets
//
//  Created by lizhijie on 7/15/13.

@import Foundation;
@import Realm;

@interface OZLModelTracker : RLMObject

@property (nonatomic) NSInteger trackerId;
@property (nonatomic, strong) NSString *name;

- (id)initWithAttributeDictionary:(NSDictionary *)attributes;

@end
