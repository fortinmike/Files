//
//  MFDirectory.h
//  Obsidian
//
//  Created by Michaël Fortin on 2013-04-12.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFPath.h"

@interface MFDirectory : MFPath

#pragma mark Creation

+ (instancetype)directoryWithPath:(NSString *)path;
+ (instancetype)directoryWithFileURL:(NSURL *)url;

#pragma mark On-Disk Inspection

- (BOOL)isEmpty; // Returns whether the directory is empty or not.
- (NSArray *)items; // Returns an array containing instances of MFFile and MFDirectory representing all of the items in the directory.
- (NSArray *)files; // Returns an array of MFFile objects, one for each file in the directory.
- (NSArray *)filesWithExtension:(NSString *)extension; // Returns only files with the specified extension.
- (NSArray *)subdirectories; // Returns an array of MFDirectory objects, one for each directory in the directory.

#pragma mark Creating Other Directories

- (MFDirectory *)subdirectory:(NSString *)name;
- (MFDirectory *)subdirectoryWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (MFDirectory *)subdirectoryWithNumberSuffixIfExists:(NSString *)name;

#pragma mark Creating Files

- (MFFile *)file:(NSString *)name;
- (MFFile *)fileWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (MFFile *)fileWithName:(NSString *)name extension:(NSString *)extension;
- (MFFile *)fileWithNumberSuffixIfExists:(NSString *)name;

#pragma mark Operations

- (BOOL)deleteContents;
- (MFDirectory *)create; // Creates the directory if it does not exist.
- (MFDirectory *)createAndSilenceLogging:(BOOL)silenceLogging;
- (MFDirectory *)copyContentsTo:(MFDirectory *)destination; // Copies the contents of the directory in another directory.
- (MFDirectory *)copyContentsTo:(MFDirectory *)destination overwrite:(BOOL)overwrite;
- (MFDirectory *)copyTo:(MFDirectory *)destination; // Copies the directory in another directory.
- (MFDirectory *)copyTo:(MFDirectory *)destination overwrite:(BOOL)overwrite;
- (MFDirectory *)copyTo:(MFPath *)destination overwrite:(BOOL)overwrite error:(NSError **)error;
- (MFDirectory *)moveTo:(MFDirectory *)destination; // Moves the directory in another directory.
- (MFDirectory *)moveTo:(MFDirectory *)destination overwrite:(BOOL)overwrite;
- (MFDirectory *)moveTo:(MFDirectory *)destination overwrite:(BOOL)overwrite error:(NSError **)error;

@end