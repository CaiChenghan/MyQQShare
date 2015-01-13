//
//  ViewController.m
//  MyQQShare
//
//  Created by 蔡成汉 on 15/1/9.
//  Copyright (c) 2015年 JW. All rights reserved.
//

#import "ViewController.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

@interface ViewController ()<TencentSessionDelegate>
{
    TencentOAuth *myTencentOAuth;   //QQ授权类
    NSArray *permissions;           //权限数组
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initiaNav];
    
    [self prepareToShare];
    
    //创建QQ分享按钮
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake((self.view.frame.size.width - 100.0)/2, 100, 100, 30);
    [shareButton setTitle:@"QQ分享" forState:UIControlStateNormal];
    [shareButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [shareButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [shareButton addTarget:self action:@selector(shareButtonIsTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
}

-(void)initiaNav
{
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.text = @"QQ分享";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:20];
    self.navigationItem.titleView = titleLabel;
}

#pragma mark - 为QQ分享做准备
-(void)prepareToShare
{
    //初始化TencentOAuth
    myTencentOAuth = [[TencentOAuth alloc]initWithAppId:@"222222" andDelegate:self];
    
    //获取权限
    permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_USER_INFO,
                   kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                   kOPEN_PERMISSION_ADD_ALBUM,
                   kOPEN_PERMISSION_ADD_IDOL,
                   kOPEN_PERMISSION_ADD_ONE_BLOG,
                   kOPEN_PERMISSION_ADD_PIC_T,
                   kOPEN_PERMISSION_ADD_SHARE,
                   kOPEN_PERMISSION_ADD_TOPIC,
                   kOPEN_PERMISSION_CHECK_PAGE_FANS,
                   kOPEN_PERMISSION_DEL_IDOL,
                   kOPEN_PERMISSION_DEL_T,
                   kOPEN_PERMISSION_GET_FANSLIST,
                   kOPEN_PERMISSION_GET_IDOLLIST,
                   kOPEN_PERMISSION_GET_INFO,
                   kOPEN_PERMISSION_GET_OTHER_INFO,
                   kOPEN_PERMISSION_GET_REPOST_LIST,
                   kOPEN_PERMISSION_LIST_ALBUM,
                   kOPEN_PERMISSION_UPLOAD_PIC,
                   kOPEN_PERMISSION_GET_VIP_INFO,
                   kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                   kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                   kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO, nil];
    
    //需要做进一步的处理 - 从本地获取AccessToken，同时赋值。
    [self getUserInfo];
}

-(void)shareButtonIsTouch:(UIButton *)paramSender
{
    
    //需要进行判断 -- 判断授权时间是否过期 -- 在没有授权之前，tpExpirationDate会是nil
    NSDate *tpExpirationDate = myTencentOAuth.expirationDate;
    if (tpExpirationDate == nil)
    {
        //需要进行授权操作 - 进行SSO授权
        [self doOAuthLogin];
    }
    else
    {
        //进一步判断 -- 授权是否过期
        NSString *tpExpirationTimeString = [NSString stringWithFormat:@"%.0f",[tpExpirationDate timeIntervalSince1970]];
        NSString *timeString = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
        if ([timeString longLongValue] <[tpExpirationTimeString longLongValue])
        {
            //表示授权没有过期 -- 则可直接分享
            [self doMyShare];
        }
        else
        {
            //表示授权过期了 - 进行SSO授权
            [self doOAuthLogin];
        }
    }
}

#pragma mark - 进行授权登陆
-(void)doOAuthLogin
{
    //直接调用SDK提供的方法 - (BOOL)authorize:(NSArray *)permissions; 进行分享操作，对于这个方法，在返回YES时表示授权成功，此时需要保存用户的accessToken、openId、expirationDate
    
    [myTencentOAuth authorize:permissions];
}

#pragma mark - TencentSessionDelegate
/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin
{
    if (myTencentOAuth.accessToken && 0 != [myTencentOAuth.accessToken length])
    {
        //获取登陆用户的OpenID、Token以及过期时间，同时进行存储。
        [self saveUserInfo:myTencentOAuth];
        
        //调用分享操作 --- 有些问题：授权成功回调后，执行分享操作。
        [self doMyShare];
    }
}

/**
 * 登录失败后的回调
 * \param cancelled 代表用户是否主动退出登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    
}

/**
 * 登录时网络有问题的回调
 */
- (void)tencentDidNotNetWork
{
    
}

#pragma mark - 存储授权用户的OpenID、Token以及过期时间
-(void)saveUserInfo:(TencentOAuth *)oauth
{
    //获取文件路径
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"oauthUser.dic"];
    
    //构建存储字典
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    [paramDic setObject:oauth.openId forKey:@"openId"];
    [paramDic setObject:oauth.accessToken forKey:@"accessToken"];
    [paramDic setObject:oauth.expirationDate forKey:@"expirationDate"];
    
    //以写文件的方式存储到Document目录下。
    [paramDic writeToFile:documentsDirectory atomically:YES];
}

-(void)getUserInfo
{
    //获取文件路径
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"oauthUser.dic"];
    
    NSDictionary *paramDic = [NSDictionary dictionaryWithContentsOfFile:documentsDirectory];
    if (paramDic != nil)
    {
        //分别获取
        NSString *accessToken = [NSString stringWithFormat:@"%@",[paramDic objectForKey:@"accessToken"]];
        NSDate *expirationDate = [paramDic objectForKey:@"expirationDate"];
        NSString *openId = [NSString stringWithFormat:@"%@",[paramDic objectForKey:@"openId"]];
        
        //给myTencentOAuth赋值 - 用于后续的判断 - 是否需要授权，同时也是对分享的一个支持
        [myTencentOAuth setAccessToken:accessToken];
        [myTencentOAuth setExpirationDate:expirationDate];
        [myTencentOAuth setOpenId:openId];
    }
}

#pragma mark - 执行分享操作 --  测试发现，如果不回到主线程中执行分享操作，会出现错误，应该是受QQ授权影响。
//http://wiki.connect.qq.com/ios_sandbox1#2.3.E5.88.86.E4.BA.AB.E7.A4.BA.E4.BE.8B.E4.BB.A3.E7.A0.81
-(void)doMyShare
{
    dispatch_async(dispatch_get_main_queue(), ^{
        QQApiTextObject *txtObj = [QQApiTextObject objectWithText:@"123456"];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        //    //发送结果
        NSLog(@"%d",sent);
        NSString *messageString;
        if (sent == 0)
        {
            messageString = @"发送成功";
        }
        else
        {
            messageString = @"发送失败";
        }
        UIAlertView *myAlertView = [[UIAlertView alloc]initWithTitle:@"提示" message:messageString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [myAlertView show];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
