//
//  NSURL_L0URLParsing.h
//  Diceshaker
//
//  Created by ∞ on 11/02/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/// @internal
@interface NSURL (L0URLParsing)

- (NSDictionary*) dictionaryByDecodingQueryString;

@end

/// @internal
@interface NSDictionary (L0URLParsing)

- (NSString*) queryString;

@end
