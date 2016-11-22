//
//  CityList.m
//  tianqiyubao
//
//  Created by hekai on 16/5/14.
//  Copyright © 2016年 hekai. All rights reserved.
//

#import "CityList.h"

@implementation CityList
@synthesize cityinfo,biaozhifu;
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cityinfo = [[NSMutableArray alloc] init];
        self.biaozhifu = @"weiyi";
    }
    return self;
}

+(LKDBHelper *)getUsingLKDBHelper
{
    return [DBModel getUsingLKDBHelper];
}
+(NSString *)getPrimaryKey
{
    return @"biaozhifu";
}
+(NSString *)getTableName
{
    return @"CityListModel";
}
+(BOOL)isContainParent
{
    return YES;
}

@end
