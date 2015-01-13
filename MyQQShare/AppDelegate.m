//
//  AppDelegate.m
//  MyQQShare
//
//  Created by 蔡成汉 on 15/1/9.
//  Copyright (c) 2015年 JW. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

@interface AppDelegate ()<QQApiInterfaceDelegate>
{
    ViewController *viewController;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    viewController = [[ViewController alloc]init];
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:viewController];
    self.window.rootViewController = navigationController;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
//#if __QQAPI_ENABLE__
//    [QQApiInterface handleOpenURL:url delegate:(id)[QQAPIDemoEntry class]];
//#endif
//    if (YES == [TencentOAuth CanHandleOpenURL:url])
//    {
//        return [TencentOAuth HandleOpenURL:url];
//    }
//    return YES;
    
    
    //对于这个结果的回调 --- 可写在share类中，有share类来返回结果，然后将结果返回到这里来。其回调的委托，可写在share类中，由share类再委托到使用者的地方去。
    
    
    return [QQApiInterface handleOpenURL:url delegate:self] || [TencentOAuth HandleOpenURL:url] ;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
//    return [TencentOAuth HandleOpenURL:url];
    
    
//#if __QQAPI_ENABLE__
//    [QQApiInterface handleOpenURL:url delegate:(id)[QQAPIDemoEntry class]];
//#endif
//    if (YES == [TencentOAuth CanHandleOpenURL:url])
//    {
//        return [TencentOAuth HandleOpenURL:url];
//    }
//    return YES;
    
    return [QQApiInterface handleOpenURL:url delegate:self] || [TencentOAuth HandleOpenURL:url] ;
}

//QQ终端向第三方程序发送请求，要求第三方程序响应。第三方程序响应完后必须调用sendRsp返回。在调用sendRsp返回时，会切回到QQ终端程序界面。
-(void)onReq:(QQBaseReq *)req
{
    NSString *string = [NSString stringWithFormat:@"%d",req.type];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:string delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
}

//如果第三方程序向QQ发送了sendReq的请求，那么onResp会被回调。sendReq请求调用后，会切到QQ终端程序界面。
-(void)onResp:(QQBaseResp *)resp
{
    NSString *string = [NSString stringWithFormat:@"%@",resp.result];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:string delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
}

-(void)isOnlineResponse:(NSDictionary *)response
{
    NSLog(@"%@",response);
}


@end
