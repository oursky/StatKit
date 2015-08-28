//
//  SimpleJSONIPResultParser.h
//  StatKit
//
//  Created by Steven Chan on 28/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PublicIPResultParser.h"

@interface SimpleJSONIPResultParser : NSObject <PublicIPResultParser>

- (instancetype)initWithTargetKey:(NSString*)key;

@end
