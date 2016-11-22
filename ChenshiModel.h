//
//  ChenshiModel.h
//  tianqiyubao
//
//  Created by hekai on 16/5/13.
//  Copyright © 2016年 hekai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBModel.h"

@interface ChenshiModel : NSObject

/// DressTr
@property (nonatomic ,strong) NSString *cityname;
///城市id
@property (nonatomic ,strong) NSString *cityid;
///天气信息
@property (nonatomic ,strong) NSArray *weekdic;
///pm
@property (nonatomic ,strong) NSDictionary *pmdic;
@end