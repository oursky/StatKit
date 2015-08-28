//
//  SKClient.h
//  StatKit
//
//  Created by Steven Chan on 26/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKEvent.h"

@interface SKClient : NSObject

+ (void)setActiveClient:(SKClient*)client;

+ (instancetype)activeClient;

- (instancetype)initWithUserDefaults:(NSUserDefaults*)userDefaults;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (void)startSession;

- (void)addStatEvent:(SKEvent*)event;

@end
