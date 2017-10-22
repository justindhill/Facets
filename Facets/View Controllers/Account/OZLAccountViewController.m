//
//  OZLAccountViewController.m
//  Facets
//
//  Created by Lee Zhijie on 7/14/13.

#import "OZLAccountViewController.h"
#import "OZLSingleton.h"
#import "OZLConstants.h"
#import "OZLNetwork.h"
#import "OZLModelProject.h"

#import <Helpshift/HelpshiftSupport.h>

@import JGProgressHUD;
@import OnePasswordExtension;

@interface OZLAccountViewController ()

@property (weak, nonatomic) IBOutlet UIButton *onePasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *supportButton;
@property JGProgressHUD *hud;

@end

@implementation OZLAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Settings";

    self.redmineHomeURL.text = [[OZLSingleton sharedInstance] redmineHomeURL];
    self.redmineUserKey.text = [[OZLSingleton sharedInstance] redmineUserKey];
    self.username.text = [[OZLSingleton sharedInstance] redmineUserName];
    self.password.text = [[OZLSingleton sharedInstance] redminePassword];

    NSBundle *opBundle = [NSBundle bundleForClass:[OnePasswordExtension class]];
    NSBundle *opResBundle = [NSBundle bundleWithPath:[opBundle.bundlePath stringByAppendingPathComponent:@"OnePasswordExtensionResources.bundle"]];
    UIImage *onePasswordImage = [UIImage imageNamed:@"onepassword-button" inBundle:opResBundle compatibleWithTraitCollection:nil];
    onePasswordImage = [onePasswordImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    [self.onePasswordButton setImage:onePasswordImage forState:UIControlStateNormal];
    self.onePasswordButton.hidden = ![[OnePasswordExtension sharedExtension] isAppExtensionAvailable];
    [self.onePasswordButton addTarget:self action:@selector(onePasswordButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    [self.supportButton addTarget:self action:@selector(supportButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped)];
    [self.view addGestureRecognizer:tapper];
}

- (void)saveButtonAction:(id)sender {

    __weak OZLAccountViewController *weakSelf = self;
    __block JGProgressHUD *hud = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleDark];
    hud.animation = [[JGProgressHUDFadeZoomAnimation alloc] init];
    [hud showInView:self.view];
    self.hud = hud;

    NSURL *baseURL = [NSURL URLWithString:_redmineHomeURL.text];
    [[OZLNetwork sharedInstance] authenticateCredentialsWithURL:baseURL username:_username.text password:_password.text completion:^(NSError *error) {
        if (error) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Couldn't validate credentials" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            
            [weakSelf presentViewController:alert animated:YES completion:nil];
            [hud dismissAnimated:YES];
            weakSelf.hud = nil;
        } else {
            [[OZLSingleton sharedInstance] setRedmineUserKey:_redmineUserKey.text];
            [[OZLSingleton sharedInstance] setRedmineHomeURL:_redmineHomeURL.text];
            [[OZLSingleton sharedInstance] setRedmineUserName:_username.text];
            [[OZLSingleton sharedInstance] setRedminePassword:_password.text];
            
            [weakSelf startSync];
        }
    }];
}

- (void)onePasswordButtonAction:(UIButton *)sender {
    __weak OZLAccountViewController *weakSelf = self;

    [[OnePasswordExtension sharedExtension] findLoginForURLString:self.redmineHomeURL.text forViewController:self sender:sender completion:^(NSDictionary *loginDictionary, NSError *error) {
        if (loginDictionary.count == 0) {
            if (error.code != AppExtensionErrorCodeCancelledByUser) {
                NSLog(@"Error invoking 1Password App Extension for find login: %@", error);
            }
            return;
        }

        weakSelf.username.text = loginDictionary[AppExtensionUsernameKey];
        weakSelf.password.text = loginDictionary[AppExtensionPasswordKey];
        [weakSelf saveButtonAction:nil];
    }];
}

- (void)supportButtonAction:(UIButton *)sender {
    [HelpshiftSupport showConversation:self withConfig:nil];
}

- (void)startSync {
    __weak OZLAccountViewController *weakSelf = self;
    
    [[OZLSingleton sharedInstance].serverSync startSyncCompletion:^(NSError *error) {
        [weakSelf.delegate accountViewControllerDidSuccessfullyAuthenticate:weakSelf shouldTransitionToIssues:weakSelf.isFirstLogin];
        weakSelf.isFirstLogin = NO;
        [weakSelf.hud dismissAnimated:YES];
        weakSelf.hud = nil;
    }];
}

- (void)backgroundTapped {
    [self.view endEditing:YES];
}

@end
