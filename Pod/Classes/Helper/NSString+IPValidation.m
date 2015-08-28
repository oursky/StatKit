//
//  NSString+IPValidation.m
//  StatKit
//
//  Created by Steven Chan on 28/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#import "NSString+IPValidation.h"
#include <arpa/inet.h>

@implementation NSString (IPValidation)

- (BOOL)isValidIPAddress
{
    const char *utf8 = [self UTF8String];
    int success;
    
    struct in_addr dst;
    success = inet_pton(AF_INET, utf8, &dst);
    if (success != 1) {
        struct in6_addr dst6;
        success = inet_pton(AF_INET6, utf8, &dst6);
    }
    
    return success == 1;
}

@end