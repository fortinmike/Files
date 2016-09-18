//
//  NSObject+Directory_OSX.h
//  Obsidian
//
//  Created by Michaël Fortin on 10/29/2013.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Files.h"

@interface Directory (OSX)

#pragma mark System Directories

/**
 Returns an instance initialized with the filesystem's root directory ("/").
 */
+ (instancetype)root;

/**
 Returns the boot drive's Volumes directory ("/Volumes").
 */
+ (instancetype)volumes;

/**
 Returns an instance initialized with the current user's home directory.
 */
+ (instancetype)home;

/**
 Returns the user's Desktop directory.
 */
+ (instancetype)desktop;

/**
 Returns the user's Downloads directory.
 */
+ (instancetype)downloads;

/**
 Returns the user's Trash directory.
 */
+ (instancetype)trash;

/**
 Returns the user's Preferences directory ("~/Library/Preferences").
 */
+ (instancetype)userLevelPreferences;

/**
 Returns the system level Preferences directory ("/Library/Preferences").
 */
+ (instancetype)systemLevelPreferences;

/**
 Returns a directory whose name matches the currently running app's bundle identifier in the user-level Application Support directory.
 */
+ (instancetype)appSpecificApplicationSupport;

/**
 Returns the path of the user's Application Support directory ("~/Library/Application Support").
 */
+ (instancetype)userLevelApplicationSupport;

/**
 Returns the path of the system level Application Support directory ("~/Library/Application Support").
 */
+ (instancetype)systemLevelApplicationSupport;

/**
 Returns the directory of the currently running app's application bundle.
 */
+ (instancetype)appBundle;

/**
 Returns the currently running app's Resources directory (in the app's bundle).
 */
+ (instancetype)resources;

/**
 Returns the path of the Resources directory in the specified bundle.
 */
+ (instancetype)resourcesInBundle:(NSBundle *)bundle;

/**
 Returns the path of the Resources directory in the bundle corresponding to the specified class.
 */
+ (instancetype)resourcesInBundleForClass:(Class)class;

/**
 Returns the folder from which a sandboxed application can load scripts and run them outside of the sandbox's constraints.
 */
+ (instancetype)applicationScripts;

/**
 Returns a temporary directory specific to the currently running app (located in an appropriate system temporary directory).
 Always returns the same directory.
 */
+ (instancetype)temp;

#pragma mark On-Disk Inspection

/**
 Returns whether the directory is a bundle (also know as a package).
 */
- (BOOL)isBundle;

/**
 Returns whether the directory is an application bundle (.app).
 */
- (BOOL)isApplicationBundle;

/**
 Returns all files that conform to the specified UTI.
 */
- (NSArray<File *> *)filesConformingToType:(CFStringRef)type;

@end
