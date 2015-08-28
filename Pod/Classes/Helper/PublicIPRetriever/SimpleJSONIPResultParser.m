//
//  SimpleJSONIPResultParser.m
//  StatKit
//
//  Created by Steven Chan on 28/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#import "SimpleJSONIPResultParser.h"

@implementation SimpleJSONIPResultParser
{
    NSString *_targetKey;
}

- (instancetype)initWithTargetKey:(NSString *)key
{
    self = [super init];
    if (self) {
        _targetKey = key;
    }
    return self;
}

- (NSString *)parseResult:(NSData *)result
{
    NSError *err = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:result
                                                         options:NSJSONReadingMutableContainers
                                                           error:&err];
    return err ? nil : [json[_targetKey] isValidIPAddress] ? json[_targetKey] : nil;
}

@end
