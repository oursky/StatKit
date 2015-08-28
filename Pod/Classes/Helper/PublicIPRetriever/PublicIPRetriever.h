//
//  PublicIPRetriever.h
//  StatKit
//
//  Created by Steven Chan on 28/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PublicIPResultParser.h"

@interface PublicIPRetriever : NSObject

@property (strong, nonatomic) NSArray *registeredAPIToParserDictionaries;

- (void)registerAPI:(NSString*)api withParser:(id<PublicIPResultParser>)parser;

- (void)lookupCurrentPublucIP:(void(^)(NSString* publucIP))resultHandler;

@end
