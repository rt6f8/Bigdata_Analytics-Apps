//
//  RoundedCornerView.m
//  HelloRMCore
//
//  Created by Ravisha Thallapalli on 7/24/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "RoundedCornerView.h"

@implementation RoundedCornerView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
}

@end
