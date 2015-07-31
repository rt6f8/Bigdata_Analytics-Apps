//
//  RecipeDetailsViewController.m
//  HelloRMCore
//
//  Created by Ravisha Thallapalli on 7/30/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//

#import "RecipeDetailsViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "UIImageView+AFNetworking.h"

#define RECOMMENDATIONS @"http://api.bigoven.com/recipe/%@?api_key=VeZFSX05bbUWuR60Nc2IaYX8o9pL1D9Y"

@interface RecipeDetailsViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation RecipeDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _manager = [AFHTTPRequestOperationManager manager];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSString *urlString = [NSString stringWithFormat:RECOMMENDATIONS , self.recipeID];
    NSLog(@"url is: %@",urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [[NSURLRequest requestWithURL:url] mutableCopy];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if (error) {
            return;
        }
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSString *instructions = [responseObject objectForKey:@"Instructions"];
        
        self.textView.text = instructions;
        [self.textView setEditable:NO];
        if ([[responseObject objectForKey:@"ImageURL"] isEqual:[NSNull null]]) {
            [self.imageView setImage:[UIImage imageNamed:@"no-image.jpg"]];
            return;
        }
        [self.imageView setImageWithURL:[NSURL URLWithString:[responseObject objectForKey:@"ImageURL"]] placeholderImage:[UIImage imageNamed:@"no-image.jpg"]];
        
    }];
    
//    [_manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSString *instructions = [responseObject objectForKey:@"Instructions"];
//        self.textView.text = instructions;
//        [self.imageView setImageWithURL:[NSURL URLWithString:[responseObject objectForKey:@"ImageURL"]] placeholderImage:[UIImage imageNamed:@"no-image.jpg"]];
//        [self.textView setEditable:NO];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
