//
//  DBModel.h
//
//  Created by 开维 on 14-11-3.
//  Copyright (c) 2014年 开维致远. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKDBHelper.h"
@interface DBModel : NSObject
+(LKDBHelper *)getUsingLKDBHelper;
@end
