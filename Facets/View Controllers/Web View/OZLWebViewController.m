//
//  OZLWebViewController.m
//  Facets
//
//  Created by Justin Hill on 11/15/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

#import "OZLWebViewController.h"
#import "OZLNetwork.h"
#import <WebKit/WebKit.h>

@interface OZLWebViewController ()

@property (strong) WKWebView *webView;
@property BOOL isFirstAppearance;
@property NSString *documentString;

@end

@implementation OZLWebViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        self.isFirstAppearance = YES;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.isFirstAppearance) {
        [self.view addSubview:self.webView];
        
        if (self.sourceURL) {
            [self fetchDocument];
        }
    }
}

- (void)setSourceURL:(NSURL *)sourceURL {
    BOOL needsLoad = (![_sourceURL isEqual:sourceURL]);
    _sourceURL = sourceURL;
    
    if (!self.isFirstAppearance && needsLoad) {
        [self fetchDocument];
    }
}

- (void)fetchDocument {
    
    NSURLSession *session = [[OZLNetwork sharedInstance] urlSession];
    
    __weak OZLWebViewController *weakSelf = self;
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:self.sourceURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (!error && httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
            weakSelf.documentString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            [weakSelf.webView loadHTMLString:weakSelf.documentString baseURL:nil];
            
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Sorry, we had issues loading this text." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }]];
            
            [weakSelf presentViewController:alert animated:YES completion:nil];
        }
    }];
    
    [task resume];
}

@end
