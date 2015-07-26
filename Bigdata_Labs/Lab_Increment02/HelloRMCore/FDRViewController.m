//
//  FDRViewController.m
//  HelloRMCore
//
//  Created by Ravisha Thallapalli on 7/24/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//

#import "FDRViewController.h"
#import "KairosSDK.h"
#import "APLAppDelegate.h"

@interface FDRViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *RecButton;
@property (weak, nonatomic) IBOutlet UITextField *subjectField;
@property (strong, nonatomic) IBOutlet UIView *subjectView;
@property (strong, nonatomic) SKRecognizer* voiceSearch;
@property (strong, nonatomic) NSString *subjectName;
@property (strong, nonatomic) APLAppDelegate *appDelegate;
@end

const unsigned char SpeechKitApplicationKey1[] = {0x20, 0x6c, 0x8d, 0x10, 0x95, 0x50, 0xdc, 0x65, 0x32, 0x11, 0x65, 0xfd, 0x57, 0x77, 0x7b, 0xdd, 0x0f, 0xfb, 0x0b, 0x48, 0x75, 0x2e, 0x2d, 0xa8, 0xbe, 0xbb, 0xd7, 0xfa, 0x1a, 0x70, 0xdd, 0x3b, 0xdc, 0x6a, 0x4b, 0x72, 0xbb, 0x27, 0xd7, 0xed, 0x39, 0x3c, 0xea, 0x90, 0xb3, 0x65, 0x6e, 0xc2, 0x60, 0x79, 0x0a, 0xd6, 0xa8, 0x38, 0x7e, 0x66, 0xf3, 0x56, 0x61, 0x0e, 0xc6, 0x3e, 0x49, 0xa3};
@implementation FDRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.subjectView.frame = CGRectMake(0, 999, self.subjectView.frame.size.width, self.subjectView.frame.size.height);
    self.appDelegate = (APLAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self.appDelegate setupSpeechKitConnection];
#pragma mark - Kairos SDK (Authentication)
    
    /*************** Authentication ****************
     * Set your credentials once to use the API.   *
     * Don't have an appID/appKey yet? Create a    *
     * free account: https://developer.kairos.com/  *
     ***********************************************/
    [KairosSDK initWithAppId:@"4cb33905" appKey:@"b703df32b73408703107569bdeeaffb0"];
    
    
#pragma mark - Kairos SDK (Configuration Options)
    
    
    /********** Configuration Options **************
     * Set your options. These are just a few      *
     * of the available options. See the complete  *
     * documentation in KairosSDK.h                *
     ***********************************************/
     [KairosSDK setPreferredCameraType:KairosCameraFront];
     [KairosSDK setEnableFlash:YES];
     [KairosSDK setEnableShutterSound:YES];
     [KairosSDK setStillImageTintColor:@"DBDB4D"];
     [KairosSDK setProgressBarTintColor:@"FFFF00"];
     [KairosSDK setErrorMessageMoveCloser:@"Yo move closer, dude!"];
    [self startListening];
    
    
#pragma mark - Kairos SDK (Notifications)
    
    
    /**************** Notifications ****************
     * Register for any of the available           *
     * notifications                               *
     ***********************************************
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(kairosNotifications:)
     name:KairosDidCaptureImageNotification
     object:nil];
     
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(kairosNotifications:)
     name:KairosWillShowImageCaptureViewNotification
     object:nil];
     
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(kairosNotifications:)
     name:KairosWillHideImageCaptureViewNotification
     object:nil];
     
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(kairosNotifications:)
     name:KairosDidHideImageCaptureViewNotification
     object:nil];
     
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(kairosNotifications:)
     name:KairosDidShowImageCaptureViewNotification
     object:nil];*/

    // Do any additional setup after loading the view.
}

-(void)startListening{
    self.voiceSearch = [[SKRecognizer alloc] initWithType:SKSearchRecognizerType
                                                detection:SKShortEndOfSpeechDetection
                                                 language:@"en_US"
                                                 delegate:self];
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

#pragma mark - Kairos SDK (Image-Capture View API Methods)
- (IBAction)recognize:(id)sender {
    [self recommend];
}

-(void)recommend{
    /********* Image Capture Recognize *************
     * This /recognize call will display an image  *
     * capture view, and send the captured image   *
     * to the API to match against your galleries  *
     ***********************************************/
    [KairosSDK imageCaptureRecognizeWithThreshold:@".75"
                                      galleryName:@"gallery1"
                                          success:^(NSDictionary *response, UIImage *image) {
                                              NSLog(@"Response------>\n%@", response);
                                              NSString *name = [[[[response objectForKey:@"images"] objectAtIndex:0] objectForKey:@"transaction"] objectForKey:@"subject"];
                                              NSLog(@"%@", name);
                                              //[self recommendFor:name]
                                              [self startListening];
                                          } failure:^(NSDictionary *response, UIImage *image) {
                                              
                                              NSLog(@"%@", response);
                                              [self startListening];
                                              
                                          }];
}

- (IBAction)test:(id)sender {
    /************ Image Capture Enroll *************
     * This /enroll call will display an image     *
     * capture view, and send the captured image   *
     * to the API to enroll the image.             *
     ***********************************************/
    self.subjectName = nil;
    [self showSubjectView];
}

-(void)showSubjectView{
    [self.view addSubview:self.subjectView];
    self.subjectView.frame = CGRectMake(0, 999, self.subjectView.frame.size.width, self.subjectView.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        self.subjectView.frame = CGRectMake(0, 0, self.subjectView.frame.size.width, self.subjectView.frame.size.height);
    }];
}

-(void)dismissSubjectView{
    [UIView animateWithDuration:0.5 animations:^{
        self.subjectView.frame = CGRectMake(0, -999, self.subjectView.frame.size.width, self.subjectView.frame.size.height);
    }];
    
    self.subjectName = @"";
    self.subjectName = nil;
    [self.subjectView removeFromSuperview];
}





/************ Image Capture Detect *************
 * This /detect call will display an image     *
 * capture view, and send the captured image   *
 * to the API and return face attributes       *
 ***********************************************
 [KairosSDK imageCaptureDetectWithSelector:@"SETPOSE"
 success:^(NSDictionary *response, UIImage *image) {
 
 NSLog(@"%@", response);
 
 } failure:^(NSDictionary *response, UIImage *image) {
 
 NSLog(@"%@", error.localizedDescription);
 
 }];*/




#pragma mark - Kairos SDK (Standard API Methods) -

/************** Enroll With Image **************
 * This /enroll call accepts a local image and *
 * sends it to the API to enroll in your       *
 * gallery.                                    *
 ***********************************************
 UIImage *localImage = [UIImage imageNamed:@"sample.jpg"];
 [KairosSDK enrollWithImage:localImage
 subjectId:@"13"
 galleryName:@"gallery1"
 success:^(NSDictionary *response) {
 
 NSLog(@"%@", response);
 
 } failure:^(NSDictionary *response) {
 
 NSLog(@"%@", error.localizedDescription);
 
 }];*/



/************** Enroll With URL ****************
 * This /enroll call accepts a URL to an       *
 * external image and sends it to the API      *
 * to enroll in your gallery.                  *
 ***********************************************
 NSString *imageURL = @"http://media.kairos.com/liz.jpg";
 [KairosSDK enrollWithImageURL:imageURL
 subjectId:@"13"
 galleryName:@"gallery2"
 success:^(NSDictionary *response) {
 
 NSLog(@"%@", response);
 
 } failure:^(NSDictionary *response) {
 
 NSLog(@"%@", error.localizedDescription);
 
 }];*/




/************ Recognize With Image *************
 * This /recognize call accepts an image,      *
 * sends the image to the API to match against *
 * your galleries                              *
 ***********************************************
 UIImage *localImage = [UIImage imageNamed:@"sample.jpg"];
 [KairosSDK recognizeWithImage:localImage
 threshold:@".75"
 galleryName:@"gallery1"
 maxResults:@"10"
 success:^(NSDictionary *response) {
 
 NSLog(@"%@", response);
 
 } failure:^(NSDictionary *response) {
 
 NSLog(@"%@", error.localizedDescription);
 
 }];*/



/********* Recognize With Image URL ************
 * This /recognize call accepts a URL to an    *
 * image, sends the image to the API to match  *
 * against your galleries                      *
 ***********************************************
 NSString *imageURL = @"http://media.kairos.com/liz.jpg";
 [KairosSDK recognizeWithImageURL:imageURL
 threshold:@".75"
 galleryName:@"gallery1"
 maxResults:@"10"
 success:^(NSDictionary *response) {
 
 NSLog(@"%@", response);
 
 } failure:^(NSDictionary *response) {
 
 NSLog(@"%@", error.localizedDescription);
 
 }];*/




/************** Detect With Image **************
 * This /detect call uses a local image        *
 ***********************************************
 UIImage *localImage = [UIImage imageNamed:@"sample.jpg"];
 [KairosSDK detectWithImage:localImage
 selector:@"SETPOSE"
 success:^(NSDictionary *response) {
 
 NSLog(@"%@", response);
 
 } failure:^(NSDictionary *response) {
 
 NSLog(@"%@", error.localizedDescription);
 
 }];*/





/************** Detect With URL ***************
 * This /detect call sends a URL string to an  *
 * external image resource to the API and      *
 * return face attributes                      *
 ***********************************************
 NSString *imageURL = @"http://media.kairos.com/liz.jpg";
 [KairosSDK detectWithImageURL:imageURL
 selector:@"SETPOSE"
 success:^(NSDictionary *response) {
 
 NSLog(@"%@", response);
 
 } failure:^(NSDictionary *response) {
 
 NSLog(@"%@", error.localizedDescription);
 
 }];*/





/************** List Galleries *****************
 * This /gallery/list_all call returns a list  *
 * of all galleries you have created           *
 ***********************************************
 [KairosSDK galleryListAllWithSuccess:^(NSDictionary *response) {
 
 NSLog(@"%@", response);
 
 } failure:^(NSDictionary *response) {
 
 NSLog(@"%@", error.localizedDescription);
 
 }];*/






/************** View Gallery *******************
 * This /gallery/view call returns a list of   *
 * all subjects enrolled in a given gallery    *
 ***********************************************
 [KairosSDK galleryView:@"gallery1"
 success:^(NSDictionary *response) {
 
 NSLog(@"%@", response);
 
 } failure:^(NSDictionary *response) {
 
 NSLog(@"%@", error.localizedDescription);
 
 }];*/





/******** Remove Subject From Gallery **********
 * This /gallery/remove_subject call removes a *
 * give subject from a given gallery           *
 ***********************************************
 [KairosSDK galleryRemoveSubject:@"13"
 fromGallery:@"gallery1"
 success:^(NSDictionary *response) {
 
 NSLog(@"%@", response);
 
 } failure:^(NSDictionary *response) {
 
 NSLog(@"%@", error.localizedDescription);
 
 }];*/



#pragma mark    Kairos SDK Test Button -

- (void)kairosSDKExampleMethod
{
    
    /************ Image Capture Enroll *************
     * This /enroll call will display an image     *
     * capture view, and send the captured image   *
     * to the API to enroll the image.             *
     ***********************************************/
    [KairosSDK imageCaptureEnrollWithSubjectId:@"12"
                                   galleryName:@"gallery1"
                                       success:^(NSDictionary *response, UIImage *image) {
                                           
                                           // API Response object (JSON)
                                           NSLog(@"%@", response);
                                           
                                           // (Optional) View the captured image in your Photo Album
                                           // UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                                           
                                           
                                       } failure:^(NSDictionary *response, UIImage *image) {
                                           
                                           NSLog(@"%@", response);
                                           
                                       }];
    
}


- (void)kairosNotifications:(id)sender
{
    // For testing notifications
}
- (IBAction)dismiss:(id)sender {
    [self dismissSubjectView];
}
- (IBAction)done:(id)sender {
    if ([self.subjectField.text length] ==0 ) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Enter the Subject" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    [self dismissSubjectView];
    self.subjectName = self.subjectField.text;
    [KairosSDK imageCaptureEnrollWithSubjectId:self.subjectName
                                   galleryName:@"gallery1"
                                       success:^(NSDictionary *response, UIImage *image) {
                                           
                                           NSLog(@"%@", response);
                                           
                                       } failure:^(NSDictionary *response, UIImage *image) {
                                           
                                           NSLog(@"%@", response);
                                           
                                       }];

}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results{
    //long numOfResults = [results.results count];
    NSString *voice = [results firstResult];
    if ([voice isEqualToString:@"Recommend me"]) {
        [self recommend];
        
    }else if ([voice isEqualToString:@"Dot"]){
        if (self.voiceSearch) {
            [self.voiceSearch stopRecording];
            [self.voiceSearch cancel];
        }
    }
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion{
    //self.searchButton.selected = NO;
    //self.messageLabel.text = @"Connection error";
    //self.activityIndicator.hidden = YES;
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
