//
//  SimpleIPResultParser.m
//  StatKit
//
//  Created by Steven Chan on 28/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#import "SimpleIPResultParser.h"

@implementation SimpleIPResultParser

- (NSString*)parseResult:(NSData*)result
{
    NSString *str = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [str isValidIPAddress] ? str : nil;
}

@end
