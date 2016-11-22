//
//  ChaxunViewController.m
//  tianqiyubao
//
//  Created by hekai on 16/5/13.
//  Copyright © 2016年 hekai. All rights reserved.
//

#import "ChaxunViewController.h"
#import "AFHttp.h"

#import "CityList.h"

@interface ChaxunViewController ()<UISearchResultsUpdating,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
{
    UISearchController *searchController;
    UITableView *chaxuntableview;
    
    NSArray *dataList,*dataListno;
    NSMutableArray *searchList,*cityidseaList;
    NSMutableDictionary *Webdic;
}
@end

@implementation ChaxunViewController
@synthesize block;
- (void)viewDidLoad {
    [super viewDidLoad];

    
    Webdic = [[NSMutableDictionary alloc] init];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.view.alpha = 0.8;
    
    dataList = [[NSArray alloc] init];
    
    NSArray *city = [CityList searchWithWhere:@"" orderBy:@"" offset:0 count:1];
    if ([city count] > 0) {
        CityList *ci = [city firstObject];
        dataList = ci.cityinfo;
    }
    [self setviews];
}

- (void)setviews
{
    chaxuntableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT - 20) style:UITableViewStylePlain];
    chaxuntableview.delegate = self;
    chaxuntableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    chaxuntableview.dataSource = self;
    chaxuntableview.backgroundColor = [UIColor clearColor];
    
    searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchController.searchResultsUpdater = self;
    searchController.searchBar.delegate = self;
    searchController.dimsBackgroundDuringPresentation = NO;
    searchController.hidesNavigationBarDuringPresentation = NO;
    searchController.searchBar.frame = CGRectMake(searchController.searchBar.frame.origin.x ,searchController.searchBar.frame.origin.y, searchController.searchBar.frame.size.width, 44.0);
    [self.view addSubview:searchController.searchBar];
    chaxuntableview.tableHeaderView = searchController.searchBar;
    [self.view addSubview:chaxuntableview];
    
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController1{
    NSString *searchString = [searchController1.searchBar text];
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF.citynm CONTAINS[c] %@ || SELF.cityno CONTAINS[c] %@",searchString, searchString];
    if (searchList!= nil) {
        [searchList removeAllObjects];
    }
    //过滤数据
    searchList = [NSMutableArray arrayWithArray:[dataList filteredArrayUsingPredicate:preicate]];
    //刷新表格
    [chaxuntableview reloadData];
}

#pragma mark - 列表代理

// 表中的结构
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
    return [searchList count];

}
// 有几个section
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// 有多高
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

//插入数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
    cell.textLabel.textColor = [UIColor whiteColor];
    NSDictionary *textDic = [searchList objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",textDic[@"citynm"], textDic[@"cityno"]];
    return cell;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [searchController.searchBar resignFirstResponder];
    if ([searchList count] == 0) {
        return;
    }
    [Webdic setObject:[searchList objectAtIndex:indexPath.row] forKey:@"cityid"];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
   
        [[AFHttp share] get:[NSString stringWithFormat:@"http://api.k780.com:88/?app=weather.future&weaid=%@&&appkey=%d&sign=%@&format=json",[searchList objectAtIndex:indexPath.row][@"cityid"],Appkey,K780Sign] parameter:nil requblock:^(id result, BOOL success) {
            if (success) {
                if ([[result objectForKey:@"success"] integerValue] == 1) {
                    [Webdic setObject:[result objectForKey:@"result"] forKey:@"weekdic"];
                    [[AFHttp share] get:[NSString stringWithFormat:@"http://api.k780.com:88/?app=weather.pm25&weaid=%@&appkey=%d&sign=%@&format=json",[searchList objectAtIndex:indexPath.row][@"cityid"],Appkey,K780Sign] parameter:nil requblock:^(id result, BOOL success) {
                        if (success) {
                            if ([[result objectForKey:@"success"] integerValue] == 1) {
                                [Webdic setObject:[result objectForKey:@"result"] forKey:@"pmdic"];
                                NSDictionary *zhudic = Webdic;
                                block(zhudic);
                            }
                        }
                    }];
                }
            }
        }];
   
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [searchController.searchBar resignFirstResponder];
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
