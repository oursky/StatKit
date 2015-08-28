//
//  DemoStatClient.m
//  StatKit
//
//  Created by Steven Chan on 26/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#import "DemoStatClient.h"
#import <StatKit/SKClientSubClass.h>

static NSUInteger const kPendingEventCapacity = 5;

@implementation DemoStatClient

- (BOOL)shouldSubmitLog
{
    return self.pendingEventsCount > kPendingEventCapacity || self.pendingSessionsCount > 0;
}

- (void)sendDataToServer:(NSData *)data resultHandler:(void(^)(BOOL success))resultHandler
{
    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((arc4random() % 3 + 1) * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        resultHandler(arc4random() % 3 != 0);
    });
}

@end
