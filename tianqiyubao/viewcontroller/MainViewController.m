//
//  MainViewController.m
//  tianqiyubao
//
//  Created by hekai on 16/4/16.
//  Copyright © 2016年 hekai. All rights reserved.
//

#import "MainViewController.h"
#import "AFHttp.h"
#import "WeaModel.h"
#import <CoreLocation/CoreLocation.h>
#import "ChaxunViewController.h"
#import "CityList.h"
#import "ChenshiModel.h"
#import "LoginModel.h"
#import "UMCommunity.h"
#import "UUID.h"
#import "MBProgressHUD.h"
#import <CommonCrypto/CommonDigest.h>


@interface MainViewController ()<CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,UICollisionBehaviorDelegate,UISearchBarDelegate,UISearchResultsUpdating>
{
    CLLocationManager *_locationManager;   //定位管理者
    
    UILabel *wenduLa,*didianLa,*zhuangtai,*TuijianLa,*shishiLa,*beijinLa,*pmLa;
    
    NSDictionary *dataDic;                     //数据
    
    UILabel *view;
    
    UIView *backview,*secView,*sousuoView;
    
    UITableView *tablewview,*chatableview;
    
    UIButton *bt;
    
    UIColor *color1;
    UIColor *color2;
    
    UIDynamicAnimator *animator;
    
    UIView *qiuview;
    
    NSArray *colorArr;
    NSMutableArray *cityList;
    
    NSInteger cityindex;
    
    NSString *namesting;
}
@end

@implementation MainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setviews];
    cityindex = 0;
    NSArray *weaArr = [WeaModel searchWithWhere:@"" orderBy:@"" offset:0 count:1];
    if ([weaArr count] > 0) {
        WeaModel *wea = [weaArr firstObject];
        dataDic = wea.WeaDic;
        didianLa.text = wea.Strdress;
        TuijianLa.text = wea.TimeStr;
        [self setData];
    }
    
    [self getData];
    
    NSArray *citys = [CityList searchWithWhere:@"" orderBy:@"" offset:0 count:1];
    if ([citys count] == 0) {
        [[AFHttp share] get:[NSString stringWithFormat:@"http://api.k780.com:88/?app=weather.city&&appkey=%d&sign=%@&format=json",Appkey,K780Sign] parameter:nil requblock:^(id result, BOOL success) {
            if (success) {
                if ([[result objectForKey:@"success"] intValue] == 1) {
                    CityList *citylist = [[CityList alloc] init];
                    NSDictionary *dic = [result objectForKey:@"result"];
                    for (NSDictionary *cdic in [dic allValues]) {
                        [citylist.cityinfo addObject:cdic];
                    }
                    [citylist saveToDB];
                }
            }
            else
            {
                
            }
            
        }];
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)shijian
{
    TuijianLa.text = @"于—:—:—";
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"于hh:mm:ss"];
    TuijianLa.text = [formatter stringFromDate:[NSDate date]];
}


- (void)getData
{
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [_locationManager requestAlwaysAuthorization];
    [_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"zh-hans",nil]
                                              forKey:@"AppleLanguages"];
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:locations[0] completionHandler:^(NSArray *array, NSError *error){
        if (array.count > 0){
            CLPlacemark *placemark = [array objectAtIndex:0];
            //将获得的所有信息显示到label上
            NSDictionary *daic = placemark.addressDictionary;
            
            //获取城市
            NSString *city = placemark.locality;
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
            }
            NSLog(@"city = %@", city);
            didianLa.text = [NSString stringWithFormat:@"%@%@",city,daic[@"SubLocality"]];
            NSDictionary *dic = @{@"location":[NSString stringWithFormat:@"%f,%f",placemark.location.coordinate.longitude,placemark.location.coordinate.latitude],@"ak":@"u8xEZgqABybWgmA75buHYG6WaGEU08lb",@"output":@"json",@"coord_type":@"wgs84",@"mcode":@"com.lihe.weather"};
            [[AFHttp share] get:@"http://api.map.baidu.com/telematics/v3/weather" parameter:dic requblock:^(id result, BOOL success) {
                if ([result[@"status"] isEqualToString:@"success"]) {
                    dataDic = result[@"results"][0];
                    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
                    [formatter setDateFormat:@"于hh:mm:ss"];
                    TuijianLa.text = [formatter stringFromDate:[NSDate date]];
                    WeaModel *wea = [[WeaModel alloc] init];
                    wea.WeaDic = dataDic;
                    wea.Strdress = didianLa.text;
                    wea.TimeStr = [formatter stringFromDate:[NSDate date]];
                    [wea saveToDB];

                    [self setData];
                
                }
            }];
            
            
        }
        else if (error == nil && [array count] == 0)
        {
            NSLog(@"No results were returned.");
        }
        else if (error != nil)
        {
            NSLog(@"An error occurred = %@", error);
        }
    }];
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];
}

- (void)selectcolor
{
    int x = arc4random()%7;
    switch (x) {
        case 0:
        {
            color1 = RGB(3, 54, 73, 1);
            color2 = RGB(232, 221, 203, 1);
        }
            break;
        case 1:
        {
            color1 = RGB(254, 67, 101, 1);
            color2 = RGB(249, 205, 173, 1);
        }
            break;
        case 2:
        {
            color1 = RGB(28, 120, 135, 1);
            color2 = RGB(225, 233, 220, 1);
        }
            break;
        case 3:
        {
            color1 = RGB(89, 69, 61, 1);
            color2 = RGB(166, 137, 124, 1);
        }
            break;
        case 4:
        {
            color1 = RGB(25, 202, 173, 1);
            color2 = RGB(190, 237, 199, 1);
        }
            break;
        case 5:
        {
            color1 = RGB(51, 102, 102, 1);
            color2 = RGB(255, 255, 204, 1);
        }
            break;
        case 6:
        {
            color1 = RGB(92, 66, 93, 1);
            color2 = RGB(175, 167, 186, 1);
        }
            break;
            
        default:
            break;
    }

}

- (void)setchaxunview
{
    cityList = [[NSMutableArray alloc] init];
    NSArray *che =  [ChenshiModel searchWithWhere:@"" orderBy:nil offset:0 count:100];
    if ([che count] > 0) {
        cityList = [che mutableCopy];
    }
    
    sousuoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    chatableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH-60, SCREEN_HEIGHT-20) style:UITableViewStylePlain];
    chatableview.delegate = self;
    chatableview.dataSource = self;
    chatableview.backgroundColor = [UIColor clearColor];
    [sousuoView addSubview:chatableview];
    sousuoView.backgroundColor = color1;
    [self.view addSubview:sousuoView];
}

- (void)setviews
{
    [self selectcolor];
    
    [self setchaxunview];
    backview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*2 - 60, SCREEN_HEIGHT )];
    backview.layer.shadowColor = [UIColor blackColor].CGColor;
    backview.layer.shadowOffset = CGSizeMake(-6, 0);
    backview.layer.shadowOpacity = 0.3;
    
    [self.view addSubview:backview];
    
    secView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH - 60, SCREEN_HEIGHT)];
    [backview addSubview:secView];
    
    backview.backgroundColor = color1;
    
    [UIView animateWithDuration:1.5 animations:^{
        secView.backgroundColor = color2;
        
        sousuoView.backgroundColor = color1;
        [beijinLa sizeToFit];
        self.view.backgroundColor = color1;
    }];
    
    
    beijinLa = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    beijinLa.textColor = [UIColor colorWithWhite:0.7 alpha:0.1];
    beijinLa.backgroundColor = color1;
    beijinLa.numberOfLines = 0;
    beijinLa.lineBreakMode = NSLineBreakByCharWrapping;
    beijinLa.font = [UIFont systemFontOfSize:SCREEN_WIDTH];
    [backview addSubview:beijinLa];
    
    int jianY = iPhone5?30:50;
    if (iPhone4) {
        jianY = 10;
    }
    
    didianLa = [[UILabel alloc]initWithFrame:CGRectMake(10, 20 + jianY, SCREEN_WIDTH - 20, 60)];
    didianLa.textColor = [UIColor whiteColor];
    didianLa.textAlignment = NSTextAlignmentCenter;
    didianLa.font = [UIFont systemFontOfSize:35];
    didianLa.alpha = 0.6;
    [backview addSubview:didianLa];
    
    zhuangtai = [[UILabel alloc] initWithFrame:CGRectMake(0, RELAY_y(didianLa) + jianY, SCREEN_WIDTH, 30)];
    zhuangtai.textColor = [UIColor whiteColor];
    zhuangtai.textAlignment = NSTextAlignmentCenter;
    zhuangtai.font = [UIFont systemFontOfSize:30];
    [backview addSubview:zhuangtai];
    
    shishiLa = [[UILabel alloc] initWithFrame:CGRectMake(0, RELAY_y(zhuangtai) + jianY, SCREEN_WIDTH, 83)];
    shishiLa.textColor = [UIColor whiteColor];
    shishiLa.textAlignment = NSTextAlignmentCenter;
    shishiLa.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:83];
    [backview addSubview:shishiLa];
    
    UISwipeGestureRecognizer *swip1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    UISwipeGestureRecognizer *swip2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    swip1.direction = UISwipeGestureRecognizerDirectionLeft;
    swip2.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swip2];
    [self.view addGestureRecognizer:swip1];
    
    
    view = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 260, SCREEN_WIDTH, 220)];
    if (!iPhone4&&!iPhone6&&!iPhone5) {
        view = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 300, SCREEN_WIDTH, 220)];
    }
    
    
    int j = 4;
    
    for (int i = 0; i < 3; i++) {
        
        UILabel *xingqi = [[UILabel alloc] initWithFrame:CGRectMake(i*SCREEN_WIDTH/3, 0, view.frame.size.width/3, 60)];
        xingqi.tag = j++;
        xingqi.textColor = [UIColor whiteColor];
        xingqi.font = [UIFont systemFontOfSize:20];
        [view addSubview:xingqi];
        
        UILabel *zhuangtaifen = [[UILabel alloc] initWithFrame:CGRectMake(i*SCREEN_WIDTH/3, RELAY_y(xingqi), view.frame.size.width/3, 60)];
        zhuangtaifen.textColor = [UIColor whiteColor];
        zhuangtaifen.font = [UIFont systemFontOfSize:20];
        if(iPhone5 || iPhone4)
            zhuangtaifen.font = [UIFont systemFontOfSize:18];
        
        zhuangtaifen.tag = j++;
        [view addSubview:zhuangtaifen];
        
        UILabel *wenduer = [[UILabel alloc] initWithFrame:CGRectMake(i*SCREEN_WIDTH/3, RELAY_y(zhuangtaifen)+20, view.frame.size.width/3, 20)];
        wenduer.textColor = [UIColor whiteColor];
        wenduer.font = [UIFont systemFontOfSize:20];
        wenduer.tag = j++;
        [view addSubview:wenduer];
        
        UILabel *wenduer1 = [[UILabel alloc] initWithFrame:CGRectMake(i*SCREEN_WIDTH/3, RELAY_y(wenduer), view.frame.size.width/3, 20)];
        wenduer1.textColor = [UIColor whiteColor];
        wenduer1.font = [UIFont systemFontOfSize:20];
        wenduer1.alpha = 0.8;
        wenduer1.tag = j++;
        [view addSubview:wenduer1];
        
    }
    [view sizeToFit];
    [backview addSubview:view];
    
    UIButton *shuaxinBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 90)];
    [shuaxinBt addTarget:self action:@selector(getDataOnCLick) forControlEvents:UIControlEventTouchUpInside];
    shuaxinBt.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 2.5);
    [shuaxinBt setTitle:@"刷新" forState:UIControlStateNormal];
    shuaxinBt.titleLabel.font = [UIFont systemFontOfSize:25];
    [shuaxinBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    shuaxinBt.layer.cornerRadius = 50;
    shuaxinBt.layer.masksToBounds = YES;
    shuaxinBt.layer.borderColor = [UIColor whiteColor].CGColor;
    shuaxinBt.layer.borderWidth = 2;
    [shuaxinBt setTitleEdgeInsets:UIEdgeInsetsMake(-31, 0, 0, 0)];
    [backview addSubview:shuaxinBt];
    
    TuijianLa = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 + 50, SCREEN_HEIGHT - 30, SCREEN_WIDTH/2 - 50, 25)];
    TuijianLa.textColor = [UIColor whiteColor];
    TuijianLa.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:20];
    TuijianLa.textAlignment = NSTextAlignmentCenter;
    [backview addSubview:TuijianLa];
    
    pmLa = [[UILabel alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT - 35, 0, 25)];
    pmLa.textColor = color1;
    pmLa.layer.masksToBounds = YES;
    pmLa.layer.cornerRadius = 3;
    pmLa.font = [UIFont systemFontOfSize:25];
    pmLa.backgroundColor = [UIColor blackColor];
    [backview addSubview:pmLa];

    
    tablewview = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, secView.frame.size.width, SCREEN_HEIGHT - 20)];
    tablewview.delegate = self;
    tablewview.dataSource = self;
    tablewview.separatorStyle = UITableViewCellSeparatorStyleNone;
    tablewview.backgroundColor = [UIColor clearColor];
    tablewview.showsVerticalScrollIndicator = NO;
    
    [secView addSubview:tablewview];
    
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p
{
    
    if (p.y >= SCREEN_HEIGHT - 15 ) {
        [qiuview removeFromSuperview];
        [animator removeBehavior:behavior];
        [self selectcolor];
                  //通知主线程刷新
        backview.backgroundColor = color1;
        [UIView animateWithDuration:1.5 animations:^{
            secView.backgroundColor = color2;
            beijinLa.backgroundColor = color1;
            sousuoView.backgroundColor = color1;
            pmLa.textColor = color1;
            self.view.backgroundColor = color1;
            [beijinLa sizeToFit];
//            backview.layer.shadowColor = color2.CGColor;
        }];
    }
}

-(void)getDataOnCLick
{
    if (cityindex == 0) {
        [self getData];
    }
    else
    {
        ChenshiModel *city = [cityList objectAtIndex:cityindex-1];
        [[AFHttp share] get:[NSString stringWithFormat:@"http://api.k780.com:88/?app=weather.future&weaid=%@&&appkey=%d&sign=%@&format=json",city.cityid,Appkey,K780Sign] parameter:nil requblock:^(id result, BOOL success) {
            if (success) {
                if ([[result objectForKey:@"success"] integerValue] == 1) {
                    city.weekdic = [result objectForKey:@"result"];
                    [[AFHttp share] get:[NSString stringWithFormat:@"http://api.k780.com:88/?app=weather.pm25&weaid=%@&appkey=%d&sign=%@&format=json",city.cityid,Appkey,K780Sign] parameter:nil requblock:^(id result, BOOL success) {
                        if (success) {
                            if ([[result objectForKey:@"success"] integerValue] == 1) {
                                city.pmdic = [result objectForKey:@"result"];
                                [city saveToDB];
                                [self settianjiacityshuju:city];
                                
                            }
                        }
                    }];
                }
            }
        }];
        

    }
    
    qiuview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    qiuview.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT - 40);
    qiuview.layer.masksToBounds = YES;
    qiuview.layer.cornerRadius = 15;
    qiuview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:qiuview];
    
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[qiuview]];
    UICollisionBehavior *collision=[[UICollisionBehavior alloc]initWithItems:@[qiuview]];
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc]
                                   initWithItems:@[qiuview]
                                   mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.pushDirection = CGVectorMake(-1, -1);
    pushBehavior.magnitude = 10;
    collision.collisionMode = UICollisionBehaviorModeEverything;
    collision.collisionDelegate = self;
    collision.translatesReferenceBoundsIntoBoundary = YES;
    gravity.magnitude = 0;
    gravity.gravityDirection = CGVectorMake(0, 0);
    
    UIDynamicItemBehavior *behavi = [[UIDynamicItemBehavior alloc] initWithItems:@[qiuview,self.view]];
    behavi.elasticity = 0.99;
    behavi.allowsRotation = YES;
    behavi.friction = 0;
    behavi.density = 0;
    behavi.resistance = 0;
    behavi.angularResistance = 0;
    [animator addBehavior:behavi];
    [animator addBehavior:pushBehavior];
    [animator addBehavior:gravity];
    [animator addBehavior:collision];
}

- (void)settianjiacityshuju:(ChenshiModel *)city
{
    [self shijian];
    beijinLa.text = city.weekdic[0][@"weather"];
    
    didianLa.text = [NSString stringWithFormat:@"%@",city.cityname];
    NSString *strrr = [NSString stringWithFormat:@"%@ %@", city.weekdic[0][@"weather"],city.weekdic[0][@"winp"]];
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString: strrr];
    
    [attributeString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20],NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange([city.weekdic[0][@"weather"]length] + 1, [city.weekdic[0][@"winp"] length])];
    zhuangtai.attributedText = attributeString;
    
    NSArray *arr = [city.weekdic[0][@"temperature"] componentsSeparatedByString:@"/"];
    attributeString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@/%@",[arr[0] substringToIndex:[arr[0] length]-1],arr[1]]];
    [attributeString addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50],NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange([attributeString length] -  1, 1)];
    shishiLa.attributedText = attributeString;
    
    int pm = [city.pmdic[@"aqi"] intValue];
    pmLa.text = [NSString stringWithFormat:@"PM:%d",pm];
    [self pm:pm];

    for(int i = 4; i < 16; i++)
    {
        UILabel *la;
        la = (UILabel *)[view viewWithTag:i];
        la.textAlignment = NSTextAlignmentCenter;
        
        switch (i % 4) {
            case 0:
            {
//                la.text = city.weekdic[i/4][@"week"];
                NSString *strr = city.weekdic[i/4][@"week"];
                la.text = [strr stringByReplacingOccurrencesOfString:@"星期" withString:@"周"];
                 
            }
                break;
            case 1:
            {
                la.text = city.weekdic[i/4][@"weather"];
            }
                break;
            case 2:
            {
                NSString *str = [city.weekdic[i/4][@"temperature"] componentsSeparatedByString:@"/"][0];
                la.text = str;
            }
                break;
            case 3:
            {
                NSString *str = [city.weekdic[i/4][@"temperature"] componentsSeparatedByString:@"/"][1];
                la.text = str;
            }
                break;
                
            default:
                break;
        }
    }
    
}



- (void)setData
{
    beijinLa.text = dataDic[@"weather_data"][0][@"weather"];

    NSString *strrr = [NSString stringWithFormat:@"%@ %@",dataDic[@"weather_data"][0][@"weather"],dataDic[@"weather_data"][0][@"wind"]];
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc]initWithString: strrr];

    [attributeString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20],NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange([dataDic[@"weather_data"][0][@"weather"]length] + 1, [dataDic[@"weather_data"][0][@"wind"] length])];
    
    zhuangtai.attributedText = attributeString;
    NSString *shi = dataDic[@"weather_data"][0][@"date"];
    NSArray *arr = [shi componentsSeparatedByString:@"："];
    
    
    strrr = [[arr lastObject] substringToIndex:[[arr lastObject] length]-1];
    attributeString = [[NSMutableAttributedString alloc]initWithString: strrr];
    
    [attributeString addAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50],NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange([strrr length] -  1, 1)];
    shishiLa.attributedText = attributeString;
    
    
    int pm = [dataDic[@"pm25"] intValue];
    pmLa.text = [NSString stringWithFormat:@"PM:%@",dataDic[@"pm25"]];
    [self pm:pm];
    for(int i = 4; i < 16; i++)
    {
        UILabel *la;
        la = (UILabel *)[view viewWithTag:i];
        la.textAlignment = NSTextAlignmentCenter;
        
        switch (i % 4) {
            case 0:
            {
                la.text = dataDic[@"weather_data"][i/4][@"date"];
            }
                break;
            case 1:
            {
                la.text = dataDic[@"weather_data"][i/4][@"weather"];
            }
                break;
            case 2:
            {
                NSString *str = [dataDic[@"weather_data"][i/4][@"temperature"] componentsSeparatedByString:@" ~ "][0];
                la.text = [NSString stringWithFormat:@"%@°", str];
            }
                break;
            case 3:
            {
                NSString *str = [dataDic[@"weather_data"][i/4][@"temperature"] componentsSeparatedByString:@" ~ "][1];
                la.text = [NSString stringWithFormat:@"%@°", [str substringToIndex:([str length] - 1)]];
            }
                break;

            default:
                break;
        }
    }
    
    
}


#pragma mark - 左右滑动
- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (backview.frame.origin.x == SCREEN_WIDTH - 60) {
            [UIView animateWithDuration:0.4 animations:^{
                backview.frame = CGRectMake(0, 0, backview.frame.size.width, backview.frame.size.height);
                
            }];
        }
        else if(backview.frame.origin.x == 0)
        {
            [tablewview reloadData];
            [UIView animateWithDuration:0.4 animations:^{
                backview.frame = CGRectMake(60 - SCREEN_WIDTH, 0, backview.frame.size.width, backview.frame.size.height);
                
            }];
        }

    }
    
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        if (backview.frame.origin.x == 60 - SCREEN_WIDTH) {
            [UIView animateWithDuration:0.5 animations:^{
                
                backview.frame = CGRectMake(0, 0, backview.frame.size.width, backview.frame.size.height);
            }];
        }
        else if (backview.frame.origin.x == 0)
        {
            [chatableview reloadData];
            [UIView animateWithDuration:0.5 animations:^{
                backview.frame = CGRectMake(SCREEN_WIDTH - 60, 0, backview.frame.size.width, backview.frame.size.height);
            }];
        }

    }
}
- (void)pm:(int)pm
{
    [pmLa sizeToFit];
    pmLa.center = CGPointMake(SCREEN_WIDTH/4 - 25, SCREEN_HEIGHT - 20);
    pmLa.backgroundColor = [UIColor whiteColor];
    if (pm >= 0 && pm < 50)
    {
        pmLa.alpha = 0.14;
    }
    else if (pm >= 50 && pm < 100)
    {
        pmLa.alpha = 0.29;
    }
    else if (pm >= 100 && pm < 150)
    {
        pmLa.alpha = 0.43;
    }
    else if (pm >= 150 && pm < 200)
    {
        pmLa.alpha = 0.57;
    }
    else if (pm >= 200 && pm < 300)
    {
        pmLa.alpha = 0.71;
    }
    else if (pm >= 300 && pm < 500)
    {
        pmLa.alpha = 0.86;
    }
    else if (pm >= 500)
    {
        pmLa.alpha = 1;
    }
    

}
#pragma mark - 列表代理
// 表中的结构
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == tablewview) {
        return 1;
    }
    if (tableView == chatableview)
    {
        return [cityList count]+2;
    }
    return 0;
}
// 有几个section
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == tablewview) {
        return [dataDic[@"index"] count];
    }
    if (tableView == chatableview)
    {
        return 1;
    }
    return 0;
}

// 有多高
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tablewview) {
        return 100;
    }
    if (tableView == chatableview)
    {
        return 90;
    }
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == tablewview) {
        return 40;
    }
    if (tableView == chatableview)
    {
        return 0;
    }
    return 0;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tablewview.frame.size.width, 40)];
    UILabel* titleLa = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tablewview.frame.size.width - 20, 40)];
    if(section < [dataDic[@"index"] count] - 1)
        titleLa.text = [NSString stringWithFormat:@"%@  %@",dataDic[@"index"][section][@"title"],dataDic[@"index"][section][@"zs"]];
    else
        titleLa.text = [NSString stringWithFormat:@"以上几点小小的建议只针对%@，另外+1s",dataDic[@"currentCity"]];
    titleLa.textColor = color1;
    titleLa.numberOfLines = 0;
    titleLa.lineBreakMode = NSLineBreakByCharWrapping;
    titleLa.font = [UIFont systemFontOfSize:16];
    topView.backgroundColor = [UIColor clearColor];
    [topView addSubview:titleLa];
    return topView;
}


//插入数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == tablewview) {
        static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                 TableSampleIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:TableSampleIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = color1;
        if (indexPath.section < [dataDic[@"index"] count] - 1) {
            cell.textLabel.text = dataDic[@"index"][indexPath.section][@"des"];
        }
        else
        {
            cell.textLabel.text = @"做了一点微小的工作，希望大家资次。吼不吼哇！";
        }
        
        return cell;

    }

    static NSString *TableSampleIdentifier = @"TableSampleIdentifier1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             TableSampleIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:TableSampleIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:30];
    if (indexPath.row == [cityList count]+1) {
        cell.textLabel.text = @"发现新城市";
        [cell setEditing:NO];
    }
    else if (indexPath.row == 0)
    {
        [cell setEditing:YES];
        cell.textLabel.text = @"";
        NSArray *weaArr = [WeaModel searchWithWhere:@"" orderBy:@"" offset:0 count:1];
        if ([weaArr count] > 0) {
            WeaModel *wea = [weaArr firstObject];
            cell.textLabel.text = wea.Strdress;
        }
    }
    else{
        ChenshiModel *city = [cityList objectAtIndex:indexPath.row-1];
        cell.textLabel.text = city.cityname;
        [cell setEditing:NO];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == tablewview||(tableView == chatableview && ( indexPath.row == 0 || indexPath.row == [cityList count]+1)))
        return NO;
    else
        return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == chatableview) {
        
        if (indexPath.row == [cityList count]+1) {
            ChaxunViewController *cha = [[ChaxunViewController alloc] init];
            cha.modalPresentationStyle=UIModalPresentationOverCurrentContext;
            cha.block = ^(NSDictionary *dic){
                ChenshiModel *citymodel = [[ChenshiModel alloc] init];
                citymodel.cityid = [dic objectForKey:@"cityid"][@"cityid"];
                citymodel.cityname = [[dic objectForKey:@"pmdic"] objectForKey:@"citynm"];
                citymodel.weekdic = [dic objectForKey:@"weekdic"];
                citymodel.pmdic = [dic objectForKey:@"pmdic"];
                [citymodel saveToDB];
                
                cityList = [[NSMutableArray alloc] init];
                NSArray *che =  [ChenshiModel searchWithWhere:@"" orderBy:nil offset:0 count:100];
                if ([che count] > 0) {
                    cityList = [che mutableCopy];
                }

                [tableView reloadData];
                
            };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:cha animated:YES completion:nil];
            });
            
        }
        else if(indexPath.row == 0)
        {
            cityindex = 0;
            if (backview.frame.origin.x == SCREEN_WIDTH - 60) {
                [UIView animateWithDuration:0.4 animations:^{
                    backview.frame = CGRectMake(0, 0, backview.frame.size.width, backview.frame.size.height);
                }];
            }
            [self getData];
        }
        else
        {
            cityindex = indexPath.row;
            ChenshiModel *city = [cityList objectAtIndex:indexPath.row-1];
            [self settianjiacityshuju:city];
            if (backview.frame.origin.x == SCREEN_WIDTH - 60) {
                [UIView animateWithDuration:0.4 animations:^{
                    backview.frame = CGRectMake(0, 0, backview.frame.size.width, backview.frame.size.height);
                }];
            }
            [[AFHttp share] get:[NSString stringWithFormat:@"http://api.k780.com:88/?app=weather.future&weaid=%@&&appkey=%d&sign=%@&format=json",city.cityid,Appkey,K780Sign] parameter:nil requblock:^(id result, BOOL success) {
                if (success) {
                    if ([[result objectForKey:@"success"] integerValue] == 1) {
                        city.weekdic = [result objectForKey:@"result"];
                        [[AFHttp share] get:[NSString stringWithFormat:@"http://api.k780.com:88/?app=weather.pm25&weaid=%@&appkey=%d&sign=%@&format=json",city.cityid,Appkey,K780Sign] parameter:nil requblock:^(id result, BOOL success) {
                            if (success) {
                                if ([[result objectForKey:@"success"] integerValue] == 1) {
                                    city.pmdic = [result objectForKey:@"result"];
                                    [city saveToDB];
                                    [self settianjiacityshuju:city];

                                }
                            }
                        }];
                    }
                }
            }];


        }
        
    }
    else
    {
            NSArray *arrLogin = [LoginModel searchWithWhere:@"" orderBy:@"" offset:0 count:1];
            if ([arrLogin count] == 0) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"起个名吧" message:@"主要是不起名字进不去呀" preferredStyle:UIAlertControllerStyleAlert];
                
                [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    // 可以在这里对textfield进行定制，例如改变背景色
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
                    
                }];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    UMComUserAccount *userAccount = [[UMComUserAccount alloc] init];
                    userAccount.usid = [UUID getUUID];
                    userAccount.name = namesting;
                    userAccount.icon_url = nil; //登录用户头像
                    
                    [UMComPushRequest loginWithCustomAccountForUser:userAccount completion:^(id responseObject, NSError *error) {
                        if(!error){
                            //登录成功
                            LoginModel *log = [[LoginModel alloc] init];
                            log.name = namesting;
                            [log saveToDB];
                            
                            self.navigationController.navigationBarHidden = NO;
                            UIViewController *communityViewController = [UMCommunity getFeedsViewController];
                            [self.navigationController pushViewController:communityViewController animated:YES];
                            
                        }else{
                            //登录失败
                            
                            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                            
                            // Set the annular determinate mode to show task progress.
                            hud.mode = MBProgressHUDModeText;
                            hud.label.text = @"换个名？可能重名了";
                            // Move to bottm center.
                            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                            
                            [hud hideAnimated:YES afterDelay:1.5];

                        }
                    }];
                    
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
                }];
                [alertController addAction:okAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
                

            }
            else
            {
                LoginModel *log = arrLogin[0];
                UMComUserAccount *userAccount = [[UMComUserAccount alloc] init];
                userAccount.usid = [UUID getUUID];
                userAccount.name = log.name;
                userAccount.icon_url = nil; //登录用户头像
                
                [UMComPushRequest loginWithCustomAccountForUser:userAccount completion:^(id responseObject, NSError *error) {
                    if(!error){
                        //登录成功
                        self.navigationController.navigationBarHidden = NO;
                        UIViewController *communityViewController = [UMCommunity getFeedsViewController];
                        [self.navigationController pushViewController:communityViewController animated:YES];
                        
                    }else{
                        //登录失败
                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                        
                        // Set the annular determinate mode to show task progress.
                        hud.mode = MBProgressHUDModeText;
                        hud.label.text = @"换个名？可能重名了";
                        // Move to bottm center.
                        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                        
                        [hud hideAnimated:YES afterDelay:1.5];

                    }
                }];


            }
        }
}

- (void)alertTextFieldDidChange:(NSNotification *)notification{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UITextField *login = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        okAction.enabled = login.text.length > 2 && login.text.length < 20;
        namesting = login.text;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0||indexPath.row == [cityList count]+1) {
        return;
    }
    if (editingStyle ==UITableViewCellEditingStyleDelete)
    {
        
        __weak ChenshiModel *city = [cityList objectAtIndex:indexPath.row-1];
        [city deleteToDB];
        [cityList removeObjectAtIndex:indexPath.row -1];
        [tableView  deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
    }
}


-(NSString *)md5:(NSString *)str {
    
    
    
    const char *cStr = [str UTF8String];
    
    
    
    unsigned char result[16];
    
    
    
    CC_MD5( cStr, strlen(cStr), result );
    
    
    
    return [NSString stringWithFormat:
            
            
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            
            
            
            result[0], result[1], result[2], result[3],
            
            
            
            result[4], result[5], result[6], result[7],
            
            
            
            result[8], result[9], result[10], result[11],
            
            
            
            result[12], result[13], result[14], result[15]
            
            
            
            ]; 
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
