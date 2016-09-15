//
//  Files.h
//  Files
//
//  Created by Michaël Fortin on 2016-09-15.
//  Copyright © 2016 fortinmike. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for Files.
FOUNDATION_EXPORT double FilesVersionNumber;

//! Project version string for Files.
FOUNDATION_EXPORT const unsigned char FilesVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Files/PublicHeader.h>

#import "MFDirectory.h"
#import "MFFile.h"

#import "NSArray+MFPath.h"

#if TARGET_OS_IPHONE
    #import "MFDirectory+iOS.h"
    #import "MFFile+iOS.h"
#else
    #import "MFPath+OSX.h"
    #import "MFDirectory+OSX.h"
    #import "MFFile+OSX.h"
#endif
