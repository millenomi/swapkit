//
//  ILSwapCommonActions.m
//  SwapKit
//
//  Created by ∞ on 25/12/09.

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


#import "ILSwapCommonActions.h"

/**
 \addtogroup ILSwapKitCommonActions Common Actions
 */

/**
 \ingroup ILSwapKitCommonActions
This action is intended to be used by data transfer and messaging programs that can receive attachments. It instructs the application to create a new message or discrete upload, or otherwise prepare the item or items to be sent to a third party.

 Mover uses to this action to mean "Add to the table".

Example of use:

 <code>
 UIImage* i = <# An image. #>;
 NSData* d = UIImagePNGRepresentation(i);
 
 ILSwapSendController* ctl = [ILSwapSendController
	controllerForSendingItems:[NSArray arrayWithObject:d]
	ofType:(id) kUTTypePNG
	forAction:kILSwapPrepareForTransferAction];
 
 [ctl send];
 </code>
 
 */
#define kILSwapPrepareForTransferAction @"ILPrepareForTransfer"
