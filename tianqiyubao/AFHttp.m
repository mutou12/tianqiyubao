//
//  AFHttp.m
//  tianqiyubao
//
//  Created by hekai on 16/4/16.
//  Copyright © 2016年 hekai. All rights reserved.
//

#import "AFHttp.h"
#import "AFNetworking/AFNetworking.h"
@implementation AFHttp


+(AFHttp *)share
{
    static AFHttp *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}

-(void)get:(NSString *)url parameter:(id)parameter requblock:(httpsblock)block
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        block(responseObject,YES);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(@"网络断开",NO);
    }];
}

@end
