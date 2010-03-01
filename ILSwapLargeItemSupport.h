//
//  ILSwapLargeItemSupport.h
//  SwapKit
//
//  Created by ∞ on 01/03/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILSwapItem.h"

@protocol ILSwapDataSource, ILSwapReader, ILSwapReaderDelegate;


@protocol ILSwapDataSource <NSObject>

- (id <ILSwapReader>) reader;

@end


@protocol ILSwapReader <NSObject>

- (void) start;
- (void) stop;
@property(readonly, getter=isRunning) BOOL running;

@property(nonatomic, assign) id <ILSwapReaderDelegate> delegate;

@end

@protocol ILSwapReaderDelegate <NSObject>

- (void) reader:(id <ILSwapReader>) r didReceiveData:(NSData*) d;

@optional
- (void) readerWillStart:(id <ILSwapReader>) r;
- (void) reader:(id <ILSwapReader>) r didEncounterError:(NSError*) e;
- (void) readerDidEnd:(id <ILSwapReader>) r;

@end


@interface ILSwapFileDataSource : NSObject <ILSwapDataSource> {
	NSString* path;
}

- (id) initWithContentsOfFile:(NSString*) f;
+ (id) dataSourceWithContentsOfFile:(NSString*) f;

@end

// ~ ~ ~

@interface ILSwapItem (ILSwapLargeItemSupport)

- (id) initWithContentsOfFile:(NSString*) f type:(NSString*) type attributes:(NSDictionary*) attributes;
+ (id) itemWithContentsOfFile:(NSString*) f type:(NSString*) type attributes:(NSDictionary*) attributes;

@end

@interface ILSwapMutableItem (ILSwapLargeItemSupport)

- (void) setValueWithContentsOfFile:(NSString*) f;

@end
