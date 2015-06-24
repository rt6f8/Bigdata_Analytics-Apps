//
//  ViewController.m
//  HelloRomo
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

#define WELCOME_MSG  0
#define ECHO_MSG     1
#define WARNING_MSG  2

#define READ_TIMEOUT 15.0
#define READ_TIMEOUT_EXTENSION 10.0

#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
#define PORT 9876

@interface ViewController () {
    dispatch_queue_t socketQueue;
    NSMutableArray *connectedSockets;
    BOOL isRunning;
    
    GCDAsyncSocket *listenSocket;
}

@end

@implementation ViewController

#pragma mark - View Management
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // To receive messages when Robots connect & disconnect, set RMCore's delegate to self
    [RMCore setDelegate:self];
    
    // Grab a shared instance of the Romo character
    self.romoCharacter = [RMCharacter Romo];
    [RMCore setDelegate:self];
    
    [self addGestureRecognizers];
    
    // Do any additional setup after loading the view, typically from a nib.
    socketQueue = dispatch_queue_create("socketQueue", NULL);
    
    listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    
    // Setup an array to store all accepted client connections
    connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
    
    isRunning = NO;
    
    NSLog(@"%@", [self getIPAddress]);
    
    [self toggleSocketState];   //Statrting the Socket
}

- (void)viewWillAppear:(BOOL)animated
{
    // Add Romo's face to self.view whenever the view will appear
    [self.romoCharacter addToSuperview:self.view];
}

#pragma mark -
#pragma mark Robo Movement

- (NSString *)direction:(NSString *)message {
    
    return @"";
}

- (void)perform:(NSString *)command {
 
    NSString *cmd = [command uppercaseString];
    if ([cmd isEqualToString:@"LEFT"]) {
        [self.romoRobo3 turnByAngle:-90 withRadius:0.0 completion:^(BOOL success, float heading) {
            if (success) {
                [self.romoRobo3 driveForwardWithSpeed:1.0];
            }
        }];
    } else if ([cmd isEqualToString:@"RIGHT"]) {
        [self.romoRobo3 turnByAngle:90 withRadius:0.0 completion:^(BOOL success, float heading) {
            [self.romoRobo3 driveForwardWithSpeed:1.0];
        }];
    } else if ([cmd isEqualToString:@"BACKWARD"]) {
        [self.romoRobo3 driveBackwardWithSpeed:1.0];
    } else if ([cmd isEqualToString:@"FORWARD"]) {
                [self.romoRobo3 driveForwardWithSpeed:1.0];
    } else if ([cmd isEqualToString:@"SMILE"]) {
        self.romoCharacter.expression=RMCharacterExpressionChuckle;
        self.romoCharacter.emotion=RMCharacterEmotionHappy;
    } else if([cmd isEqualToString:@"STOP"]){
        [self.romoRobo3 stopDriving];
    }else if([cmd isEqualToString:@"SAY NO"]){
        self.romoCharacter.expression=RMCharacterExpressionAngry;
        self.romoCharacter.emotion=RMCharacterEmotionSad;
        
        [self.romoRobo3 turnByAngle:60 withRadius:.2 speed:0.75 finishingAction:RMCoreTurnFinishingActionDriveBackward completion:^(BOOL success, float heading) {
            [self.romoRobo3 turnByAngle:60 withRadius:.2 speed:0.75 finishingAction:RMCoreTurnFinishingActionDriveForward completion:^(BOOL success, float heading) {
                [self.romoRobo3 turnByAngle:60 withRadius:.2 speed:0.75 finishingAction:RMCoreTurnFinishingActionDriveForward completion:^(BOOL success, float heading) {
                    
                }];
            }];
        }];
        
        
    }
    else if([cmd isEqualToString:@"SAY YES"]){
        self.romoCharacter.expression=RMCharacterExpressionHappy;
        self.romoCharacter.emotion=RMCharacterEmotionHappy;
        
        [self.romoRobo3 tiltByAngle:135 completion:^(BOOL success) {
            
        }];
        [self.romoRobo3 tiltToAngle:70 completion:^(BOOL success) {
            
        }];
        
    }
}

#pragma mark - RMCoreDelegate Methods
- (void)robotDidConnect:(RMCoreRobot *)robot
{
    // Currently the only kind of robot is Romo3, so this is just future-proofing
    if ([robot isKindOfClass:[RMCoreRobotRomo3 class]]) {
        self.romoRobo3 = (RMCoreRobotRomo3 *)robot;
        
        // Change Romo's LED to be solid at 80% power
        [self.romoRobo3.LEDs setSolidWithBrightness:0.8];
        
        // When we plug Romo in, he get's excited!
        self.romoCharacter.expression = RMCharacterExpressionExcited;
    }
}

- (void)robotDidDisconnect:(RMCoreRobot *)robot
{
    if (robot == self.romoRobo3) {
        self.romoRobo3 = nil;
        
        // When we plug Romo in, he get's excited!
        self.romoCharacter.expression = RMCharacterExpressionSad;
    }
}

#pragma mark - Gesture recognizers

- (void)addGestureRecognizers
{
    // Let's start by adding some gesture recognizers with which to interact with Romo
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedUp:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeUp];
    
    UITapGestureRecognizer *tapReceived = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedScreen:)];
    [self.view addGestureRecognizer:tapReceived];
}

- (void)driveLeft {

}

- (void)swipedLeft:(UIGestureRecognizer *)sender
{
    [self.romoRobo3 turnByAngle:-90 withRadius:0.0 completion:NULL];
    // When the user swipes left, Romo will turn in a circle to his left
    //[self.Romo3 driveWithRadius:-1.0 speed:1.0];
}

- (void)swipedRight:(UIGestureRecognizer *)sender
{
    [self.romoRobo3 turnByAngle:90 withRadius:0.0 completion:NULL];
    // When the user swipes right, Romo will turn in a circle to his right
//    [self.Romo3 driveWithRadius:1.0 speed:1.0];
}

// Swipe up to change Romo's emotion to some random emotion
- (void)swipedUp:(UIGestureRecognizer *)sender
{
    int numberOfEmotions = 7;
    
    // Choose a random emotion from 1 to numberOfEmotions
    // That's different from the current emotion
    RMCharacterEmotion randomEmotion = 1 + (arc4random() % numberOfEmotions);
    
    self.romoCharacter.emotion = randomEmotion;
}

// Simply tap the screen to stop Romo
- (void)tappedScreen:(UIGestureRecognizer *)sender
{
    [self.romoRobo3 stopDriving];
}

#pragma mark -
#pragma mark Socket

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
        @synchronized(connectedSockets)
        {
            NSUInteger i;
            for (i = 0; i < [connectedSockets count]; i++)
            {
                // Call disconnect on the socket,
                // which will invoke the socketDidDisconnect: method,
                // which will remove the socket from the list.
                [[connectedSockets objectAtIndex:i] disconnect];
            }
        }
        
        isRunning = false;
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

#pragma mark -
#pragma mark GCDAsyncSocket Delegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    // This method is executed on the socketQueue (not the main thread)
    
    @synchronized(connectedSockets)
    {
        [connectedSockets addObject:newSocket];
    }
    
    NSString *host = [newSocket connectedHost];
    UInt16 port = [newSocket connectedPort];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            NSLog(@"Connection Established %@:%hu", host, port);
            
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
    
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self perform:message];
    [sock readDataWithTimeout:READ_TIMEOUT tag:0];
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
        NSString *warningMsg = @"Connection Still Alive??";
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
            }
        });
        
        @synchronized(connectedSockets)
        {
            [connectedSockets removeObject:sock];
        }
    }
}

@end
