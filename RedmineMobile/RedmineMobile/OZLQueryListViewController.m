//
//  OZLQueryListViewController.m
//  RedmineMobile
//
//  Created by Justin Hill on 10/15/15.
//  Copyright © 2015 Lee Zhijie. All rights reserved.
//

#import "OZLQueryListViewController.h"
#import "OZLNetwork.h"

@interface OZLQueryListViewController ()

@property BOOL isFirstAppearance;
@property NSArray *queries;

@end

@implementation OZLQueryListViewController

NSString * const OZLQueryReuseIdentifier = @"query";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFirstAppearance = YES;
    
    // Do any additional setup after loading the view from its nib.
    self.title = @"Queries";
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:OZLQueryReuseIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isFirstAppearance) {
        [self refreshData];
        self.isFirstAppearance = NO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.queries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:OZLQueryReuseIdentifier forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    OZLModelQuery *query = self.queries[indexPath.row];
    cell.textLabel.text = query.name;
    
    return cell;
}

- (void)refreshData {
    if (!self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
    }
    
    __weak OZLQueryListViewController *weakSelf = self;
    
    [OZLNetwork getQueryListWithParams:nil andBlock:^(NSArray *result, NSError *error) {
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Fetch Error" message:[NSString stringWithFormat:@"Couldn't fetch the query list. \r%@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        } else {
            weakSelf.queries = result;
        }
        
        [weakSelf.tableView reloadData];
        [weakSelf.refreshControl endRefreshing];
    }];
}

@end
