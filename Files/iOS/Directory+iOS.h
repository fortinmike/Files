//
//  Directory+iOS.h
//  Obsidian
//
//  Created by Michaël Fortin on 11/23/2013.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import "Directory.h"

@interface Directory (iOS)

#pragma mark System Directories

/**
 Returns the directory of the currently running app's application bundle.
 */
+ (instancetype)appBundle;

/**
 Returns the Library directory in the app's sandbox.
 */
+ (instancetype)library;

/**
 Returns the "Library/Application Support" directory in the app's sandbox.
 */
+ (instancetype)applicationSupport;

/**
 Returns the "Library/Caches" directory in the app's sandbox.
 */
+ (instancetype)caches;

/**
 Returns the Documents directory in the app's sandbox.
 */
+ (instancetype)documents;

/**
 Returns the currently running app's Resources directory (in the app's bundle).
 */
+ (instancetype)resources;

/**
 Returns the path of the Resources directory in the specified bundle.
 */
+ (instancetype)resourcesInBundle:(NSBundle *)bundle;

/**
 Returns a temporary directory specific to the currently running app. Always returns the same directory.
 */
+ (instancetype)temp;

@end
