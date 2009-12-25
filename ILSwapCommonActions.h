//
//  ILSwapCommonActions.h
//  SwapKit
//
//  Created by ∞ on 25/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ILSwapService.h"

// Common actions to use with ILSwapService's -sendItems:ofType:forAction:.

// Share or store the item locally or remotely.
// For example: prepare for sending the item to another iPhone through an helper application (ahem); or for sending the item as an e-mail; or for storing on an online disk.
// An app implementing this action should, on item receipt, prominently show the item in its final location and/or open a compose screen with the item in it, ready for sharing (eg a new e-mail).
#define kILSwapSendToAction @"public.send-to"

