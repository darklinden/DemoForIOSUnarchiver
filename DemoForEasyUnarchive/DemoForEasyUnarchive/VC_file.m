//
//  VC_file.m
//  DemoForEasyUnarchive
//
//  Created by darklinden on 14-6-19.
//  Copyright (c) 2014年 darklinden. All rights reserved.
//

#import "VC_file.h"
#import "V_loading.h"
#import "ODRefreshControl.h"
#import "VC_zip.h"

@interface VC_file () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray               *pArr_contents;
@property (nonatomic,   weak) IBOutlet UITableView  *pVt_contents;
@end

@implementation VC_file

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadData)];
    self.navigationItem.rightBarButtonItem = item;
    
    ODRefreshControl *refreshControl = [ODRefreshControl newWithScroll:self.pVt_contents actType:ODRefreshActivityTypeDefault actView:nil];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self reloadData];
        [refreshControl endRefreshing];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadData];
}

- (void)reloadData
{
    if (_path.length) {
        NSFileManager *mgr = [NSFileManager defaultManager];
        self.pArr_contents = [mgr contentsOfDirectoryAtPath:self.path error:nil];
    }
    [self.pVt_contents reloadData];
}

#pragma mark - table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _pArr_contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = _pArr_contents[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name = _pArr_contents[indexPath.row];
    NSString *fullpath = [_path stringByAppendingPathComponent:name];
    
    BOOL isDirectory = NO;
    NSFileManager *mgr = [NSFileManager defaultManager];
    BOOL fileExist = [mgr fileExistsAtPath:fullpath isDirectory:&isDirectory];
    
    if (!fileExist) {
        [self reloadData];
    }
    else {
        if (isDirectory) {
            VC_file *pVC_file = [[VC_file alloc] initWithNibName:@"VC_file" bundle:nil];
            pVC_file.path = fullpath;
            [self.navigationController pushViewController:pVC_file animated:YES];
        }
        else {
            VC_zip *pVC_zip = [[VC_zip alloc] initWithNibName:@"VC_zip" bundle:nil];
            pVC_zip.path = fullpath;
            [self.navigationController pushViewController:pVC_zip animated:YES];
        }
    }
}

@end
