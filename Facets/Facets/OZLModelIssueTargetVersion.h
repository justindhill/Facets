//
//  OZLModelIssueTargetVersion.h
//  Facets
//
//  Created by Justin Hill on 11/7/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OZLModelIssueTargetVersion : NSObject

@property NSInteger targetVersionId;
@property NSString *name;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
