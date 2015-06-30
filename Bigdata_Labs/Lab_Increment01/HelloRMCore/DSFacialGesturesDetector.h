//
//  FacialDetector.h
//  FacialGestures
//
//  Created by Danny Shmueli on 6/28/13.
//  Copyright (c) 2013 Danny Shmueli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSFacialGesture.h"

@class UIView;
@class UIImage;

@protocol DSFacialDetectorDelegate <NSObject>

-(void)didRegisterFacialGesutreOfType:(GestureType)facialGestureType withLastImage:(UIImage *)lastImage;
@optional
-(void)didUpdateProgress:(float)progress forType:(GestureType)facialGestureType;

@end

@interface DSFacialGesturesDetector : NSObject

@property (nonatomic, weak) id<DSFacialDetectorDelegate> delegate;

/**
 *  UIView displaying the camera output, default is nil with no output.
 */
@property (nonatomic, weak) UIView *cameraPreviewView;

-(void)startDetection:(NSError **)error;
-(void)stopDetection;
@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
