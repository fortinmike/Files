//
//  Path.h
//  Obsidian
//
//  Created by Michaël Fortin on 2013-04-12.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//
//  Description: An abstract class to represent a file system item.
//               Implements some file and directory common behavior.
//

#import <Foundation/Foundation.h>

@class Directory;
@class File;

@interface Path : NSObject<NSCopying, NSCoding>

#pragma mark Lifetime

- (id)initWithPath:(NSString *)path;

#pragma mark Information

/**
 Returns the full path, relative to the user's home directory (~) if applicable.
 */
- (NSString *)path;

/**
 Returns the absolute path (fully expanded).
 */
- (NSString *)absolutePath;

/**
 Returns an array of NSStrings containing all of the path components.
 */
- (NSArray<NSString *> *)pathComponents;

/**
 Returns an array of NSStrings containing all of the absolute path's components.
 */
- (NSArray<NSString *> *)absolutePathComponents;

/**
 Returns a fully qualified file URL for the item (file URLs are prefixed with file:// and can point to a directory as well as a file).
 */
- (NSURL *)fileURL;

/**
 Returns the last path component (either the file name including its extension or the directory name with its extension if a package).
 */
- (NSString *)name;

/**
 Returns the file or directory/package name excluding its extension.
 */
- (NSString *)nameWithoutExtension;

/**
 Returns the file or package extension. Returns nil if the file has no extension or the directory isn't a package.
 */
- (NSString *)extension;

#pragma mark On-Disk Inspection

/**
 Checks whether the path exists on disk and corresponds to the appropriate Path subclass.
 */
- (BOOL)exists;

/**
 Checks whether the path exists on disk (disregarding whether the path is a directory or a file).
 */
- (BOOL)itemExists;

/**
 Checks whether the path is a directory on disk.
 */
- (BOOL)isDirectory;

/**
 Checks whether the path is a file on disk.
 */
- (BOOL)isFile;

#pragma mark Item Attributes

/**
 Returns a dictionary containing file or directory attributes as returned from NSFileManager.
 */
- (NSDictionary *)attributes;

/**
 Returns the size of the item on disk (file or directory contents).
 */
- (unsigned long long)size;

    
/**
 The item's creation date.
 */
- (NSDate *)creationDate;

/**
 The item's last modification date.
 */
- (NSDate *)modificationDate;

/**
 Excludes the path from the iOS backup process (iTunes or iCloud).
 */
- (void)setExcludeFromBackup:(BOOL)exclude;

#pragma mark File System Attributes

/**
 Returns a dictionary containing the file system attributes of the mounted volume on which the path resides.
 */
- (NSDictionary *)fileSystemAttributes;

/**
 Returns the total size of the volume on which the item resides.
 */
- (unsigned long long)fileSystemSize;

/**
 Returns the total free size in the volume on which the path resides.
 */
- (unsigned long long)fileSystemFreeSize;

#pragma mark Creating Other Instances

/**
 Returns the parent directory.
 */
- (Directory *)parent;

/**
 Returns a subitem of the current path with the same concrete type as the object on which the method is called.
 */
- (Path *)subitem:(NSString *)name;

/**
 Returns a subitem of the current path with the same concrete type as the object on which the method is called.
 Adds a numeric suffix if there is already something on disk with that name.
 */
- (Path *)subitemWithNumericSuffixIfExists:(NSString *)name;

#pragma mark Operations

- (BOOL)delete;
- (Path *)copyTo:(Path *)destination overwrite:(BOOL)overwrite error:(NSError **)error;
- (Path *)createSymlinkAtPath:(Path *)path;
- (Path *)createSymlinkAtPath:(Path *)path error:(NSError **)error;
- (Path *)createHardLinkAtPath:(Path *)path;
- (Path *)createHardLinkAtPath:(Path *)path error:(NSError **)error;

@end
