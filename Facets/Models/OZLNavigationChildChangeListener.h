//
//  OZLNavigationChildChangeListener.h
//  Facets
//
//  Created by Justin Hill on 12/26/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OZLModelIssue.h"

@protocol OZLNavigationChildChangeListener <NSObject>

- (void)navigationChild:(UIViewController *)navigationChild didModifyIssue:(OZLModelIssue *)issue;

@end
