//
//  RecipeDetailsViewController.h
//  HelloRMCore
//
//  Created by Ravisha Thallapalli on 7/30/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecipeDetailsViewController : UIViewController
@property (strong,nonatomic) NSString *recipeDescription;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *recipeID;
@end
