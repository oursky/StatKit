//
//  SKEvent.h
//  StatKit
//
//  Created by Steven Chan on 27/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKData.h"

@interface SKEvent : NSObject <SKData>

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSDictionary *params;

+ (SKEvent*)newEventWithName:(NSString*)name params:(NSDictionary*)params;

+ (SKEvent*)eventWithDictionary:(NSDictionary*)dictionary;

- (instancetype)init NS_DESIGNATED_INITIALIZER;




// package method

- (void)setSessionID:(NSString*)sessionID;

- (NSDictionary*)dictionary;

@end
