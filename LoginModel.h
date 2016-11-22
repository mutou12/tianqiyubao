//
//  LoginModel.h
//  tianqiyubao
//
//  Created by hekai on 16/6/5.
//  Copyright © 2016年 hekai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBModel.h"

@interface LoginModel : NSObject

/// 姓名信息
@property (nonatomic ,strong) NSString *name;
/// 姓名id
@property (nonatomic ,strong) NSString *nameid;

@end
