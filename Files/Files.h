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

#import "Directory.h"
#import "File.h"

#import "NSArray+Path.h"

#if TARGET_OS_IPHONE
    #import "Directory+iOS.h"
    #import "File+iOS.h"
#else
    #import "Path+OSX.h"
    #import "Directory+OSX.h"
    #import "File+OSX.h"
#endif
