//
//  RecipeCell.h
//  HelloRMCore
//
//  Created by Ravisha Thallapalli on 7/30/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipeCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *recipeImage;
@property (strong, nonatomic) IBOutlet UILabel *Title;
@property (strong, nonatomic) IBOutlet UILabel *cusine;
@property (strong, nonatomic) IBOutlet UILabel *Category;

@end
