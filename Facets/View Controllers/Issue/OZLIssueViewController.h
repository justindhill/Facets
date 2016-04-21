//
//  OZLIssueViewController.h
//  Facets
//
//  Created by Justin Hill on 11/5/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

@import UIKit;
#import "OZLModelIssue.h"
#import "OZLIssueViewModel.h"

@protocol OZLQuickAssignDelegate;
@interface OZLIssueViewController : UITableViewController

@property (nonatomic, strong) OZLIssueViewModel *viewModel;
@property (weak) id<OZLQuickAssignDelegate> previewQuickAssignDelegate;

@end
