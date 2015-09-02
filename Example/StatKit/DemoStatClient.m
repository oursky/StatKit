//
//  DemoStatClient.m
//  StatKit
//
//  Created by Steven Chan on 26/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#import "DemoStatClient.h"
#import <StatKit/SKClientSubClass.h>

static NSString *const kStatAPI = @"";
static NSUInteger const kPendingEventCapacity = 5;

@implementation DemoStatClient

- (BOOL)shouldSubmitLog
{
    return self.pendingEventsCount > kPendingEventCapacity || self.pendingSessionsCount > 0;
}

- (void)sendDataToServer:(NSData *)data resultHandler:(void(^)(BOOL success))resultHandler
{
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    if (kStatAPI.length == 0)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((arc4random() % 3 + 1) * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            resultHandler(arc4random() % 3 != 0);
        });
    }
    else
    {
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kStatAPI]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:data];
        
        [[session dataTaskWithRequest:request
                    completionHandler:^(NSData *data,
                                        NSURLResponse *response,
                                        NSError *error) {
                        if (error)
                        {
                            NSLog(@"stat upload error: %@", error);
                            resultHandler(NO);
                        }
                        else
                        {
                            NSLog(@"stat uploaded response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                            resultHandler(YES);
                        }
                        
                    }] resume];
    }
}

@end
