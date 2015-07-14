//
//  ViewController.m
//  DSFacialGestureDetectorExampleProject
//
//  Created by Danny Shmueli on 10/18/14.
//  Copyright (c) 2014 DS. All rights reserved.
//

#import "FacialDetectionViewController.h"
#import "DSFacialGesturesDetector.h"
#import "RoundProgressView.h"


@interface FacialDectionViewController () <DSFacialDetectorDelegate>

@property (nonatomic, weak) IBOutlet UIView *cameraPreview;
@property (nonatomic, strong) DSFacialGesturesDetector *facialGesturesDetector;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation FacialDectionViewController

const float kTimeToDissmissDetectedGestureLabel = 2.6f;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.facialGesturesDetector = [DSFacialGesturesDetector new];
    self.facialGesturesDetector.delegate = self;
    self.facialGesturesDetector.cameraPreviewView = self.cameraPreview;
    NSError *error;
    [self.facialGesturesDetector startDetection:&error];
    if (error)
    {
        [self showError:error];
    }
    self.Romo = [RMCharacter Romo];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.Romo addToSuperview:self.romoView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Facial Detector Delegate

-(void)didRegisterFacialGesutreOfType:(GestureType)facialGestureType withLastImage:(UIImage *)lastImage
{
    [self startTimerDetecetedLabelDismisallTimer];
}

-(void)didUpdateProgress:(float)progress forType:(GestureType)facialGestureType
{
    if (facialGestureType == GestureTypeSmile) {
        self.Romo.expression = RMCharacterExpressionHappy;
        self.Romo.emotion = RMCharacterEmotionExcited;
    }
}

#pragma mark - Private

-(void)showError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:
      [NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
                                message:[error localizedDescription]
                               delegate:nil
                      cancelButtonTitle:@"Dismiss"
                      otherButtonTitles:nil] show];
}

-(void)startTimerDetecetedLabelDismisallTimer
{
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimeToDissmissDetectedGestureLabel
                                                  target:self selector:@selector(dismissDetectedLabel)
                                                userInfo:nil
                                                 repeats:NO];
}

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net
