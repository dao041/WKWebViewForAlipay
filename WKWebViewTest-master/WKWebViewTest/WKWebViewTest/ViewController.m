//
//  ViewController.m
//  WKWebViewTest
//

/// 控件高度
#define kSearchBarH  0
#define kBottomViewH 0

// 屏幕大小尺寸
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import <WebKit/WebKit.h>


@interface ViewController () <UISearchBarDelegate, WKNavigationDelegate>
/// 搜索栏
@property (nonatomic, strong) UISearchBar *searchBar;
/// 网页控制导航栏
@property (weak, nonatomic) UIView *bottomView;

@property (nonatomic, strong) WKWebView *wkWebView;

@property (weak, nonatomic) UIButton *backBtn;
@property (weak, nonatomic) UIButton *forwardBtn;
@property (weak, nonatomic) UIButton *reloadBtn;
@property (weak, nonatomic) UIButton *browserBtn;

@property (weak, nonatomic) NSString *baseURLString;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self simpleExampleTest];
    
    [self addSubViews];
    [self refreshBottomButtonState];
    
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.qq.com"]]];
    
}
- (void)simpleExampleTest {
    // 1.创建webview，并设置大小，"20"为状态栏高度
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    // 2.创建请求
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.qq.com"]];
    // 3.加载网页
    [webView loadRequest:request];
    
    // 最后将webView添加到界面
    [self.view addSubview:webView];
}
/// 模拟器加载mac本地文件
- (void)loadLocalFile {
    // 1.创建webview，并设置大小，"20"为状态栏高度
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    // 2.创建url  userName：电脑用户名
    NSURL *url = [NSURL fileURLWithPath:@"/Users/userName/Desktop/bigIcon.png"];
    // 3.加载文件
    [webView loadFileURL:url allowingReadAccessToURL:url];
    // 最后将webView添加到界面
    [self.view addSubview:webView];
}
- (void)addSubViews {
    //[self addBottomViewButtons];
    
    //[self.view addSubview:self.searchBar];
    
    [self.view addSubview:self.wkWebView];
}

- (void)addBottomViewButtons {
   
}
- (void)setupBottomViewLayout
{
   
}
/// 刷新按钮是否允许点击
- (void)refreshBottomButtonState {
    if ([self.wkWebView canGoBack]) {
        self.backBtn.enabled = YES;
    } else {
        self.backBtn.enabled = NO;
    }
    
    if ([self.wkWebView canGoForward]) {
        self.forwardBtn.enabled = YES;
    } else {
        self.forwardBtn.enabled = NO;
    }
}
/// 按钮点击事件
- (void)onBottomButtonsClicled:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
        {
            [self.wkWebView goBack];
            [self refreshBottomButtonState];
        }
            break;
        case 2:
        {
            [self.wkWebView goForward];
            [self refreshBottomButtonState];
        }
            break;
        case 3:
            [self.wkWebView reload];
            break;
        case 4:
            [[UIApplication sharedApplication] openURL:self.wkWebView.URL];
            break;
        default:
            break;
    }
}

#pragma mark - WKWebView WKNavigationDelegate 相关
/// 是否允许加载网页 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
   
    NSURL *URL = navigationAction.request.URL;
    NSString *scheme = [URL scheme];
    if ([scheme isEqualToString:@"tel"]) {
        NSString *resourceSpecifier = [URL resourceSpecifier];
        NSString *callPhone = [NSString stringWithFormat:@"telprompt://%@", resourceSpecifier];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone]];
    }
     NSString *urls = [navigationAction.request.URL.absoluteString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if ([scheme isEqualToString:@"alipay"]) {//拦截url，截取参数，
        NSString* dataStr=[urls substringFromIndex:23];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[ NSString stringWithFormat:@"alipay://alipayclient/?%@",[self URLEncodedString:dataStr]]]];// 对参数进行urlencode，拼接
    }
    decisionHandler(WKNavigationActionPolicyAllow);
     
}
-(NSString *)URLEncodedString:(NSString *)str
{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)str,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}
- (NSArray *)getImageUrlByJS:(WKWebView *)wkWebView {
    
    // js方法遍历图片添加点击事件返回图片个数
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgUrlStr='';\
    for(var i=0;i<objs.length;i++){\
    if(i==0){\
    if(objs[i].alt==''){\
    imgUrlStr=objs[i].src;\
    }\
    }else{\
    if(objs[i].alt==''){\
    imgUrlStr+='#'+objs[i].src;\
    }\
    }\
    objs[i].onclick=function(){\
    if(this.alt==''){\
    document.location=\"myweb:imageClick:\"+this.src;\
    }\
    };\
    };\
    return imgUrlStr;\
    };";
    
    // 这里只是将代码添加到web？？？
    [wkWebView evaluateJavaScript:jsGetImages completionHandler:^(id Result, NSError * error) {
//        NSLog(@"js___Result==%@",Result);
//        NSLog(@"js___Error -> %@", error);
    }];
    
    // 这里执行？？？
    NSString *js2=@"getImages()";
    
    __block NSArray *array=[NSArray array];
    [wkWebView evaluateJavaScript:js2 completionHandler:^(id Result, NSError * error) {
        NSLog(@"js2__Result==%@",Result);
        NSString *resurlt=[NSString stringWithFormat:@"%@",Result];
        
        if([resurlt hasPrefix:@"#"])
        {
            resurlt=[resurlt substringFromIndex:1];
        }
        array=[resurlt componentsSeparatedByString:@"#"];
        NSLog(@"array====%@",array);
    }];
    
    return array;
}
//- (void)setMethod:(NSArray *)imgUrlArray
//{
//    objc_setAssociatedObject(self, &imgUrlArrayKey, imgUrlArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
/// 网页加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    //[self getImageUrlByJS:self.wkWebView];
}


#pragma mark - searchBar代理方法
/// 点击搜索按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // 创建url
    NSURL *url = nil;
    NSString *urlStr = searchBar.text;
    
    // 如果file://则为打开bundle本地文件，http则为网站，否则只是一般搜索关键字
    if([urlStr hasPrefix:@"file://"]){
        NSRange range = [urlStr rangeOfString:@"file://"];
        NSString *fileName = [urlStr substringFromIndex:range.length];
        url = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
        // 如果是模拟器加载电脑上的文件，则用下面的代码
//        url = [NSURL fileURLWithPath:fileName];
    }else if(urlStr.length>0){
        if ([urlStr hasPrefix:@"http://"]) {
            url=[NSURL URLWithString:urlStr];
        } else {
            urlStr=[NSString stringWithFormat:@"http://www.baidu.com/s?wd=%@",urlStr];
        }
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        url=[NSURL URLWithString:urlStr];
        
    }
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    
    // 加载请求页面
    [self.wkWebView loadRequest:request];
}
#pragma mark - 懒加载
- (UIView *)bottomView {
    if (_bottomView == nil) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kBottomViewH, kScreenWidth, kBottomViewH)];
        view.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
        [self.view addSubview:view];
        _bottomView = view;
    }
    return _bottomView;
}

- (WKWebView *)wkWebView {
    if (_wkWebView == nil) {
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20 + kSearchBarH, kScreenWidth, kScreenHeight - 20 - kSearchBarH - kBottomViewH)];
        webView.navigationDelegate = self;
//                webView.scrollView.scrollEnabled = NO;
        
        //        webView.backgroundColor = [UIColor colorWithPatternImage:self.image];
        // 允许左右划手势导航，默认允许
        webView.allowsBackForwardNavigationGestures = YES;
        _wkWebView = webView;
    }

    return _wkWebView;
}


@end
