//
//  AppDelegate.m
//  tianqiyubao
//
//  Created by hekai on 16/4/16.
//  Copyright © 2016年 hekai. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import <UMMobClick/MobClick.h>
#import "UMCommunity.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UMConfigInstance.appKey = UmAppkey;
    [MobClick startWithConfigure:UMConfigInstance];
    // 注：AppSecret要与AppKey匹配
    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:UmAppkey];
    //设置微信AppId、appSecret，分享url
    [UMCommunity setAppKey:UmAppkey withAppSecret:@"39041f20e0e44f94b4b0fe4c963ba924"]; //需要修改微社区的Appkey
    
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:@"2832933103"
                                              secret:@"a9582a394cf9bc55763b75454821877c"
                                         RedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    [UMSocialQQHandler setQQWithAppId:@"1105355743" appKey:@"4LzFzLZ64aZOV3Fw" url:@"http://www.umeng.com/social"];
    
    [UMSocialWechatHandler setWXAppId:@"wx2ea1017323da2e5c" appSecret:@"60aa1366a9729e7ba6e91032452c9448" url:@"http://www.umeng.com/social"];
    
    MainViewController *main = [[MainViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:main];
    
    
    [UMComPushRequest getCommunityGuestWithResponse:^(id responseObject, NSError *error) {
        
    }];
    
    
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
        //调用其他SDK，例如支付宝SDK等
    }
    return result;
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
    [UMSocialSnsService applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
