//
//  MFPath.h
//  Obsidian
//
//  Created by Michaël Fortin on 2013-04-12.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//
//  Description: An abstract class to represent a file system item.
//               Implements some file and directory common behavior.
//

#import <Foundation/Foundation.h>

@class MFDirectory;
@class MFFile;

@interface MFPath : NSObject<NSCopying, NSCoding>

#pragma mark Lifetime

- (id)initWithPath:(NSString *)path;

#pragma mark Information

- (NSString *)path; // Returns the full path (with a tilde, where appropriate, representing the user's home folder).
- (NSString *)absolutePath; // Returns the absolute path (fully expanded).
- (NSArray *)pathComponents; // Returns an array of NSStrings containing all of the path components.
- (NSArray *)absolutePathComponents; // Returns an array of NSStrings containing all of the absolute path's components.
- (NSURL *)fileURL; // Returns a fully qualified file URL for the item (file URLs are prefixed with file:// and can point to a directory as well as a file).
- (NSString *)name; // Returns the last path component (either the file name including its extension or the directory name with its extension if a package).
- (NSString *)nameWithoutExtension; // Returns the file or directory/package name excluding its extension.
- (NSString *)extension; // Returns the file or package extension. Returns nil if the file has no extension or the directory isn't a package.

#pragma mark On-Disk Inspection

- (BOOL)exists; // Checks whether the path exists on disk and corresponds to the appropriate MFPath subclass.
- (BOOL)itemExists; // Checks whether the path exists on disk (disregarding whether the path is a directory or a file)
- (BOOL)isDirectory; // Checks whether the path is a directory on disk.
- (BOOL)isFile; // Checks whether the path is a file on disk.

#pragma mark Item Attributes

- (NSDictionary *)attributes; // Returns a dictionary containing file or directory attributes as returned from NSFileManager.
- (unsigned long long)size; // Returns the size of the item on disk (file or directory contents).
- (NSDate *)creationDate;
- (NSDate *)modificationDate;
- (void)setExcludeFromBackup:(BOOL)exclude; // Excludes the path from the iOS backup process (iTunes or iCloud).

#pragma mark File System Attributes

- (NSDictionary *)fileSystemAttributes; // Returns a dictionary containing the file system attributes of the mounted volume on which the path resides.
- (unsigned long long)fileSystemSize; // Returns the total size of the mounted volume on which the path resides.
- (unsigned long long)fileSystemFreeSize; // Returns the total free size in the mounted volume on which the path resides.

#pragma mark Creating Other Instances

- (MFDirectory *)parent; // Returns the parent directory.
- (MFPath *)subitem:(NSString *)name; // Returns a subitem of the current path with the same concrete type as the object on which the method is called.
- (MFPath *)subitemWithNumberSuffixIfExists:(NSString *)name; // Same but with a number suffix if the file already exists.

#pragma mark Operations

- (BOOL)delete;
- (BOOL)deleteAndSilenceLogging:(BOOL)silenceLogging;
- (MFPath *)copyTo:(MFPath *)destination overwrite:(BOOL)overwrite error:(NSError **)error;
- (MFPath *)createSymlinkAtPath:(MFPath *)path;
- (MFPath *)createSymlinkAtPath:(MFPath *)path error:(NSError **)error;
- (MFPath *)createHardLinkAtPath:(MFPath *)path;
- (MFPath *)createHardLinkAtPath:(MFPath *)path error:(NSError **)error;

@end