//
//  NutritionCell.h
//  Lab_Increment2
//
//  Created by Ravisha Thallapalli on 6/19/15.
//  Copyright (c) 2015 Sirish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NutritionCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *calories;
@property (strong, nonatomic) IBOutlet UILabel *fat;
@property (strong, nonatomic) IBOutlet UILabel *quantityPerServing;

@end
