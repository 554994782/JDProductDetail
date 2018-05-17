//
//  JDProductDeViewController.m
//  JDProductDetail
//
//  Created by jiangyunfeng on 2018/5/17.
//  Copyright © 2018年 姜云锋. All rights reserved.
//

#import "JDProductDeViewController.h"
#import "MJRefresh.h"

#define WS(weakSelf)  __weak __block __typeof(&*self)weakSelf = self;

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define TABBAR_HEIGHT 49
#define STATUSBAR_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define NAVBAR_HEIGHT (STATUSBAR_HEIGHT+44)

#define kEndHeight 80

@interface JDProductDeViewController ()<UIScrollViewDelegate, UITableViewDelegate,UITableViewDataSource>
@property (assign, nonatomic) CGFloat minY;
@property (assign, nonatomic) CGFloat maxY;
@property (assign, nonatomic) BOOL isShowBottom;
@property(nonatomic,strong) UIScrollView     *mainScrollView;//最底层横向scrollview

@property(nonatomic,strong) UIView          *transformView;//用来做第一面偏移的view，是 detailTableView、webView的父视图
@property(nonatomic,strong) UITableView     *detailTableView;//第一面tableview
@property(nonatomic,strong) UIWebView       *webView;//第一面webview


@property(nonatomic,strong) UIWebView       *scrollWebView;//第二面webview

@property(nonatomic,strong) UILabel         *bottomView;//底部菜单

@property(nonatomic,strong)UIPageControl *pageControl;
@end

@implementation JDProductDeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //最底层横向scrollview
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, kScreenWidth, kScreenHeight-NAVBAR_HEIGHT-TABBAR_HEIGHT)];
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.backgroundColor = [UIColor whiteColor];
    _mainScrollView.delegate = self;
    _mainScrollView.contentSize = CGSizeMake(kScreenWidth*3, kScreenHeight-NAVBAR_HEIGHT-TABBAR_HEIGHT);
    [self.view addSubview:_mainScrollView];
    
    //用来做偏移的view
    _transformView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, (kScreenHeight-NAVBAR_HEIGHT-TABBAR_HEIGHT) * 2)];
    _transformView.backgroundColor = [UIColor grayColor];
    [_mainScrollView addSubview:_transformView];
    
    //第一面tableview
    _detailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-NAVBAR_HEIGHT-TABBAR_HEIGHT)];
    _detailTableView.delegate = self;
    _detailTableView.dataSource = self;
    _detailTableView.backgroundColor = [UIColor magentaColor];
    [_transformView addSubview:self.detailTableView];
    WS(weakSelf)
    _detailTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf transformToWebview];
    }];
    
    //第一面webview
    _webView = [[UIWebView alloc] init];
    _webView.backgroundColor = [UIColor magentaColor];
    _webView.frame = CGRectMake(0, kScreenHeight-NAVBAR_HEIGHT-TABBAR_HEIGHT, kScreenWidth, kScreenHeight-NAVBAR_HEIGHT-TABBAR_HEIGHT);
    _webView.scrollView.delegate = self;
    _webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf transformToTableview];
    }];
    [self.transformView addSubview:_webView];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.didachuxing.com/static/h5/didahome/index.html"]]];
    
    
    //底部菜单
    _bottomView = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight - TABBAR_HEIGHT, kScreenWidth, TABBAR_HEIGHT)];
    _bottomView.text = @"底部菜单栏(购物车、购买)";
    _bottomView.textAlignment = NSTextAlignmentCenter;
    _bottomView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_bottomView];
    
    //第二面webview
    _scrollWebView = [[UIWebView alloc] init];
    _scrollWebView.backgroundColor = [UIColor orangeColor];
    _scrollWebView.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, kScreenHeight-NAVBAR_HEIGHT-TABBAR_HEIGHT);
    _scrollWebView.scrollView.delegate = self;
    [_mainScrollView addSubview:_scrollWebView];
    
    [_scrollWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.didachuxing.com/static/h5/didahome/index.html"]]];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 200, 120, 30)];
    _pageControl.pageIndicatorTintColor = UIColor.greenColor;
    _pageControl.numberOfPages = 3;
    _pageControl.currentPageIndicatorTintColor = UIColor.orangeColor;
    [view addSubview:_pageControl];
    self.navigationItem.titleView = _pageControl;
}

#pragma _transformView偏移
- (void)transformToWebview {
    [self.detailTableView.mj_footer endRefreshing];
    //_transformView向下偏移
    [UIView animateWithDuration:0.5 animations:^{
        self.transformView.transform = CGAffineTransformTranslate(self.transformView.transform, 0,-(kScreenHeight-NAVBAR_HEIGHT-TABBAR_HEIGHT));
    } completion:^(BOOL finished) {
        self.mainScrollView.scrollEnabled = NO;
    }];
}

- (void)transformToTableview {
    [self.webView.scrollView.mj_header endRefreshing];
    
    //_transformView向上偏移
    [UIView animateWithDuration:0.5 animations:^{
        self.transformView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.mainScrollView.scrollEnabled = YES;
    }];
}

#pragma tableview代理
- (NSInteger)numberOfSections {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 15;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    cell.backgroundColor = [UIColor greenColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = scrollView.contentOffset.x / kScreenWidth + 0.5;
    _pageControl.currentPage = page;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
