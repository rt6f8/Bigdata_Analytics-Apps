//
//  FacialGestureAggregator.h
//  FacialGestures
//
//  Created by Danny Shmueli on 6/28/13.
//  Copyright (c) 2013 Danny Shmueli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSFacialGesture.h"

@protocol FacialGestureAggregatorDelegte <NSObject>

-(void)didUpdateProgress:(DSFacialGesture *)gesture;

@end

@interface DSFacialGestureAggregator : NSObject

@property (nonatomic, readwrite) float samplesPerSecond;
@property (nonatomic, weak) id<FacialGestureAggregatorDelegte> delegate;

-(void)addGesture:(GestureType)gestureType;
-(GestureType)checkIfRegisteredGesturesAndUpdateProgress;

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
