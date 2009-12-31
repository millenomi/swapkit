//
//  NSURL_L0URLParsing.m
//  SwapKit
//
//  Created by ∞ on 11/02/09.

/*
 
 The MIT License
 
 Copyright (c) 2009 Emanuele Vulcano ("∞labs")
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */


#import "NSURL+L0URLParsing.h"


@implementation NSURL (L0URLParsing)

- (NSDictionary*) dictionaryByDecodingQueryString;
{
	NSString* query = [self query];
	if (!query) {
		NSString* resSpecifier = [self resourceSpecifier];
		NSRange r = [resSpecifier rangeOfString:@"?"];
		
		if (r.location == NSNotFound || r.location == [resSpecifier length] - 1)
			return [NSDictionary dictionary];
		else
			query = [resSpecifier substringFromIndex:r.location + 1];
	}
	
	NSArray* keyValuePairs = [query componentsSeparatedByString:@"&"];
	
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	for (NSString* pair in keyValuePairs) {
		NSArray* splitPair = [pair componentsSeparatedByString:@"="];
		NSAssert([splitPair count] > 0, @"At least one element out of componentsSeparatedByString:");
		NSString* key = [splitPair objectAtIndex:0];
		
		NSString* value;
		if ([splitPair count] > 2) {
			NSMutableArray* splitPairWithoutKey = [NSMutableArray arrayWithArray:splitPair];
			[splitPairWithoutKey removeObjectAtIndex:0];
			value = [splitPairWithoutKey componentsJoinedByString:@"="];
		} else if ([splitPair count] == 2)
			value = [splitPair objectAtIndex:1];
		else
			value = nil;
		
		if (value)
			[dict setObject:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		else
			[dict setObject:[NSNull null] forKey:[key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			
	}
	
	return dict;
}

@end


@implementation NSDictionary (L0URLParsing)

- (NSString*) queryString;
{
	NSMutableString* queryString = [NSMutableString string];
	
	BOOL first = YES;
	for (NSString* key in self) {
		if (!first)
			[queryString appendString:@"&"];
		[queryString appendString:[key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		
		id value = [self objectForKey:key];
		if (![value isEqual:[NSNull null]]) {
			[queryString appendString:@"="];
			[queryString appendString:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
		
		first = NO;
	}
	
	return queryString;
}

@end
