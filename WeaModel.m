//
//  WeaModel.m
//  tianqiyubao
//
//  Created by hekai on 16/4/23.
//  Copyright © 2016年 hekai. All rights reserved.
//

#import "WeaModel.h"

@implementation WeaModel
@synthesize WeaDic,Strdress,TimeStr,bendi;
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.WeaDic = [[NSDictionary alloc] init];
        self.Strdress = @"";
        self.TimeStr = @"";
        self.bendi = @"bendi";
    }
    return self;
}

+(LKDBHelper *)getUsingLKDBHelper
{
    return [DBModel getUsingLKDBHelper];
}
+(NSString *)getPrimaryKey
{
    return @"bendi";
}
+(NSString *)getTableName
{
    return @"WeatherModel";
}
+(BOOL)isContainParent
{
    return YES;
}


@end
