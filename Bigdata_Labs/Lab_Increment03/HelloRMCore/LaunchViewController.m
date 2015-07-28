//
//  LaunchViewController.m
//  HelloRMCore
//
//  Created by Ravisha Thallapalli on 6/29/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//

#import "LaunchViewController.h"
#import "FeatureListCell.h"
#import "APLAccelerometerGraphViewController.h"
#import "FacialDetectionViewController.h"
#import "PeerToPeerViewController.h"
#import "SpeechViewController.h"
#import "FDRViewController.h"

@interface LaunchViewController ()

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startTableView.delegate = self;
    self.startTableView.dataSource = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FeatureListCell *cell = (FeatureListCell *)[tableView dequeueReusableCellWithIdentifier:@"featurecell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[FeatureListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"featurecell"];
    }
    if (indexPath.row == 0) {
        cell.name.text = @"Color Detection";
    }else if (indexPath.row == 1){
        cell.name.text = @"Motion Sensor Detection";
    }else if (indexPath.row == 2){
        cell.name.text = @"Detect Smile";
    }else if (indexPath.row == 3){
        cell.name.text = @"Peer-to-Peer Connection";
    }else if (indexPath.row == 4){
        cell.name.text = @"Speak";
    }else if (indexPath.row == 5){
        cell.name.text = @"Facedetection";
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        UIStoryboard *stryBoard = [UIStoryboard storyboardWithName:@"MotionGraphsStoryboard" bundle:[NSBundle mainBundle]];
        APLAccelerometerGraphViewController *vc = (APLAccelerometerGraphViewController *)[stryBoard instantiateViewControllerWithIdentifier:@"AccelerometerGraphView"];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 1){
        UIStoryboard *stryBoard = [UIStoryboard storyboardWithName:@"MotionGraphsStoryboard" bundle:[NSBundle mainBundle]];
        APLAccelerometerGraphViewController *vc = (APLAccelerometerGraphViewController *)[stryBoard instantiateViewControllerWithIdentifier:@"AccelerometerGraphView"];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 2){
        UIStoryboard *stryBoard = [UIStoryboard storyboardWithName:@"Emotion" bundle:[NSBundle mainBundle]];
        FacialDectionViewController *vc = (FacialDectionViewController *)[stryBoard instantiateViewControllerWithIdentifier:@"facialDetection"];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 3){
        UIStoryboard *stryBoard = [UIStoryboard storyboardWithName:@"Socket" bundle:[NSBundle mainBundle]];
        PeerToPeerViewController *vc = (PeerToPeerViewController *)[stryBoard instantiateViewControllerWithIdentifier:@"socket"];
        [self.navigationController pushViewController:vc animated:YES];

    }else if (indexPath.row == 4){
        UIStoryboard *stryBoard = [UIStoryboard storyboardWithName:@"Speech" bundle:[NSBundle mainBundle]];
        SpeechViewController *vc = (SpeechViewController *)[stryBoard instantiateViewControllerWithIdentifier:@"Speech"];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 5){
        UIStoryboard *stryBoard = [UIStoryboard storyboardWithName:@"FDR" bundle:[NSBundle mainBundle]];
        FDRViewController *vc = (FDRViewController *)[stryBoard instantiateViewControllerWithIdentifier:@"FD"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
