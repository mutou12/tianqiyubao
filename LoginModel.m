//
//  LoginModel.m
//  tianqiyubao
//
//  Created by hekai on 16/6/5.
//  Copyright © 2016年 hekai. All rights reserved.
//

#import "LoginModel.h"

@implementation LoginModel
@synthesize name;
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.name = @"";
        self.nameid = @"name";
    }
    return self;
}

+(LKDBHelper *)getUsingLKDBHelper
{
    return [DBModel getUsingLKDBHelper];
}
+(NSString *)getPrimaryKey
{
    return @"nameid";
}
+(NSString *)getTableName
{
    return @"LoginModel";
}
+(BOOL)isContainParent
{
    return YES;
}


@end
