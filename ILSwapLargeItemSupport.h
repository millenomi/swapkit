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

/**
 A data source object provides larger-than-RAM data sets to clients.
 */
@protocol ILSwapDataSource <NSObject>

/**
 Provides a reader that will produce the data contained by this source as a sequence of NSData objects. The reader will have a nil delegate and will be stopped. See the ILSwapReader protocol for more information about readers and reader states.
 */
- (id <ILSwapReader>) reader;

@end

/**
 A reader provides a way to access data from a ILSwapDataSource as a sequence of NSData objects, similar to a NSStream.
 
 Swap readers are obtained through the ILSwapDataSource#reader method. When obtained this way, readers are stopped and have a nil delegate. When started using their #start method, readers will provide their delegate with a sequence of NSData objects in successive delegate calls (see the ILSwapReaderDelegate protocol for details), until either the data ends, an error is encountered, or the #stop method is called.
 
 Readers must be as memory-efficient as possible in their implementation.
 */
@protocol ILSwapReader <NSObject>

/**
 Starts the reader. The reader must not be running prior to calling this method, or the behavior may be undefined. It is also recommended that you set the delegate prior to calling this method.
 */
- (void) start;

/**
 Stops the reader if it's running. Calling this method while the reader isn't running is safe and has no effect. No delegate messages will be sent after this method is called (not even ILSwapReaderDelegate#readerDidEnd:).
 */
- (void) stop;

/**
 Returns whether the reader is running.
 */
@property(readonly, getter=isRunning) BOOL running;

/**
 The delegate for this reader.
 */
@property(nonatomic, assign) id <ILSwapReaderDelegate> delegate;

@end


/**
 A reader delegate will receive the data that a ILSwapReader produces.
 
 A reader will call methods in this protocol in the following manner:
 
 <ul>
 <li> #readerWillStart:, exactly once.
 <li> #reader:didReceiveData: multiple times, until the data is exhausted, and/or
 <li> #reader:didEncounterError: at most once, if an error is encountered;
 <li> #readerDidEnd:, exactly once.
 </ul>
 
 If ILSwapReader#stop is called, this sequence of calls will interrupt.
 
 */
@protocol ILSwapReaderDelegate <NSObject>

/**
 Provides data from a reader. This method will be provided multiple times.
 */
- (void) reader:(id <ILSwapReader>) r didReceiveData:(NSData*) d;

@optional
/**
 Called as the reader starts, before any of the other methods is called.
 */
- (void) readerWillStart:(id <ILSwapReader>) r;

/**
 Called as an error is detected during reading. This method will be called at most once, and immediately before #readerDidEnd:.
 */
- (void) reader:(id <ILSwapReader>) r didEncounterError:(NSError*) e;

/**
 Called as the reader ends, whether for an error or by having reached the end of the data.
 */
- (void) readerDidEnd:(id <ILSwapReader>) r;

@end


/**
 A file data source will produce reader objects that will provide the contents of the given file. You usually should not use this class directly; use ILSwapItem#initWithContentsOfFile:type:attributes or ILSwapMutableItem#setValueWithContentsOfFile: instead.
 */
@interface ILSwapFileDataSource : NSObject <ILSwapDataSource> {
	NSString* path;
}

/**
 Produces a new file data source for the existing file at the provided path.
 */
- (id) initWithContentsOfFile:(NSString*) f;

/**
 Produces a new file data source for the existing file at the provided path. (Convenience method for #initWithContentsOfFile:.)
 */
+ (id) dataSourceWithContentsOfFile:(NSString*) f;

@end

// ~ ~ ~

@interface ILSwapItem (ILSwapLargeItemSupport)

/**
 Produces a new "large item", that is, an item that is potentially larger than available RAM. The item will provide the receiving application the contents of the given file.
 */
- (id) initWithContentsOfFile:(NSString*) f type:(NSString*) type attributes:(NSDictionary*) attributes;

/**
 Convenience method for #initWithContentsOfFile:type:attributes:. See that method for details.
 */
+ (id) itemWithContentsOfFile:(NSString*) f type:(NSString*) type attributes:(NSDictionary*) attributes;

@end

@interface ILSwapMutableItem (ILSwapLargeItemSupport)

/**
 Changes the value of this item to a data source that will provide the receiving application with the contents of the given file. This will make this item a "large item"; see the documentation on sending potentially larger-than-RAM items for details.
 */
- (void) setValueWithContentsOfFile:(NSString*) f;

@end
