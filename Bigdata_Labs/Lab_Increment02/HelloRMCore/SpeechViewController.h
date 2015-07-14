//
//  SpeechViewController.h
//  HelloRMCore
//
//  Created by Ravisha Thallapalli on 6/30/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpeechKit/SpeechKit.h>
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>
@interface SpeechViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,SpeechKitDelegate, SKRecognizerDelegate,MFMessageComposeViewControllerDelegate>

@end
