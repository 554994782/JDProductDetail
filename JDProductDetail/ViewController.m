//
//  ViewController.m
//  JDProductDetail
//
//  Created by jiang on 2017/8/10.
//  Copyright © 2017年 姜云锋. All rights reserved.
//

#import "ViewController.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kEndHeight 80

@interface ViewController ()<UIScrollViewDelegate, UITableViewDelegate,UITableViewDataSource>
@property (assign, nonatomic) CGFloat minY;
@property (assign, nonatomic) CGFloat maxY;
@property (assign, nonatomic) BOOL isShowBottom;
@property(nonatomic,strong) UIScrollView     *mainScrollView;

@property(nonatomic,strong) UIView          *backOneView;
@property(nonatomic,strong) UIView          *backTwoView;
@property(nonatomic,strong) UITableView     *tableView;
@property(nonatomic,strong) UIWebView       *webView;
@property(nonatomic,strong) UIWebView       *scrollWebView;
@property(nonatomic,strong) UILabel         *webSubLabel;
@property(nonatomic,strong) UILabel         *tableSubLabel;

@property(nonatomic,strong) UIView          *topView;
@property(nonatomic,strong) UIView          *bottomView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    _topView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_topView];
    
    self.view.backgroundColor = [UIColor redColor];
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-64-64)];
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.contentSize = CGSizeMake(kScreenWidth*3, kScreenHeight-64-64);
    [self.view addSubview:_mainScrollView];
    
    _backOneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, (kScreenHeight - 64-64) * 2)];
    _backOneView.backgroundColor = [UIColor grayColor];
    [_mainScrollView addSubview:_backOneView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-64-64)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor purpleColor];
    [_backOneView addSubview:self.tableView];
    
    _webView = [[UIWebView alloc] init];
    _webView.backgroundColor = [UIColor orangeColor];
    _webView.frame = CGRectMake(0, kScreenHeight-64-64, kScreenWidth, kScreenHeight-64-64);
    
    _webView.scrollView.delegate = self;
    
    _webSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -kEndHeight, kScreenWidth, kEndHeight)];
    _webSubLabel.font = [UIFont systemFontOfSize:13.0f];
    _webSubLabel.textAlignment = NSTextAlignmentCenter;
    _webSubLabel.text = @"下拉返回中间View";
    [self.webView.scrollView addSubview:_webSubLabel];
    [self.backOneView addSubview:_webView];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.autohome.com.cn/beijing/"]]];
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 64, kScreenWidth, 64)];
    _bottomView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_bottomView];
    
    //    _backTwoView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth, 0, kScreenWidth, kScreenHeight-64-64)];
    //    _backTwoView.backgroundColor = [UIColor grayColor];
    //    [_mainScrollView addSubview:_backTwoView];
    
    _scrollWebView = [[UIWebView alloc] init];
    _scrollWebView.backgroundColor = [UIColor orangeColor];
    _scrollWebView.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, kScreenHeight-64-64);
    _scrollWebView.scrollView.delegate = self;
    [_mainScrollView addSubview:_scrollWebView];
    
    [_scrollWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.autohome.com.cn/shanghai/"]]];
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;
    if (scrollView == self.tableView) {
        
    } else {
        // WebView中的ScrollView
        if (offset <= -kEndHeight) {
            self.webSubLabel.text = @"释放返回中间View";
        } else {
            self.webSubLabel.text = @"下拉返回中间View";
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate)
    {
        CGFloat offset = scrollView.contentOffset.y;
        NSLog(@"----offset=%f",offset);
        if (scrollView == self.tableView) {
            if (offset < 0) {
                _minY = MIN(_minY, offset);
            } else {
                _maxY = MAX(_maxY, offset);
            }
        } else {
            _minY = MIN(_minY, offset);
        }
        // 滚到底部视图
        NSLog(@"----maxY=%f",_maxY);
        NSLog(@"----contentSize=%f",[self getTableViewHeight]);
        if (_maxY >= [self getTableViewHeight] - (kScreenHeight-64-64) + kEndHeight) {
            NSLog(@"----%@",NSStringFromCGRect(self.backOneView.frame));
            _isShowBottom = NO;
            [UIView animateWithDuration:0.4 animations:^{
                self.backOneView.transform = CGAffineTransformTranslate(self.backOneView.transform, 0,-(kScreenHeight-64-64));
            } completion:^(BOOL finished) {
                _maxY = 0.0f;
                _isShowBottom = YES;
                _mainScrollView.scrollEnabled = NO;
            }];
        }
        
        // 滚到中间视图
        if (_minY <= -kEndHeight && _isShowBottom) {
            NSLog(@"----minY=%f",_minY);
            NSLog(@"----%@",NSStringFromCGRect(self.backOneView.frame));
            _isShowBottom = NO;
            [UIView animateWithDuration:0.4 animations:^{
                self.backOneView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                _minY = 0.0f;
                _mainScrollView.scrollEnabled = YES;
            }];
        }
        
    }
}

-(float)getTableViewHeight
{
    [self.tableView layoutIfNeeded];
    return self.tableView.contentSize.height;
}

- (NSInteger)numberOfSections {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    cell.backgroundColor = [UIColor greenColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
