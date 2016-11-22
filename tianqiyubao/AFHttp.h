//
//  AFHttp.h
//  tianqiyubao
//
//  Created by hekai on 16/4/16.
//  Copyright © 2016年 hekai. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^httpsblock)(id result ,BOOL success);

@interface AFHttp : NSObject

+(AFHttp *)share;
-(void)get:(NSString *)url parameter:(id)parameter requblock:(httpsblock)block;
@end
