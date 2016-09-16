//
//  Directory.h
//  Obsidian
//
//  Created by Michaël Fortin on 2013-04-12.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Path.h"

@interface Directory : Path

#pragma mark Creation

+ (instancetype)directoryWithPath:(NSString *)path;
+ (instancetype)directoryWithFileURL:(NSURL *)url;

#pragma mark On-Disk Inspection

- (BOOL)isEmpty; // Returns whether the directory is empty or not.
- (NSArray *)items; // Returns an array containing instances of File and Directory representing all of the items in the directory.
- (NSArray *)files; // Returns an array of File objects, one for each file in the directory.
- (NSArray *)filesWithExtension:(NSString *)extension; // Returns only files with the specified extension.
- (NSArray *)subdirectories; // Returns an array of Directory objects, one for each directory in the directory.

#pragma mark Creating Other Directories

- (Directory *)subdirectory:(NSString *)name;
- (Directory *)subdirectoryWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (Directory *)subdirectoryWithNumberSuffixIfExists:(NSString *)name;

#pragma mark Creating Files

- (File *)file:(NSString *)name;
- (File *)fileWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (File *)fileWithName:(NSString *)name extension:(NSString *)extension;
- (File *)fileWithNumberSuffixIfExists:(NSString *)name;

#pragma mark Operations

- (BOOL)deleteContents;
- (Directory *)create; // Creates the directory if it does not exist.
- (Directory *)copyContentsTo:(Directory *)destination; // Copies the contents of the directory in another directory.
- (Directory *)copyContentsTo:(Directory *)destination overwrite:(BOOL)overwrite;
- (Directory *)copyTo:(Directory *)destination; // Copies the directory in another directory.
- (Directory *)copyTo:(Directory *)destination overwrite:(BOOL)overwrite;
- (Directory *)copyTo:(Path *)destination overwrite:(BOOL)overwrite error:(NSError **)error;
- (Directory *)moveTo:(Directory *)destination; // Moves the directory in another directory.
- (Directory *)moveTo:(Directory *)destination overwrite:(BOOL)overwrite;
- (Directory *)moveTo:(Directory *)destination overwrite:(BOOL)overwrite error:(NSError **)error;

@end
