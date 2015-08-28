//
//  PublicIPResultParser.h
//  StatKit
//
//  Created by Steven Chan on 28/8/15.
//  Copyright © 2015 oursky. All rights reserved.
//

#ifndef PublicIPResultParser_h
#define PublicIPResultParser_h

#import <Foundation/Foundation.h>
#import "NSString+IPValidation.h"

@protocol PublicIPResultParser <NSObject>

- (NSString*)parseResult:(NSData*)result;

@end

#endif /* PublicIPResultParser_h */
