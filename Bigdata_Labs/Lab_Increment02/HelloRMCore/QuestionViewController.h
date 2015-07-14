//
//  QuestionViewController.h
//  HelloRMCore
//
//  Created by Ravisha Thallapalli on 7/13/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RMCore/RMCore.h>
#import <RMCharacter/RMCharacter.h>

@interface QuestionViewController : UIViewController
@property (nonatomic, strong) RMCharacter *Romo;
@property (nonatomic, strong) IBOutlet UIView *romoView;
@end
