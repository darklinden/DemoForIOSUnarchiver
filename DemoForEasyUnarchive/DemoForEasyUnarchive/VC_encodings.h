//
//  VC_encodings.h
//  DemoForZipx
//
//  Created by DarkLinden on 7/11/12.
//  Copyright (c) 2012 darklinden. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VC_encodingsDelegate <NSObject>
- (void)didselectEncoding:(NSNumber *)encoding;
@end

@interface VC_encodings : UIViewController <UITableViewDataSource, UITableViewDelegate>
+ (void)showSelectEncodingWithList:(NSArray*)array delegate:(UIViewController *)delegate;
@end
