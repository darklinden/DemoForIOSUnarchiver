//
//  VC_encodings.m
//  DemoForZipx
//
//  Created by DarkLinden on 7/11/12.
//  Copyright (c) 2012 darklinden. All rights reserved.
//

#import "VC_encodings.h"
#import "EasyUnarchive.h"

@interface VC_encodings ()
@property (unsafe_unretained) id                   delegate;
@property (nonatomic, strong) NSArray              *pArr_list;
@property (nonatomic, strong) IBOutlet UITableView *pV_list;
@end

@implementation VC_encodings
@synthesize delegate;
@synthesize pV_list;
@synthesize pArr_list;

+ (void)showSelectEncodingWithList:(NSArray*)array delegate:(UIViewController *)delegate
{
    VC_encodings *pVC_encodings = [[VC_encodings alloc] initWithNibName:@"VC_encodings" bundle:nil];
    pVC_encodings.pArr_list = array;
    pVC_encodings.delegate = delegate;
    UINavigationController *pNav = [[UINavigationController alloc] initWithRootViewController:pVC_encodings];
    [delegate presentViewController:pNav animated:YES completion:nil];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)pBtn_cancelClick:(id)sender
{
    if (delegate) {
        if ([delegate respondsToSelector:@selector(didselectEncoding:)]) {
            [delegate didselectEncoding:[NSNumber numberWithInt:0]];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *pBtn_cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(pBtn_cancelClick:)];
    self.navigationItem.leftBarButtonItem = pBtn_cancel;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return pArr_list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [cell.textLabel setFont:[UIFont systemFontOfSize:16.f]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ -- %@", [[pArr_list objectAtIndex:indexPath.row] objectForKey:KEY_Decoded], [EasyUnarchive nameOfEncoding:[[[pArr_list objectAtIndex:indexPath.row] objectForKey:KEY_Encoding] unsignedIntegerValue]]];
    cell.tag = [[[pArr_list objectAtIndex:indexPath.row] objectForKey:KEY_Encoding] integerValue];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (delegate) {
        if ([delegate respondsToSelector:@selector(didselectEncoding:)]) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [delegate didselectEncoding:[NSNumber numberWithInt:cell.tag]];
        }
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%@", cell.textLabel.text);
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
