//
//  WeaModel.h
//  tianqiyubao
//
//  Created by hekai on 16/4/23.
//  Copyright © 2016年 hekai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBModel.h"

@interface WeaModel : NSObject

/// WeathDic
@property (nonatomic ,strong) NSDictionary *WeaDic;
/// DressTr
@property (nonatomic ,strong) NSString *Strdress;
/// TimeStr
@property (nonatomic ,strong) NSString *TimeStr;
/// bendi
@property (nonatomic ,strong) NSString *bendi;

@end
