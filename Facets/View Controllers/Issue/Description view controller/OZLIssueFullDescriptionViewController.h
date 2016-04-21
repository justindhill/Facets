//
//  OZLIssueFullDescriptionViewController.h
//  Facets
//
//  Created by Justin Hill on 11/10/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

@import UIKit;
@import TTTAttributedLabel;

@interface OZLIssueFullDescriptionViewController : UIViewController

@property (readonly) UIScrollView *scrollView;
@property CGFloat contentPadding;

/**
 *  @brief The label that should contain the description
 */
@property (strong) TTTAttributedLabel *descriptionLabel;

/**
 *  @brief URL to load the text from
 */
@property (strong) NSURL *sourceURL;

@end
