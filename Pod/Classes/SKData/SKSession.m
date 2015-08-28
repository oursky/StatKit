//
//  SKSession.m
//  StatKit
//
//  Created by Steven Chan on 27/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#import "SKSession.h"
#import "NSDate+UnixTimestamp.h"

static NSString *const kKeySKClientSessionID = @"session_id";
static NSString *const kKeySKClientSessionTimestamp = @"timestamp";
static NSString *const kKeySKClientSessionCount = @"count";
static NSString *const kKeySKClientSessionIP = @"ip";

@interface SKSession ()

@property (strong, nonatomic) NSString *ip;

@end

@implementation SKSession

+ (SKSession *)newSessionWithCount:(NSUInteger)count
{
    return [[self alloc] initWithCount:count];
}

+ (SKSession*)sessionWithDictionary:(NSDictionary*)dictionary
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

- (instancetype)initWithCount:(NSUInteger)count
{
    self = [self init];
    if (self)
    {
        _id = [[NSUUID UUID] UUIDString];
        _timestamp = [[NSDate date] unixTimestamp];
        _count = count;
        _ip = @"";
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self)
    {
        _id = dictionary[kKeySKClientSessionID];
        _timestamp = [dictionary[kKeySKClientSessionTimestamp] longValue];
        _count = [dictionary[kKeySKClientSessionCount] integerValue];
        _ip = dictionary[kKeySKClientSessionIP];
    }
    return self;
}

- (void)setIPAddress:(NSString*)ipAddress
{
    _ip = ipAddress;
}

- (NSDictionary*)dictionary
{
    return @{ kKeySKClientSessionID : _id,
              kKeySKClientSessionTimestamp : @(_timestamp),
              kKeySKClientSessionCount : @(_count),
              kKeySKClientSessionIP : _ip };
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[SKSession class]]) return NO;
    
    return [[object id] isEqualToString:[self id]];
}

@end
