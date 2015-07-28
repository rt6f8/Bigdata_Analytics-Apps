//
//  LaunchViewController.h
//  HelloRMCore
//
//  Created by Ravisha Thallapalli on 6/29/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LaunchViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *startTableView;

@end
