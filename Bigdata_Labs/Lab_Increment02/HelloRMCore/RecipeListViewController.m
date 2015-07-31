//
//  RecipeListViewController.m
//  HelloRMCore
//
//  Created by Ravisha Thallapalli on 7/30/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//

#import "RecipeListViewController.h"
#import "RecipeCell.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIImageView+AFNetworking.h"
#import "RecipeDetailsViewController.h"
@interface RecipeListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@end

@implementation RecipeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _manager = [AFHTTPRequestOperationManager manager];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
      target:self
      action:@selector(dismissNav:)];
    // Do any additional setup after loading the view.
}

-(void)dismissNav:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.recipeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RecipeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recipe"];
    if (cell == nil) {
        cell = [[RecipeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"recipe"];
    }
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:[[self.recipeList objectAtIndex:indexPath.row] objectForKey:@"ImageURL"]] placeholderImage:[UIImage imageNamed:@"no-image.jpg"]];
    cell.Title.text = [[self.recipeList objectAtIndex:indexPath.row] objectForKey:@"Title"];
    cell.Category.text = [[self.recipeList objectAtIndex:indexPath.row] objectForKey:@"Category"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"FDR" bundle:[NSBundle mainBundle]];
    RecipeDetailsViewController *rdvc = [storyBoard instantiateViewControllerWithIdentifier:@"recipeDetails"];
    rdvc.recipeID = [[self.recipeList objectAtIndex:indexPath.row] objectForKey:@"RecipeID"];
    [self.navigationController pushViewController:rdvc animated:YES];
}

@end
