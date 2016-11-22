//
//  ChenshiModel.m
//  tianqiyubao
//
//  Created by hekai on 16/5/13.
//  Copyright © 2016年 hekai. All rights reserved.
//

#import "ChenshiModel.h"

@implementation ChenshiModel
@synthesize cityname,cityid,weekdic,pmdic;
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cityid = @"";
        self.cityname = @"";
        self.weekdic = [[NSArray alloc] init];
        self.pmdic = [[NSDictionary alloc] init];
    }
    return self;
}

+(LKDBHelper *)getUsingLKDBHelper
{
    return [DBModel getUsingLKDBHelper];
}
+(NSString *)getPrimaryKey
{
    return @"cityid";
}
+(NSString *)getTableName
{
    return @"CityModel";
}
+(BOOL)isContainParent
{
    return YES;
}
@end
