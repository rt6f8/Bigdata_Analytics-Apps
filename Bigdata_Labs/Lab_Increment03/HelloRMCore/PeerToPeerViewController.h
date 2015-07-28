//
//  PeerToPeerViewController.h
//  HelloRMCore
//
//  Created by Ravisha Thallapalli on 6/29/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RMCore/RMCore.h>
#import <RMCharacter/RMCharacter.h>
#import <MessageUI/MessageUI.h>

@interface PeerToPeerViewController : UIViewController <RMCoreDelegate,MFMessageComposeViewControllerDelegate>
@property (strong,nonatomic) RMCoreRobotRomo3<HeadTiltProtocol, DriveProtocol, LEDProtocol> *romo;
@property (nonatomic, strong) RMCharacter *romoCharater;
@property (nonatomic, strong) IBOutlet UIView *romoView;
@end
