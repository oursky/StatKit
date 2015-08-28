//
//  SKClientSubClass.h
//  StatKit
//
//  Created by Steven Chan on 26/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#ifndef SKClientSubClass_h
#define SKClientSubClass_h

#import "SKClient.h"

@interface SKClient (SubClass)

- (NSUInteger)pendingEventsCount;
- (NSUInteger)pendingSessionsCount;

#pragma mark Methods overridden by subclass

/*!
 
 return nil if not interested about reachability
 
 */
- (NSString*)reachabilityTargetHost;

- (BOOL)shouldSubmitLog;

- (void)sendDataToServer:(NSData*)data resultHandler:(void(^)(BOOL success))resultHandler;

@end


#endif /* SKClientSubClass_h */
