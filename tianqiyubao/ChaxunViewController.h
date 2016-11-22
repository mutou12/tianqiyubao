//
//  ChaxunViewController.h
//  tianqiyubao
//
//  Created by hekai on 16/5/13.
//  Copyright © 2016年 hekai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^cityblock)(NSDictionary *dic);

@interface ChaxunViewController : UIViewController

@property (nonatomic, strong)cityblock block;
@end
