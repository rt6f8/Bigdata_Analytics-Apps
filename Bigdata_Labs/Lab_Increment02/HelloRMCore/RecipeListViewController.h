//
//  RecipeListViewController.h
//  HelloRMCore
//
//  Created by Ravisha Thallapalli on 7/30/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipeListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) NSArray *recipeList;
@end
