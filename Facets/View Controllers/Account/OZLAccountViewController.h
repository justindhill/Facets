//
//  OZLAccountViewController.h
//  RedmineMobile
//
//  Created by Lee Zhijie on 7/14/13.

#import <UIKit/UIKit.h>

@class OZLAccountViewController;

@protocol OZLAccountViewControllerDelegate <NSObject>

- (void)accountViewControllerDidSuccessfullyAuthenticate:(OZLAccountViewController *)account shouldTransitionToIssues:(BOOL)shouldTransition;

@end

@interface OZLAccountViewController : UIViewController

@property (weak) id<OZLAccountViewControllerDelegate> delegate;

@property BOOL isFirstLogin;

@property (strong, nonatomic) IBOutlet UITextField *redmineHomeURL;
@property (strong, nonatomic) IBOutlet UITextField *redmineUserKey;

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

- (IBAction)saveButtonAction:(id)sender;

@end
