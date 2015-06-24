//
//  ViewController.h
//  HelloRomo
//

#import <UIKit/UIKit.h>
#import <RMCore/RMCore.h>
#import <RMCharacter/RMCharacter.h>

@interface ViewController : UIViewController <RMCoreDelegate>

@property (nonatomic, strong) RMCoreRobotRomo3 *romoRobo3;
@property (nonatomic, strong) RMCharacter *romoCharacter;

- (void)addGestureRecognizers;

@end
