//
//  ViewController.m
//  VideoMonitor
//
//  Created by Chen on 16/8/4.
//  Copyright © 2016年 Chen. All rights reserved.
//

#import "ViewController.h"


@interface ViewController (){
    UIBarButtonItem * __weak _doneItem;
}

@property (nonatomic,strong)WKWebView *webView;
@property (nonatomic,strong)UIProgressView *progressView;

@property(strong, nonatomic) UIBarButtonItem *navigationBackBarButtonItem;
@property(strong, nonatomic) UIBarButtonItem *navigationCloseBarButtonItem;

/// Back bar button item of tool bar.
@property(strong, nonatomic) UIBarButtonItem *backBarButtonItem;
/// Forward bar button item of tool bar.
@property(strong, nonatomic) UIBarButtonItem *forwardBarButtonItem;
/// Refresh bar button item of tool bar.
@property(strong, nonatomic) UIBarButtonItem *refreshBarButtonItem;
/// Stop bar button item of tool bar.
@property(strong, nonatomic) UIBarButtonItem *stopBarButtonItem;
/// Action bar button item of tool bar.
@property(strong, nonatomic) UIBarButtonItem *actionBarButtonItem;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://123.56.143.177/"]]];
    self.webView.allowsBackForwardNavigationGestures =YES; //左滑回退
    
    
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.scrollView.delegate = self;
    
    //进度条
    self.progressView.progressTintColor = self.navigationController.navigationBar.tintColor;
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willOritate:) name:UIApplicationDidChangeStatusBarOrientationNotification object:NULL];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar addSubview:self.progressView];
    
    if (self.navigationController && [self.navigationController isBeingPresented]) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                    target:self
                                                                                    action:@selector(doneButtonClicked:)];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            self.navigationItem.leftBarButtonItem = doneButton;
        else
            self.navigationItem.rightBarButtonItem = doneButton;
        _doneItem = doneButton;
    }

   
}


- (void)viewWillDisappear:(BOOL)animated{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIProgressView *)progressView {
    if (_progressView) return _progressView;
    CGFloat progressBarHeight = 2.0f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[UIProgressView alloc] initWithFrame:barFrame];
    _progressView.trackTintColor = [UIColor clearColor];
//    _progressView.ax_hiddenWhenProgressApproachFullSize = YES;
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    return _progressView;
}

- (void)toBack{
    if ([self.webView canGoBack]){
        [self.webView goBack];
    }
}
- (void)toForward{
    if ([self.webView canGoForward]){
        [self.webView goForward];
    }
}

- (void)doneButtonClicked:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.webView reload];
}

- (void)navigationIemHandleClose:(UIBarButtonItem *)sender {
//    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.webView reload];
}

- (void)willOritate:(NSNotification*)noti{
    self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]){
        if (object == self.webView){
            [self.progressView setAlpha:1.0f];
            [self.progressView setProgress:self.webView.estimatedProgress];
            if (self.webView.estimatedProgress >= 1.0f){
                [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [self.progressView setAlpha:0.0f];
                }completion:^(BOOL finished){
                    [self.progressView setProgress:0.0f];
                }];
            }
        }
        else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
        
    }
    else if([keyPath isEqualToString:@"title"]){
        if (object == self.webView){
            self.title = self.webView.title;
        }
        else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
//    else{
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//    }
}


- (void)updateNavigationItems {
    [self.navigationItem setLeftBarButtonItems:nil animated:NO];
    if (self.webView.canGoBack) {// Web view can go back means a lot requests exist.
        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = -6.5;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        if (self.navigationController.viewControllers.count == 1) {
            [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem, self.navigationBackBarButtonItem, ] animated:NO];//self.navigationCloseBarButtonItem
        } else {
            [self.navigationItem setLeftBarButtonItems:@[self.navigationCloseBarButtonItem] animated:NO];
        }
    } else {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        [self.navigationItem setLeftBarButtonItems:nil animated:NO];
    }
}



- (UIBarButtonItem *)navigationBackBarButtonItem {
    if (_navigationBackBarButtonItem) return _navigationBackBarButtonItem;
    UIImage* backItemImage = [[[UINavigationBar appearance] backIndicatorImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]?:[[UIImage imageNamed:@"backItemImage"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIGraphicsBeginImageContextWithOptions(backItemImage.size, NO, backItemImage.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, backItemImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, backItemImage.size.width, backItemImage.size.height);
    CGContextClipToMask(context, rect, backItemImage.CGImage);
    [[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage* backItemHlImage = newImage?:[[UIImage imageNamed:@"backItemImage-hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton* backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    NSDictionary *attr = [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal];
    if (YES) {
        [backButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"返回" attributes:attr] forState:UIControlStateNormal];
        UIOffset offset = [[UIBarButtonItem appearance] backButtonTitlePositionAdjustmentForBarMetrics:UIBarMetricsDefault];
        backButton.titleEdgeInsets = UIEdgeInsetsMake(offset.vertical, offset.horizontal, 0, 0);
        backButton.imageEdgeInsets = UIEdgeInsetsMake(offset.vertical, offset.horizontal, 0, 0);
    } else {
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [backButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [backButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    }
    [backButton setImage:backItemImage forState:UIControlStateNormal];
    [backButton setImage:backItemHlImage forState:UIControlStateHighlighted];
    [backButton sizeToFit];
    
    [backButton addTarget:self action:@selector(toBack) forControlEvents:UIControlEventTouchUpInside];
    _navigationBackBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    return _navigationBackBarButtonItem;
}

- (UIBarButtonItem *)navigationCloseBarButtonItem {
    if (_navigationCloseBarButtonItem) return _navigationCloseBarButtonItem;
    if (self.navigationItem.rightBarButtonItem == _doneItem && self.navigationItem.rightBarButtonItem != nil) {
        _navigationCloseBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:0 target:self action:@selector(doneButtonClicked:)];
    } else {
        _navigationCloseBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:0 target:self action:@selector(navigationIemHandleClose:)];
    }
    return _navigationCloseBarButtonItem;
}



#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self updateNavigationItems];
}


#pragma mark - WKUIDelegate
//系统阻止了不安全的连接
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    
    if (!navigationAction.targetFrame.isMainFrame) {
        
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

//- (UIScrollView*)scrollView:(UIScrollView*)scrollView view  
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return nil;
}

@end
