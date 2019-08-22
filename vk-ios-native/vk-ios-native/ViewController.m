//
//  ViewController.m
//  vk-ios-native
//
//  Created by Johan Forssell on 2019-08-21.
//  Copyright © 2019 Västerbottens-Kuriren. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) WKWebView *webbvy;
@property (strong, nonatomic) UIButton *backButton;
@end

static void *URLContext = &URLContext;


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];

    [[config userContentController] addUserScript:[[WKUserScript alloc] initWithSource:@"" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO]];
    self.webbvy = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    self.webbvy.allowsBackForwardNavigationGestures = YES;
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton setTitle:@"< Bakåt" forState:UIControlStateNormal];
    self.backButton.backgroundColor = [UIColor greenColor];
    
    [self layoutStuff];
    
    self.webbvy.UIDelegate = self;
    self.webbvy.navigationDelegate = self;
    [self.webbvy addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:URLContext];
    
    [self.webbvy loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.vk.se"]]];
}

- (void)layoutStuff
{
    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    [self.view addSubview:self.webbvy];
    self.webbvy.translatesAutoresizingMaskIntoConstraints = NO;
    [self.webbvy.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor].active = YES;
    [self.webbvy.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor].active = YES;
    [self.webbvy.topAnchor constraintEqualToAnchor:guide.topAnchor].active = YES;
    [self.webbvy.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;

    [self.view addSubview:self.backButton];
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backButton.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor].active = YES;
    [self.backButton.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;
    self.backButton.contentEdgeInsets = UIEdgeInsetsMake(20,20,20,20);
    

}

- (void)back:(id)sender
{
    [self.webbvy goBack];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context == URLContext) {
        NSLog(@">>> New url: %@", change[@"new"]);
        NSLog(@">>> History: [%@]", [[self.webbvy.backForwardList.backList valueForKey:@"URL"] componentsJoinedByString:@", "]);
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)dealloc
{
    [self.webbvy removeObserver:self forKeyPath:@"URL"];
}



#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@">>> Navigation action: %@, %@", [ViewController translateNavigationActionType:navigationAction.navigationType], navigationAction.request.URL);
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@">>> Provisional navigation: %@, %@", navigation, webView.URL);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@">>> Commit navigation: %@, %@", navigation, webView.URL);
}


#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    NSLog(@">>> Öppnar nytt fönster i samma fönster");
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark - other


+ (NSString *)translateNavigationActionType:(WKNavigationType)type
{
    switch (type) {
        case WKNavigationTypeLinkActivated:
            return @"WKNavigationTypeLinkActivated";
            break;
        case WKNavigationTypeFormSubmitted:
            return @"WKNavigationTypeFormSubmitted";
            break;
        case WKNavigationTypeBackForward:
            return @"WKNavigationTypeBackForward";
            break;
        case WKNavigationTypeReload:
            return @"WKNavigationTypeReload";
            break;
        case WKNavigationTypeFormResubmitted:
            return @"WKNavigationTypeFormResubmitted";
            break;
        case WKNavigationTypeOther:
            return @"WKNavigationTypeOther";
            break;
            
        default:
            return @"<?>";
            break;
    }
}


@end
