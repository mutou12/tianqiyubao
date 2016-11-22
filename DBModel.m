//
//  DBModel.m
//  哔哔电台
//
//  Created by 开维 on 14-11-3.
//  Copyright (c) 2014年 开维致远. All rights reserved.
//

#import "DBModel.h"

@implementation DBModel
//重载选择 使用的LKDBHelper
+(LKDBHelper *)getUsingLKDBHelper
{
    static LKDBHelper* db;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString* dbpath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/teamin.db"];
        db = [[LKDBHelper alloc]initWithDBPath:dbpath];
        //or
        //        db = [[LKDBHelper alloc]init];
    });
    return db;
}

@end
