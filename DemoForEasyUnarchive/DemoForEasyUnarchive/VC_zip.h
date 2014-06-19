//
//  VC_zip.h
//  DemoForZip
//
//  Created by Shaokun DarkLinden on 4/10/12.
//  Copyright (c) 2012 darklinden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyUnarchive.h"
#import "VC_encodings.h"

@interface VC_zip : UIViewController <EasyUnarchiveDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, VC_encodingsDelegate>
@property (nonatomic, strong) NSString *path;
@end
