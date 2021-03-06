//
//  OZLIssueHeaderView.h
//  Facets
//
//  Created by Justin Hill on 11/5/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

@import UIKit;

@class OZLModelIssue;

@interface OZLIssueHeaderView : UIView

@property (strong) UILabel *titleLabel;
@property (strong) UILabel *assigneeDisplayNameLabel;
@property (strong) UIImageView *assigneeProfileImageView;
@property (assign) CGFloat contentPadding;
@property (strong) UIButton *assignButton;

- (void)applyIssueModel:(OZLModelIssue *)issue;

@end
