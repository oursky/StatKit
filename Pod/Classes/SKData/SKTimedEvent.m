//
//  SKTimedEvent.m
//  StatKit
//
//  Created by Steven Chan on 27/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#import "SKTimedEvent.h"
#import "NSDate+UnixTimestamp.h"

static NSString *const kKeySKClientEventDuration = @"duration";

@interface SKTimedEvent ()

@property (strong, nonatomic) NSDate *startDate;

@property (assign, nonatomic) long duration;

@end

@implementation SKTimedEvent

- (void)start
{
    _duration = 0;
    _startDate = [NSDate date];
}

- (void)stop
{
    NSDate *stopDate = [NSDate date];
    _duration = [stopDate unixTimestamp] - [_startDate unixTimestamp];
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:[super dictionary]];
    
    d[kKeySKClientEventDuration] = @(_duration);
    
    return d;
}

@end
