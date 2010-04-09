//
//  ILSwapLargeItemSupport.m
//  SwapKit
//
//  Created by ∞ on 01/03/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import "ILSwapLargeItemSupport.h"

@interface ILSwapFileReader : NSObject <ILSwapReader
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
, NSStreamDelegate
#endif
> {
	NSString* path;
	NSInputStream* stream;
	id <ILSwapReaderDelegate> delegate;
	
	uint8_t* buffer;
	NSUInteger bufferLength;
}

- (id) initWithPath:(NSString*) path;

@end


@implementation ILSwapFileDataSource

- (id) initWithContentsOfFile:(NSString*) f;
{
	if (self = [super init]) {
		path = [f copy];
	}
	
	return self;
}

- (void) dealloc
{
	[path release];
	[super dealloc];
}

+ (id) dataSourceWithContentsOfFile:(NSString*) f;
{
	return [[[self alloc] initWithContentsOfFile:f] autorelease];
}


- (id <ILSwapReader>) reader;
{
	return [[[ILSwapFileReader alloc] initWithPath:path] autorelease];
}

@end

@implementation ILSwapFileReader

- (id) initWithPath:(NSString*) f;
{
	if (self = [super init]) {
		path = [f copy];
		bufferLength = 500 * 1024; // 500KB
	}
		
	return self;
}

- (void) dealloc
{
	[self stop];
	[path release];
	[super dealloc];
}


@synthesize delegate;

- (BOOL) running;
{
	return stream != nil;
}

- (void) start;
{
	NSAssert(!stream, @"Can't call -start on a running reader!");
	NSAssert(!buffer, @"Bug: we have a stray buffer (a leak?)");
	
	buffer = malloc(bufferLength);

	stream = [[NSInputStream inputStreamWithFileAtPath:path] retain];
	[stream setDelegate:self];
	[stream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[stream open];
}

- (void) stop;
{
	if (stream) {
		[stream setDelegate:nil];
		[stream release]; stream = nil;
		
		if ([delegate respondsToSelector:@selector(readerDidEnd:)])
			[delegate readerDidEnd:self];
	}
	
	if (buffer) {
		free(buffer);
		buffer = NULL;
	}
}

- (void) stream:(NSStream*) aStream handleEvent:(NSStreamEvent) eventCode;
{
	switch (eventCode) {
		case NSStreamEventOpenCompleted:
		case NSStreamEventHasBytesAvailable: {
			
			uint8_t* data; NSUInteger length;
			if (![stream getBuffer:&data length:&length]) {
				
				data = buffer;
				length = [stream read:buffer maxLength:bufferLength];
				
			}
			
			NSData* d = [NSData dataWithBytes:data length:length];
			
			[delegate reader:self didReceiveData:d];
			
		}
			break;
			
		case NSStreamEventErrorOccurred: {
			[[stream retain] autorelease]; // to keep the stream valid throughout the -stop.
			
			if ([delegate respondsToSelector:@selector(reader:didEncounterError:)])
				[delegate reader:self didEncounterError:[stream streamError]];
			
			[self stop];
		}
			break;

		case NSStreamEventEndEncountered: {
			[[stream retain] autorelease]; // to keep the stream valid throughout the -stop.
			[self stop];
		}
			break;
			
			
		default:
			break;
	}
}

@end


// ~ ~ ~

@implementation ILSwapItem (ILSwapLargeItemSupport)

- (id) initWithContentsOfFile:(NSString*) f type:(NSString*) t attributes:(NSDictionary*) a;
{
	return [self initWithValue:[ILSwapFileDataSource dataSourceWithContentsOfFile:f] type:t attributes:a];
}

+ (id) itemWithContentsOfFile:(NSString*) f type:(NSString*) t attributes:(NSDictionary*) a;
{
	return [[[self alloc] initWithContentsOfFile:f type:t attributes:a] autorelease];
}

@end

@implementation ILSwapMutableItem (ILSwapLargeItemSupport)

- (void) setValueWithContentsOfFile:(NSString*) f;
{
	self.value = [ILSwapFileDataSource dataSourceWithContentsOfFile:f];
}

@end
