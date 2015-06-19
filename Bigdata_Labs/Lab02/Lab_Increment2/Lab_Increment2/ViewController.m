//
//  ViewController.m
//  Lab_Increment2
//
//  Created by Ravisha Thallapalli on 6/19/15.
//  Copyright (c) 2015 Sirish. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "NutritionCell.h"

#define BASE_URL @"https://api.nutritionix.com/v1_1/search/"
#define FIELDS @"?fields=item_name,item_id,brand_name,nf_calories,nf_total_fat&appId=c0927e7d&appKey=d801f26d5f8821e2e300dc75abc8548f"


#define CELL_IDENTIFIER @"nutritionCell"

#define HITS @"hits"
#define ITEM_NAME @"item_name"
#define BRAND_NAME @"brand_name"
#define CALORIES @"nf_calories"
#define FAT @"nf_total_fat"
#define SERVING_QUANTITY @"nf_serving_size_qty"
#define FIELD @"fields"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UITableView *nutritionList;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) NSArray *nutritionArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nutritionList.delegate = self;
    self.nutritionList.dataSource = self;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSearchItem:(id)sender {
    if ([_searchField.text length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter a valid Food item" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@%@",BASE_URL,_searchField.text,FIELDS ];
    NSString *urlString = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    _manager = [AFHTTPRequestOperationManager manager];
    [_manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        _nutritionArray = [responseObject objectForKey:HITS];
        [_nutritionList reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Items Found, Please try again" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _nutritionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NutritionCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[NutritionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    cell.name.text = [NSString stringWithFormat:@"Name: %@-%@", [[[_nutritionArray objectAtIndex:indexPath.row] objectForKey:FIELD] objectForKey:ITEM_NAME],[[[_nutritionArray objectAtIndex:indexPath.row] objectForKey:FIELD] objectForKey:BRAND_NAME]];
    cell.calories.text = [NSString stringWithFormat:@"Calories: %@", [[[_nutritionArray objectAtIndex:indexPath.row] objectForKey:FIELD] objectForKey:CALORIES]];
    cell.fat.text = [NSString stringWithFormat:@"Fat: %@", [[[_nutritionArray objectAtIndex:indexPath.row] objectForKey:FIELD] objectForKey:FAT]];
    cell.quantityPerServing.text = [NSString stringWithFormat:@"Quantity/Serving: %@", [[[_nutritionArray objectAtIndex:indexPath.row] objectForKey:FIELD] objectForKey:SERVING_QUANTITY]];
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_searchField resignFirstResponder];
}
- (IBAction)onClickback:(id)sender {
    [self dismissViewControllerAnimated:(YES) completion:^{
        
    }];
}

@end
