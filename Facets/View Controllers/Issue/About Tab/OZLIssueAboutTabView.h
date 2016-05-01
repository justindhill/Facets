//
//  OZLIssueAboutTabView.h
//  Facets
//
//  Created by Justin Hill on 11/7/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

@import DRPSlidingTabView;

#import "OZLModelIssue.h"

@class OZLModelIssue;

@interface OZLIssueAboutTabView : UIView <DRPIntrinsicHeightChangeEmitter>

@property (nonatomic, strong) UIFont *fieldNameFont;
@property (nonatomic, strong) UIFont *fieldValueFont;
@property (nonatomic, assign) CGFloat contentPadding;

- (void)applyIssueModel:(OZLModelIssue *)issueModel;

@end
