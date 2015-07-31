//
//  SpeechViewController.m
//  HelloRMCore
//
//  Created by Ravisha Thallapalli on 6/30/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//

#import "SpeechViewController.h"
#import "APLAppDelegate.h"
#import "AFHTTPRequestOperationManager.h"
#import "NutritionCell.h"
#import "WeatherCell.h"
#import <AVFoundation/AVFoundation.h>

#define BASE_URL @"https://api.nutritionix.com/v1_1/search/"
#define TTP @"http://tts-api.com/tts.mp3?"
#define WEATHER_BASE_URL @"http://api.openweathermap.org/data/2.5/weather?q="
#define FIELDS @"?fields=item_name,item_id,brand_name,nf_calories,nf_total_fat&appId=c0927e7d&appKey=d801f26d5f8821e2e300dc75abc8548f"
#define CELL_IDENTIFIER @"nutritionCell"
#define WEATHER_CELL_IDENTIFIER @"weather"

#define HITS @"hits"
#define ITEM_NAME @"item_name"
#define BRAND_NAME @"brand_name"
#define CALORIES @"nf_calories"
#define FAT @"nf_total_fat"
#define SERVING_QUANTITY @"nf_serving_size_qty"
#define FIELD @"fields"
enum TableViewState{
    TableViewNutrition,
    TableViewWeather
};

@interface SpeechViewController ()
@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UITableView *nutritionList;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) NSArray *nutritionArray;
@property (strong, nonatomic) NSArray *weatherArray;
@property (strong, nonatomic) SKRecognizer* voiceSearch;
@property (strong, nonatomic) SKVocalizer* vocalizer;
@property (strong, nonatomic) APLAppDelegate *appDelegate;
@property (nonatomic) enum TableViewState tableState;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@end
const unsigned char SpeechKitApplicationKey[] = {0x20, 0x6c, 0x8d, 0x10, 0x95, 0x50, 0xdc, 0x65, 0x32, 0x11, 0x65, 0xfd, 0x57, 0x77, 0x7b, 0xdd, 0x0f, 0xfb, 0x0b, 0x48, 0x75, 0x2e, 0x2d, 0xa8, 0xbe, 0xbb, 0xd7, 0xfa, 0x1a, 0x70, 0xdd, 0x3b, 0xdc, 0x6a, 0x4b, 0x72, 0xbb, 0x27, 0xd7, 0xed, 0x39, 0x3c, 0xea, 0x90, 0xb3, 0x65, 0x6e, 0xc2, 0x60, 0x79, 0x0a, 0xd6, 0xa8, 0x38, 0x7e, 0x66, 0xf3, 0x56, 0x61, 0x0e, 0xc6, 0x3e, 0x49, 0xa3};
@implementation SpeechViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nutritionList.delegate = self;
    self.nutritionList.dataSource = self;
    self.appDelegate = (APLAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self.appDelegate setupSpeechKitConnection];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textToSpeech:(NSString *)command{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *sentence = [command stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *url = [NSString stringWithFormat:@"%@q=%@",TTP , sentence];
    NSLog(@"url is: %@",url);
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"audio/mpeg",nil];
        NSData *audioData = responseObject;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:nil] ;
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.tableState == TableViewWeather) {
        return _weatherArray.count;
    }
    return _nutritionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tableState == TableViewNutrition) {
        NutritionCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[NutritionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
        }
        cell.name.text = [NSString stringWithFormat:@"Name: %@-%@", [[[_nutritionArray objectAtIndex:indexPath.row] objectForKey:FIELD] objectForKey:ITEM_NAME],[[[_nutritionArray objectAtIndex:indexPath.row] objectForKey:FIELD] objectForKey:BRAND_NAME]];
        cell.calories.text = [NSString stringWithFormat:@"Calories: %@", [[[_nutritionArray objectAtIndex:indexPath.row] objectForKey:FIELD] objectForKey:CALORIES]];
        cell.fat.text = [NSString stringWithFormat:@"Fat: %@", [[[_nutritionArray objectAtIndex:indexPath.row] objectForKey:FIELD] objectForKey:FAT]];
        cell.quantityPerServing.text = [NSString stringWithFormat:@"Quantity/Serving: %@", [[[_nutritionArray objectAtIndex:indexPath.row] objectForKey:FIELD] objectForKey:SERVING_QUANTITY]];
        return cell;
    }else if (self.tableState == TableViewWeather){
        WeatherCell *cell = [tableView dequeueReusableCellWithIdentifier:WEATHER_CELL_IDENTIFIER forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[WeatherCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WEATHER_CELL_IDENTIFIER];
        }
        cell.label.text = [[NSString stringWithFormat:@"%@: %@", [[[_weatherArray objectAtIndex:indexPath.row] objectForKey:@"main"] stringByReplacingOccurrencesOfString:@"\"" withString:@""],[[_weatherArray objectAtIndex:indexPath.row] objectForKey:@"description"]] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        //cell.calories.text = [NSString stringWithFormat:@"Calories: %@", [[[_nutritionArray objectAtIndex:indexPath.row] objectForKey:FIELD] objectForKey:CALORIES]];
        //cell.fat.text = [NSString stringWithFormat:@"Fat: %@", [[[_nutritionArray objectAtIndex:indexPath.row] objectForKey:FIELD] objectForKey:FAT]];
        //cell.quantityPerServing.text = [NSString stringWithFormat:@"Quantity/Serving: %@", [[[_nutritionArray objectAtIndex:indexPath.row] objectForKey:FIELD] objectForKey:SERVING_QUANTITY]];
        return cell;
    }
    return nil;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_searchField resignFirstResponder];
}

- (IBAction)startRecording:(id)sender {
    self.searchButton.selected = !self.searchButton.isSelected;
    
    // This will initialize a new speech recognizer instance
    if (self.searchButton.isSelected) {
        self.voiceSearch = [[SKRecognizer alloc] initWithType:SKSearchRecognizerType
                                                    detection:(SKShortEndOfSpeechDetection)
                                                     language:@"en_US"
                                                     delegate:self];
    }
    
    // This will stop existing speech recognizer processes
    else {
        if (self.voiceSearch) {
            [self.voiceSearch stopRecording];
            [self.voiceSearch cancel];
        }
    }
}

#pragma mark - textfield delegates

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}// return NO to not change text

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    return YES;
}// called when clear button pressed. return NO to ignore (no notifications)
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return YES;
}// called when 'return' key pressed. return NO to ignore.

#pragma mark - speech delegates
- (void)audioSessionReleased{
    
}

/*!
 @abstract Sent when the destruction process is complete.
 
 @discussion This allows the delegate to monitor the destruction process.
 Note that subsequent calls to destroy and setupWithID will be ignored until
 this delegate method is called, so if you need to call setupWithID
 again to connect to a different server, you must wait for this.
 */
- (void)destroyed{
    
}

/*!
 @abstract Sent when the recognizer starts recording audio.
 
 @param recognizer The recognizer sending the message.
 */
- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer{
    self.messageLabel.text = @"Listening..";
}

/*!
 @abstract Sent when the recognizer stops recording audio.
 
 @param recognizer The recognizer sending the message.
 */
- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer{
    self.messageLabel.text = @"Done Listening..";
}

/*!
 @abstract Sent when the recognition process completes successfully.
 
 @param recognizer The recognizer sending the message.
 @param results The SKRecognition object containing the recognition results.
 
 @discussion This method is only called when the recognition process completes
 successfully.  The results object contains an array of possible results, with
 the best result at index 0 or an empty array if no error occurred but no
 speech was detected.
 */
- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results{
    long numOfResults = [results.results count];
    
    if (numOfResults > 0) {
        // update the text of text field with best result from SpeechKit
        self.tableState = TableViewNutrition;
        self.searchField.text = [results firstResult];
        if ([_searchField.text length] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter a valid Food item" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
            return;
        }
        self.searchButton.selected = !self.searchButton.isSelected;
        
        if (self.voiceSearch) {
            [self.voiceSearch stopRecording];
            [self.voiceSearch cancel];
        }
        
        if ([_searchField.text hasPrefix:@"Call"]) {
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            NSString *phone = [_searchField.text stringByReplacingOccurrencesOfString:@"Call " withString:@""];
            NSData *decode = [phone dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            phone = [[NSString alloc] initWithData:decode encoding:NSASCIIStringEncoding];
            phone = [phone stringByReplacingOccurrencesOfString:@"?" withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@"+1" withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@")" withString:@""];
            NSNumber *myNumber = [f numberFromString:phone];
            
            if (myNumber == nil) {
                phone = [self contactWithName:phone];
                NSLog(@"%@",phone);
                if (phone==nil) {
                    return;
                }
            }
            phone = [self formatPhoneNumber:phone];
            
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:phone]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
            }
            return;
            
        }
        if ([_searchField.text hasPrefix:@"Text"]) {
            NSString *phone = [_searchField.text stringByReplacingOccurrencesOfString:@"Text"
                                                                           withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
            NSString *phoneNumber = [NSString stringWithFormat:@"+1%@",phone];
            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
            controller.messageComposeDelegate = self;
            if([MFMessageComposeViewController canSendText])
            {
                controller.body = @"";
                controller.recipients = [NSArray arrayWithObjects:phoneNumber, nil];
                controller.messageComposeDelegate = self;
                [self presentViewController:controller animated:YES completion:^{
                    //
                }];
            }
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:phoneNumber]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            }
            return;
        }
        if ([_searchField.text hasPrefix:@"Weather"]) {
            self.tableState = TableViewWeather;
            NSString *city = [_searchField.text stringByReplacingOccurrencesOfString:@"Weather "
                                                                           withString:@""];
            NSString *url = [NSString stringWithFormat:@"%@%@",WEATHER_BASE_URL,city];
            NSString *urlString = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            _manager = [AFHTTPRequestOperationManager manager];
            [_manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                _weatherArray = [responseObject objectForKey:@"weather"];
                [_nutritionList reloadData];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Items Found, Please try again" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alert show];
                return;
            }];
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
}

/*!
 @abstract Sent when the recognition process completes with an error.
 
 @param recognizer The recognizer sending the message.
 @param error The recognition error.  Possible numeric values for the
 SKSpeechErrorDomain are listed in SpeechKitError.h and a text description is
 available via the localizedDescription method.
 @param suggestion This is a suggestion to the user about how he or she can
 improve recognition performance and is based on the audio received.  Examples
 include moving to a less noisy location if the environment is extremely noisy, or
 waiting a bit longer to start speaking if the beeginning of the recording seems
 truncated.  Results are often still present and may still be of useful quality.
 
 @discussion This method is called when the recognition process results in an
 error due to any number of circumstances.  The audio system may fail to
 initialize, the server connection may be disrupted or a parameter specified
 during initialization, such as language or authentication information was invalid.
 */
- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion{
    self.searchButton.selected = NO;
    self.messageLabel.text = @"Connection error";
    //self.activityIndicator.hidden = YES;
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


-(NSArray *)contactsContainingPhoneNumber:(NSString *)phoneNumber {
    /*
     
     Returns an array of contacts that contain the phone number
     
     */
    
    // Remove non numeric characters from the phone number
    phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    // Create a new address book object with data from the Address Book database
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (!addressBook) {
        return [NSArray array];
    } else if (error) {
        CFRelease(addressBook);
        return [NSArray array];
    }
    
    // Requests access to address book data from the user
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {});
    
    // Build a predicate that searches for contacts that contain the phone number
    NSPredicate *predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary *bindings) {
        ABMultiValueRef phoneNumbers = ABRecordCopyValue( (__bridge ABRecordRef)record, (kABPersonPhoneProperty | kABPersonFirstNameProperty));
        BOOL result = NO;
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
            NSString *contactPhoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            contactPhoneNumber = [[contactPhoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
            if ([contactPhoneNumber rangeOfString:phoneNumber].location != NSNotFound) {
                result = YES;
                break;
            }
        }
        CFRelease(phoneNumbers);
        return result;
    }];
    
    // Search the users contacts for contacts that contain the phone number
    NSArray *allPeople = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    NSArray *filteredContacts = [allPeople filteredArrayUsingPredicate:predicate];
    CFRelease(addressBook);
    
    return filteredContacts;
}

-(NSArray *)contactsContainingName:(NSString *)name {
    /*
     
     Returns an array of contacts that contain the phone number
     
     */
    
    // Remove non numeric characters from the phone number
    name = [[name componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
    
    // Create a new address book object with data from the Address Book database
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (!addressBook) {
        return [NSArray array];
    } else if (error) {
        CFRelease(addressBook);
        return [NSArray array];
    }
    
    // Requests access to address book data from the user
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {});
    
    // Build a predicate that searches for contacts that contain the phone number
    NSPredicate *predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary *bindings) {
        BOOL result = NO;
        CFStringRef nameF = (CFStringRef)ABRecordCopyValue( (__bridge ABRecordRef)record,  kABPersonFirstNameProperty);
        NSString* firstName = (__bridge_transfer NSString*)nameF;
        firstName = [[firstName componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
        if ([firstName rangeOfString:name].location != NSNotFound) {
            result = YES;
        }
        /*ABMultiValueRef contactName = ABRecordCopyValue( (__bridge ABRecordRef)record,  kABPersonFirstNameProperty);
        
        BOOL result = NO;
        for (CFIndex i = 0; i < ABMultiValueGetCount(contactName); i++) {
            NSString *contactPhoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(contactName, i);
            contactPhoneNumber = [[contactPhoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
            if ([contactPhoneNumber rangeOfString:name].location != NSNotFound) {
                result = YES;
                break;
            }
        }
        CFRelease(contactName);*/
        return result;
    }];
    
    // Search the users contacts for contacts that contain the phone number
    NSArray *allPeople = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    NSArray *filteredContacts = [allPeople filteredArrayUsingPredicate:predicate];
    CFRelease(addressBook);
    return filteredContacts;
}

-(NSString *)contactWithName:(NSString *)name{
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    CFArrayRef all = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex n = ABAddressBookGetPersonCount(addressBook);
    BOOL found = FALSE;
    NSString *phoneNum = nil;
    for( int i = 0 ; i < n ; i++ )
    {
        ABRecordRef ref = CFArrayGetValueAtIndex(all, i);
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        NSLog(@"Name %@", firstName);
        
        ABMultiValueRef phones = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
        {
            CFStringRef locPhone = ABMultiValueCopyValueAtIndex(phones, j);
            if ([firstName isEqualToString:name]) {
                phoneNum = (__bridge NSString*) ABAddressBookCopyLocalizedLabel(locPhone);
                found = TRUE;
                break;
            }
        }
        if (found) {
            NSLog(@"Found Phone Number %@",phoneNum);
            break;
        }
    }
    return phoneNum;
}

-(NSString *)formatPhoneNumber:(NSString *)phoneNum{
    NSString *phoneNum1 = [phoneNum mutableCopy];
    NSData *decode = [phoneNum1 dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    phoneNum1 = [[NSString alloc] initWithData:decode encoding:NSASCIIStringEncoding];
    phoneNum1 = [phoneNum1 stringByReplacingOccurrencesOfString:@"?" withString:@""];
    phoneNum1 = [phoneNum1 stringByReplacingOccurrencesOfString:@"+1" withString:@""];
    phoneNum1 = [phoneNum1 stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneNum1 = [phoneNum1 stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneNum1 = [phoneNum1 stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phoneNum1 = [phoneNum1 stringByReplacingOccurrencesOfString:@")" withString:@""];
    NSString *phoneNumber = [NSString stringWithFormat:@"tel://+1%@",phoneNum1];
    return phoneNumber;
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
