//
//  L0UUID.h
//  SwapKit
//
//  Created by ∞ on 12/08/08.


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


#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

#define L0UUID ILSwapKit_L0UUID

/// @internal
@interface L0UUID : NSObject <NSCopying, NSCoding> {
	__strong CFUUIDRef uuid;
}

// Creates a newly generated UUID.
- (id) init;

// Creates a UUID that wraps an existing Core Fondation UUID object.
- (id) initWithUUID:(CFUUIDRef) uuid;

// Creates a UUID from a correctly formatted string.
- (id) initWithString:(NSString*) string;

// Creates a UUID from the given bytes. They will be copied.
- (id) initWithBytes:(CFUUIDBytes*) bytes;

// Creates a UUID from the contents of NSData, which must wrap a
// CFUUIDBytes structure.
- (id) initWithData:(NSData*) data;

// Retrieves the wrapped Core Foundation UUID object.
- (CFUUIDRef) CFUUID;

// Returns a string of the kind '68753A44-4D6F-1226-9C60-0050E4C00067' for
// this UUID.
@property(readonly) NSString* stringValue;

// Returns the bytes this UUID is made of.
@property(readonly) CFUUIDBytes UUIDBytes;

// Returns a NSData object wrapping what would be returned by
// a call to -bytes.
@property(readonly) NSData* dataValue;

+ (id) UUID;
+ (id) UUIDWithUUID:(CFUUIDRef) uuid;
+ (id) UUIDWithString:(NSString*) string;
+ (id) UUIDWithBytes:(CFUUIDBytes*) bytes;
+ (id) UUIDWithData:(NSData*) data;

@end
