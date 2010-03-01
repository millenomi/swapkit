//
//  ILSwapSendOperation.h
//  SwapKit
//
//  Created by ∞ on 01/03/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "L0Map.h"

enum {
	kILSwapSendDone,
	kILSwapSendOngoing,
	kILSwapSendError
};
typedef NSInteger ILSwapSendResult;

#define kILSwapFragmentPasteboardType @"net.infinite-labs.SwapKit.Fragment"
#define kILSwapFragmentListPasteboardType @"net.infinite-labs.SwapKit.FragmentList"


@interface ILSwapPasteboardSender : NSObject {
	NSArray* items;
	NSString* action;
	NSString* appID;
	
	NSDictionary* registration;
	
	NSArray* pasteboardItems;
	
	NSInteger finishedReaders;
	NSSet* readers;
	L0Map* buffersByReader;
	L0Map* pasteboardListsByReader;
	L0Map* attributesByReader;
}

- (id) initWithItems:(NSArray*) i action:(NSString*) a applicationIdentifier:(NSString*) ai;

- (ILSwapSendResult) send;

@end
