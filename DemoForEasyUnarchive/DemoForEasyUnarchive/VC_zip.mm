//
//  VC_zip.m
//  DemoForZip
//
//  Created by Shaokun DarkLinden on 4/10/12.
//  Copyright (c) 2012 darklinden. All rights reserved.
//

#import "VC_zip.h"
#import "V_loading.h"
#import "ODRefreshControl.h"

@interface VC_zip ()
@property (nonatomic, strong) NSArray               *pArr_contents;
@property (nonatomic,   weak) IBOutlet UITableView  *pVt_contents;
@property (nonatomic, strong) ODRefreshControl      *refreshControl;
@end

@implementation VC_zip

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
    
    UIBarButtonItem *itemall = [[UIBarButtonItem alloc] initWithTitle:@"Unarchive" style:UIBarButtonItemStylePlain target:self action:@selector(unarchiveAll:)];
    UIBarButtonItem *itemselect = [[UIBarButtonItem alloc] initWithTitle:@"UnarcSel" style:UIBarButtonItemStylePlain target:self action:@selector(unarchiveSelect:)];
    
    self.navigationItem.rightBarButtonItems = @[itemall, itemselect];
    
    _refreshControl = [ODRefreshControl newWithScroll:self.pVt_contents actType:ODRefreshActivityTypeDefault actView:nil];
    [_refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self reloadData];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadData];
}

- (void)reloadData
{
    if (!_path.length) {
        return;
    }
    
    [V_loading showLoadingView:nil title:nil message:nil];
    if (![EasyUnarchive requestContentWithDelegate:self file:_path]) {
        NSLog(@"%s", __FUNCTION__);
        [V_loading removeLoading];
    }
}

#pragma mark - alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [EasyUnarchive cancel];
    }
    else {
        UITextField *s = [alertView textFieldAtIndex:0];
        [EasyUnarchive setPassword:s.text];
    }
}

- (void)unarchiveAll:(id)sender
{
    [V_loading showLoadingView:nil tag:0 title:@"loading..." message:nil viewType:LoadingViewType_Default];
    if (![EasyUnarchive requestUnarchiveWithDelegate:self file:_path selectedFiles:nil]) {
        NSLog(@"%s", __FUNCTION__);
        [V_loading removeLoading];
    }
}

- (void)unarchiveSelect:(id)sender
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSIndexPath *in in [_pVt_contents indexPathsForSelectedRows]) {
        [array addObject:[_pArr_contents objectAtIndex:in.row]];
    }
    
    [V_loading showLoadingView:nil title:nil message:nil];
    
    if (![EasyUnarchive requestUnarchiveWithDelegate:self file:_path selectedFiles:array]) {
        NSLog(@"%s", __FUNCTION__);
        [V_loading removeLoading];
    }
}

#pragma mark - easy delegate
- (void)didParsedFileContents:(NSArray *)contents withError:(NSString *)err
{
    [V_loading removeLoading];
    if (err) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"err" message:err delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [_refreshControl endRefreshing];
    }
    else {
        NSMutableArray *array = [NSMutableArray array];
        
        NSMutableDictionary *folderdict = [NSMutableDictionary dictionary];
        
        for (NSDictionary *obj in contents) {
            NSString *res = [NSString stringWithFormat:@"%@", [obj objectForKey:KEY_XADIsResourceForkKey]];
            if ([res isEqualToString:@"1"]) {
                continue;
            }
            else {
                [array addObject:obj];
                
                NSString *IsDirectory = [NSString stringWithFormat:@"%@", [obj objectForKey:KEY_XADIsDirectoryKey]];
                NSString *path = [NSString stringWithFormat:@"%@", [obj objectForKey:KEY_XADFileNameKey]];
                
                if ([IsDirectory isEqualToString:@"1"]) {
                    
                    NSMutableDictionary *tmpdict = folderdict;
                    for (int i = 0; i < path.pathComponents.count; i++) {
                        NSString *tmp = path.pathComponents[i];
                        NSMutableDictionary *dict = tmpdict[tmp];
                        if (!dict) {
                            dict = [NSMutableDictionary dictionary];
                        }
                        [tmpdict setObject:dict forKey:tmp];
                        tmpdict = dict;
                    }
                    
                }
                else {
                    
                    if (path.pathComponents.count > 1) {
                        NSMutableDictionary *tmpdict = folderdict;
                        for (int i = 0; i < path.pathComponents.count - 1; i++) {
                            NSString *tmp = path.pathComponents[i];
                            NSMutableDictionary *dict = tmpdict[tmp];
                            if (!dict) {
                                dict = [NSMutableDictionary dictionary];
                            }
                            [tmpdict setObject:dict forKey:tmp];
                            tmpdict = dict;
                        }
                        
                        NSMutableArray *tmparr = tmpdict[@"files"];
                        if (!tmparr) {
                            tmparr = [NSMutableArray array];
                        }
                        [tmparr addObject:path.lastPathComponent];
                        tmpdict[@"files"] = tmparr;
                    }
                    else {
                        NSMutableArray *tmparr = folderdict[@"files"];
                        if (!tmparr) {
                            tmparr = [NSMutableArray array];
                        }
                        [tmparr addObject:path.lastPathComponent];
                        folderdict[@"files"] = tmparr;
                    }
                }
            }
        }
        
        NSLog(@"folder content %@", folderdict);
        
        self.pArr_contents = [NSArray arrayWithArray:array];
        [self.pVt_contents reloadData];
        [_refreshControl endRefreshing];
    }
}

- (void)needPassword
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"type the password here" message:@"\n\n\n" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert show];
}

- (void)didselectEncoding:(NSNumber *)encoding
{
    if ([encoding integerValue] == 0) {
        [EasyUnarchive cancel];
    }
    else {
        [EasyUnarchive setEncoding:encoding];
    }
}

- (void)needEncoding:(NSArray *)encodingArray
{
    NSLog(@"%@", encodingArray);
    [VC_encodings showSelectEncodingWithList:encodingArray delegate:self];
}

- (void)didFinishUnarchiveToFolder:(NSString *)folder withError:(NSString *)err
{
    [V_loading removeLoading];
    if (err) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"err" message:err delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"info" message:@"success" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_pArr_contents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[_pArr_contents objectAtIndex:indexPath.row] objectForKey:KEY_XADFileNameKey]];
    return cell;
}


@end
