//
//  SKEvent.m
//  StatKit
//
//  Created by Steven Chan on 27/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#import "SKEvent.h"
#import "NSDate+UnixTimestamp.h"

static NSString *const kKeySKClientEventSessionID = @"session_id";
static NSString *const kKeySKClientEventName = @"name";
static NSString *const kKeySKClientEventParams = @"attributes";
static NSString *const kKeySKClientEventTimestamp = @"timestamp";

@interface SKEvent ()

@property (strong, nonatomic) NSString *sessionID;
@property (assign, nonatomic) long timestamp;

@end

@implementation SKEvent

+ (SKEvent*)newEventWithName:(NSString*)name params:(NSDictionary*)params
{
    return [[self alloc] initWithName:name params:params];
}

+ (SKEvent*)eventWithDictionary:(NSDictionary*)dictionary
{
    return [[self alloc] initWithDictionary:dictionary];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (instancetype)initWithName:(NSString*)name params:(NSDictionary*)params
{
    self = [self init];
    if (self)
    {
        NSAssert([NSJSONSerialization isValidJSONObject:params], @"params cannot be converted to JSON");
        
        params = params == nil ? @{} : params;
        
        _sessionID = @"";
        _name = name;
        _params = params;
        _timestamp = [[NSDate date] unixTimestamp];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self) {
        _sessionID = dictionary[kKeySKClientEventSessionID];
        _name = dictionary[kKeySKClientEventName];
        _params = dictionary[kKeySKClientEventParams];
        _timestamp = [dictionary[kKeySKClientEventTimestamp] longValue];
    }
    return self;
}

- (NSDictionary*)dictionary
{
    return @{ kKeySKClientEventSessionID : _sessionID,
              kKeySKClientEventName : _name,
              kKeySKClientEventParams : _params,
              kKeySKClientEventTimestamp : @(_timestamp) };
}


- (void)setSessionID:(NSString*)sessionID
{
    _sessionID = sessionID;
}


@end
