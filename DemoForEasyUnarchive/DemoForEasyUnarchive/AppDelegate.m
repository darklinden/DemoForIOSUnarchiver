//
//  AppDelegate.m
//  TestEasyUnarchive
//
//  Created by DarkLinden on 1/11/13.
//  Copyright (c) 2013 darklinden. All rights reserved.
//

#import "AppDelegate.h"

#import "VC_file.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    VC_file *pVC_file = [[VC_file alloc] initWithNibName:@"VC_file" bundle:nil];
    pVC_file.path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    UINavigationController *pNav = [[UINavigationController alloc] initWithRootViewController:pVC_file];
    self.window.rootViewController = pNav;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
