//
//  FacialGesture.h
//  FacialGestures
//
//  Created by Danny Shmueli on 6/28/13.
//  Copyright (c) 2013 Danny Shmueli. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger , GestureType) {
	GestureTypeSmile,
	GestureTypeLeftBlink,
	GestureTypeRightBlink,
	GestureTypeNoGesture
};
#import <Foundation/Foundation.h>

@interface DSFacialGesture : NSObject

@property (nonatomic, readwrite) GestureType type;
@property (nonatomic, readwrite) double timestamp;
@property (nonatomic, readwrite) float precentForFullGesture;

+(DSFacialGesture *)facialGestureOfType:(GestureType)type withTimeStamp:(double)timestamp;

+(NSString *)gestureTypeToString:(GestureType)type;

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
