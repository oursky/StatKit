//
//  SKSession.h
//  StatKit
//
//  Created by Steven Chan on 27/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKData.h"

@interface SKSession : NSObject <SKData>

@property (strong, nonatomic, readonly) NSString *id;
@property (assign, nonatomic, readonly) long timestamp;
@property (assign, nonatomic, readonly) NSUInteger count;

+ (SKSession*)newSessionWithCount:(NSUInteger)count;

+ (SKSession*)sessionWithDictionary:(NSDictionary*)dictionary;

- (instancetype)init NS_DESIGNATED_INITIALIZER;



// package method

- (void)setIPAddress:(NSString*)ipAddress;

- (NSDictionary*)dictionary;

@end
