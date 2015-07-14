//
//  PeerToPeerViewController.m
//  HelloRMCore
//
//  Created by Ravisha Thallapalli on 6/29/15.
//  Copyright (c) 2015 Romotive. All rights reserved.
//

#import "PeerToPeerViewController.h"
#import "GCDAsyncSocket.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

#define PORT 1234
#define WELCOME_MSG  0
#define ECHO_MSG     1
#define WARNING_MSG  2

#define READ_TIMEOUT 15.0
#define READ_TIMEOUT_EXTENSION 10.0

@interface PeerToPeerViewController ()
@property (strong,nonatomic) dispatch_queue_t socketQueue;
@property (strong,nonatomic) NSMutableArray *connectedSockets;
@property (strong,nonatomic) GCDAsyncSocket *listenSocket;
@property (assign) BOOL isRunning;
@property (strong,nonatomic) UIButton *tiltDownButton;
@end

@implementation PeerToPeerViewController

@synthesize socketQueue = socketQueue;
@synthesize listenSocket = listenSocket;
@synthesize isRunning = isRunning;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [RMCore setDelegate:self];
    
    socketQueue = dispatch_queue_create("socketQueue", NULL);
    listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    _connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
    
    isRunning = NO;
    
    NSLog(@"%@", [self getIPAddress]);
    self.romoCharater = [RMCharacter Romo];
    [self toggleSocketState];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.romoCharater addToSuperview:self.romoView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 Delegate method that is triggered when the iDevice is connected to a robot.
 */
- (void)robotDidConnect:(RMCoreRobot *)robot{
    
    if ([robot isKindOfClass:[RMCoreRobotRomo3 class]]) {
        self.romo = (RMCoreRobotRomo3 *)robot;
        [self.romo.LEDs setSolidWithBrightness:0.8];
    }
    
}

/**
 Delegate method that is triggered when the iDevice is disconnected from a
 robot.
 */
- (void)robotDidDisconnect:(RMCoreRobot *)robot{
    if (robot == self.romo) {
        self.romo = nil;
        [RMCore disconnectFromSimulatedRobot];
    }
}

- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

- (void)toggleSocketState
{
    if(!isRunning)
    {
        NSError *error = nil;
        if(![listenSocket acceptOnPort:PORT error:&error])
        {
            NSLog(@"Error starting server: %@", error);
            return;
        }
        
        NSLog(@"Echo server started on port %hu", [listenSocket localPort]);
        isRunning = YES;
    }
    else
    {
        // Stop accepting connections
        [listenSocket disconnect];
        
        // Stop any client connections
        @synchronized(_connectedSockets)
        {
            NSUInteger i;
            for (i = 0; i < [_connectedSockets count]; i++)
            {
                // Call disconnect on the socket,
                // which will invoke the socketDidDisconnect: method,
                // which will remove the socket from the list.
                [[_connectedSockets objectAtIndex:i] disconnect];
            }
        }
        
        NSLog(@"Stopped Echo server");
        isRunning = false;
    }
}

#pragma mark -
#pragma mark GCDAsyncSocket Delegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    // This method is executed on the socketQueue (not the main thread)
    UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"Done" message:@"ROMO socket accepted" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert1 show];
    
    @synchronized(_connectedSockets)
    {
        [_connectedSockets addObject:newSocket];
    }
    
    NSString *host = [newSocket connectedHost];
    UInt16 port = [newSocket connectedPort];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            
            NSLog(@"Accepted client %@:%hu", host, port);
            
        }
    });
    
    NSString *welcomeMsg = @"Welcome to the AsyncSocket Echo Server\r\n";
    NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
    
    [newSocket writeData:welcomeData withTimeout:-1 tag:WELCOME_MSG];
    
    
    [newSocket readDataWithTimeout:READ_TIMEOUT tag:0];
    newSocket.delegate = self;
    
    //    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:READ_TIMEOUT tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    // This method is executed on the socketQueue (not the main thread)
    
    if (tag == ECHO_MSG)
    {
        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:100 tag:0];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    NSLog(@"== didReadData %@ ==", sock.description);
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",msg);
    [self perform:msg];
    [sock readDataWithTimeout:READ_TIMEOUT tag:0];
}

- (void)perform:(NSString *)command {
    
    NSString *cmd = [command uppercaseString];
    if ([cmd isEqualToString:@"LEFT"]) {
        [self.romo turnByAngle:-90 withRadius:0.0 completion:^(BOOL success, float heading) {
            if (success) {
                [self.romo driveForwardWithSpeed:1.0];
            }
        }];
    } else if ([cmd isEqualToString:@"RIGHT"]) {
        [self.romo turnByAngle:90 withRadius:0.0 completion:^(BOOL success, float heading) {
            [self.romo driveForwardWithSpeed:1.0];
        }];
    }else if ([cmd isEqualToString:@"UP"]) {
        [self.romo tiltByAngle:30 completion:^(BOOL success) {
            //
        }];
    }
    else if ([cmd isEqualToString:@"DOWN"]) {
        [self.romo tiltByAngle:30 completion:^(BOOL success) {
            //
        }];
    }
    else if ([cmd isEqualToString:@"BACKWARD"]) {
        [self.romo driveBackwardWithSpeed:1.0];
    } else if ([cmd isEqualToString:@"FORWARD"]) {
        [self.romo driveForwardWithSpeed:1.0];
    } else if ([cmd isEqualToString:@"SMILE"]) {
        self.romoCharater.expression=RMCharacterExpressionChuckle;
        self.romoCharater.emotion=RMCharacterEmotionHappy;
    } else if([cmd isEqualToString:@"STOP"]){
        [self.romo stopDriving];
    }else if([cmd isEqualToString:@"SAY NO"]){
        self.romoCharater.expression=RMCharacterExpressionAngry;
        self.romoCharater.emotion=RMCharacterEmotionSad;
        
        [self.romo turnByAngle:60 withRadius:.2 speed:0.75 finishingAction:RMCoreTurnFinishingActionDriveBackward completion:^(BOOL success, float heading) {
            [self.romo turnByAngle:60 withRadius:.2 speed:0.75 finishingAction:RMCoreTurnFinishingActionDriveForward completion:^(BOOL success, float heading) {
                [self.romo turnByAngle:60 withRadius:.2 speed:0.75 finishingAction:RMCoreTurnFinishingActionDriveForward completion:^(BOOL success, float heading) {
                    
                }];
            }];
        }];
    }
    else if([cmd isEqualToString:@"SAY YES"]){
        self.romoCharater.expression=RMCharacterExpressionHappy;
        self.romoCharater.emotion=RMCharacterEmotionHappy;
        
        [self.romo tiltByAngle:135 completion:^(BOOL success) {
            
        }];
        [self.romo tiltToAngle:70 completion:^(BOOL success) {
            
        }];
        
    }
    else if([cmd isEqualToString:@"SMS"]){
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.messageComposeDelegate = self;
        if([MFMessageComposeViewController canSendText])
        {
            controller.body = @"Hi This is your friend Romo";
            controller.recipients = [NSArray arrayWithObjects:@"+18602623937",@"+12482470310",@"+12104156433",@"+18167876600", nil];
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:^{
                //
            }];
        }
    }
    else if([cmd isEqualToString:@"CALL"]){
        self.romoCharater.expression=RMCharacterExpressionHappy;
        self.romoCharater.emotion=RMCharacterEmotionHappy;
        NSString *phoneNumber = [NSString stringWithFormat:@"tel://%@",@"+18162355932"];
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:phoneNumber]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        }
    }
}

/**
 * This method is called if a read has timed out.
 * It allows us to optionally extend the timeout.
 * We use this method to issue a warning to the user prior to disconnecting them.
 **/
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    if (elapsed <= READ_TIMEOUT)
    {
        NSString *warningMsg = @"Are you still there?\r\n";
        NSData *warningData = [warningMsg dataUsingEncoding:NSUTF8StringEncoding];
        
        [sock writeData:warningData withTimeout:-1 tag:WARNING_MSG];
        
        return READ_TIMEOUT_EXTENSION;
    }
    
    return 0.0;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (sock != listenSocket)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                NSLog(@"Client Disconnected");
            }
        });
        
        @synchronized(_connectedSockets)
        {
            [_connectedSockets removeObject:sock];
        }
    }
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    switch (result) {
        case MessageComposeResultCancelled:
        {
            self.romoCharater.expression = RMCharacterExpressionAngry;
            self.romoCharater.emotion = RMCharacterEmotionIndifferent;
            break;
        }
            
            
        case MessageComposeResultFailed:
        {
            self.romoCharater.emotion = RMCharacterEmotionSad;
            self.romoCharater.expression = RMCharacterExpressionSad;
            
            break;
        }
            
        case MessageComposeResultSent:
            self.romoCharater.emotion = RMCharacterEmotionHappy;
            self.romoCharater.expression = RMCharacterExpressionHappy;
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
