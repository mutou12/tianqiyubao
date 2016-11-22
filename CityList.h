//
//  CityList.h
//  tianqiyubao
//
//  Created by hekai on 16/5/14.
//  Copyright © 2016年 hekai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBModel.h"

@interface CityList : NSObject

/// 城市信息
@property (nonatomic ,strong) NSMutableArray *cityinfo;
/// id
@property (nonatomic ,strong) NSString *biaozhifu;
@end