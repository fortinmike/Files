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

+ (instancetype)root; // Returns an instance initialized with the filesystem's root directory ("/").
+ (instancetype)volumes; // Returns the boot drive's Volumes directory ("/Volumes")
+ (instancetype)home; // Returns an instance initialized with the current user's home directory.
+ (instancetype)desktop; // Returns the user's Desktop directory.
+ (instancetype)downloads; // Returns the user's Downloads directory.
+ (instancetype)trash; // Returns the user's Trash directory.
+ (instancetype)userLevelPreferences; // Returns the user's Preferences directory ("~/Library/Preferences").
+ (instancetype)systemLevelPreferences; // Returns the system level Preferences directory ("/Library/Preferences").
+ (instancetype)appSpecificApplicationSupport; // Returns a directory whose name matches the currently running app's bundle identifier in the user-level Application Support directory.
+ (instancetype)userLevelApplicationSupport; // Returns the path of the user's Application Support directory ("~/Library/Application Support").
+ (instancetype)systemLevelApplicationSupport; // Returns the path of the system level Application Support directory ("~/Library/Application Support").
+ (instancetype)appBundle; // Returns the directory of the currently running app's application bundle.
+ (instancetype)resources; // Returns the currently running app's Resources directory (in the app's bundle).
+ (instancetype)resourcesInBundle:(NSBundle *)bundle; // Returns the path of the Resources directory in the specified bundle.
+ (instancetype)resourcesInBundleForClass:(Class)class; // Returns the path of the Resources directory in the bundle corresponding to the specified class.
+ (instancetype)applicationScripts; // Returns the folder from which a sandboxed application can load scripts and run them outside of the sandbox's constraints.
+ (instancetype)temp; // Returns a temporary directory specific to the currently running app. Always returns the same directory.

#pragma mark On-Disk Inspection

- (BOOL)isBundle; // Returns whether the directory is a bundle (also know as a package).
- (BOOL)isApplicationBundle; // Returns whether the directory is an application bundle (.app).
- (NSArray<File *> *)filesConformingToType:(CFStringRef)type; // Returns all files that conform to the specified UTI.

@end
