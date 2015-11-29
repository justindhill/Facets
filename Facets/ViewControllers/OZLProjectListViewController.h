//
//  OZLProjectListViewController.h
//  RedmineMobile
//
//  Created by Lee Zhijie on 7/14/13.

#import <UIKit/UIKit.h>

@interface OZLProjectListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL needRefresh;
@property (strong, nonatomic) IBOutlet UITableView *projectsTableview;

@end
