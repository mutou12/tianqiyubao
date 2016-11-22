//
//  KeyChainStore.h
//  tianqiyubao
//
//  Created by hekai on 16/6/5.
//  Copyright © 2016年 hekai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyChainStore : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteKeyData:(NSString *)service;

@end
