//
//  NSDate+UnixTimestamp.m
//  StatKit
//
//  Created by Steven Chan on 27/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#import "NSDate+UnixTimestamp.h"

@implementation NSDate (UnixTimestamp)

- (long)unixTimestamp
{
    double time = floor([self timeIntervalSince1970] * 1000.0);
    return (long)time;
}

@end
