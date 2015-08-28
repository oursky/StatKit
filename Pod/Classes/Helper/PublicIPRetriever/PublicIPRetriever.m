//
//  PublicIPRetriever.m
//  StatKit
//
//  Created by Steven Chan on 28/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#import "PublicIPRetriever.h"

@implementation PublicIPRetriever
{
    NSMutableArray *_registeredAPIToParserDictionaries;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _registeredAPIToParserDictionaries = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)registeredAPIToParserDictionaries
{
    return [_registeredAPIToParserDictionaries copy];
}

- (void)registerAPI:(NSString*)api withParser:(id<PublicIPResultParser>)parser
{
    [_registeredAPIToParserDictionaries addObject:@{ @"API" : api,
                                                     @"Parser" : parser }];
}

- (void)lookupCurrentPublucIP:(void(^)(NSString* publucIP))resultHandler
{
    NSArray *lookupTable = [_registeredAPIToParserDictionaries copy];
    
    __block void (^lookUpFunc)(NSUInteger);
    
    lookUpFunc = ^(NSUInteger currentIndex) {
        
        if (currentIndex > lookupTable.count - 1)
        {
            resultHandler(nil);
            return;
        }
        
        NSDictionary *d = lookupTable[currentIndex];
        
        id<PublicIPResultParser> parser = d[@"Parser"];
        
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithURL:[NSURL URLWithString:d[@"API"]]
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    if (error)
                    {
                        lookUpFunc(currentIndex + 1);
                    }
                    else
                    {
                        NSString *ip = [parser parseResult:data];
                        
                        if (ip)
                        {
                            resultHandler(ip);
                        }
                        else
                        {
                            lookUpFunc(currentIndex + 1);
                        }
                    }
                    
                }] resume];
    };
    
    lookUpFunc(0);
}

@end
