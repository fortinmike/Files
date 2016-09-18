//
//  Files.h
//  Files
//
//  Created by Michaël Fortin on 2016-09-15.
//  Copyright © 2016 irradiated.net. All rights reserved.
//

//! Project version number for Files.
FOUNDATION_EXPORT double FilesVersionNumber;

//! Project version string for Files.
FOUNDATION_EXPORT const unsigned char FilesVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Files/PublicHeader.h>

#import <Files/Directory.h>
#import <Files/File.h>

//#import "NSArray+Path.h"

#if TARGET_OS_IPHONE
    #import <Files/Directory+iOS.h>
    #import <Files/File+iOS.h>
#else
    #import <Files/Path+macOS.h>
    #import <Files/Directory+macOS.h>
    #import <Files/File+macOS.h>
#endif
