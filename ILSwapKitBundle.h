//
//  ILSwapKitBundle.h
//  SwapKit
//
//  Created by ∞ on 19/01/10.
//  Copyright 2010 Emanuele Vulcano (Infinite Labs). All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 \addtogroup ILSwapKitBundleManagement Bundle Management
 */

/**
 \ingroup ILSwapKitBundleManagement
 Returns the SwapKit bundle. This bundle is the SwapKit.framework from a binary distribution, or the SwapKit.bundle from a source build, or otherwise a bundle that contains all resources that SwapKit needs to function.
 
 If the bundle is not explictly set using ILSwapKitSetBundle(), it will be searched in the Resources directory of the main bundle (but not in any localized subdirectory), in this order:
 
- resources directory/SwapKit.framework
- resources directory/SwapKit.bundle
 
 If not set explicitly or not found, behavior is undefined (currently, a guard is tripped causing an error message and optionally an exception; but this may change in the future). Note that other parts of SwapKit rely on this function, so you MUST embed the bundle as specified above (or set where to find the resources via ILSwapKitSetBundle()).
 */
extern NSBundle* ILSwapKitBundle();

/**
 \ingroup ILSwapKitBundleManagement
 
 Sets the SwapKit bundle. For more information on the bundle, see ILSwapKitBundle(). You must use this function if you place SwapKit's resources in a bundle other than one searched by ILSwapKitBundle() by default.
 
 @param bundle The bundle that will be searched for SwapKit resources. Can be <code>nil</code>; if so, the next invocation of ILSwapKitBundle() will repeat its default search.
 */
extern void ILSwapKitSetBundle(NSBundle* bundle);
