//
//  OZLProjectInfoViewController.h
//  RedmineMobile
//
//  Created by lizhijie on 7/16/13.

#import <UIKit/UIKit.h>
#import "OZLModelProject.h"

typedef enum {
	OZLProjectInfoViewModeCreate,
    OZLProjectInfoViewModeDisplay,
    OZLProjectInfoViewModeEdit
} OZLProjectInfoViewMode;

@interface OZLProjectInfoViewController : UITableViewController

- (IBAction)onCancel:(id)sender;
- (IBAction)onSave:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *identifier;
@property (weak, nonatomic) IBOutlet UITextField *homepageUrl;
@property (weak, nonatomic) IBOutlet UITextView *description;
@property (nonatomic) BOOL isPublic;
@property (nonatomic, strong) OZLModelProject *parentProject;
@property (nonatomic, strong) NSArray *projectList;

@property (nonatomic, strong) OZLModelProject *projectData;
@property (nonatomic) OZLProjectInfoViewMode viewMode;

@end
