//
//  File.h
//  Obsidian
//
//  Created by Michaël Fortin on 2013-04-12.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Path.h"

@interface File : Path

#pragma mark Creation

+ (instancetype)fileWithPath:(NSString *)path;

+ (instancetype)fileWithFileURL:(NSURL *)url;

/**
 Returns a file pointing to a resource matching the specified name and extension in the app bundle.
 */
+ (instancetype)fileForResource:(NSString *)resourceName withExtension:(NSString *)extension;

#pragma mark Creating Other Instances

/**
 Returns another file in the same parent directory as the current file.
 */
- (File *)sibling:(NSString *)name;

- (File *)siblingWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

#pragma mark Operations

/**
 Creates a zero-length file if the file doesn't exist.
 */
- (File *)create;

/**
 Copies the file in a directory or to the specified file path.
 */
- (File *)copyTo:(Path *)destination;

/**
 Copies the file in a directory or to the specified file path, optionally overwriting any existing file.
 */
- (File *)copyTo:(Path *)destination overwrite:(BOOL)overwrite;

/**
 Copies the file in a directory or to the specified file path, optionally overwriting any existing file.
 */
- (File *)copyTo:(Path *)destination overwrite:(BOOL)overwrite error:(NSError **)error;


/**
 Moves the file in a directory or to the specified file path.
 */
- (File *)moveTo:(Path *)destination;

/**
 Moves the file in a directory or to the specified file path, optionally overwriting any existing file.
 */
- (File *)moveTo:(Path *)destination overwrite:(BOOL)overwrite;

/**
 Moves the file in a directory or to the specified file path, optionally overwriting any existing file.
 */
- (File *)moveTo:(Path *)destination overwrite:(BOOL)overwrite error:(NSError **)error;

#pragma mark Data Writing / Reading

- (NSData *)readData;

- (NSData *)readData:(NSError **)error;

- (BOOL)writeData:(NSData *)data;

- (BOOL)writeData:(NSData *)data overwrite:(BOOL)overwrite;

- (BOOL)writeData:(NSData *)data overwrite:(BOOL)overwrite error:(NSError **)error;

- (NSOutputStream *)outputStreamToAppend:(BOOL)append;

#pragma mark Keyed Archiving / Unarchiving

/**
 Archives the the object in the file. The object must implement the NSCoding protocol.
 */
- (BOOL)archive:(id<NSCoding>)object;

/**
 Archives the the object in the file, optionally overwriting any existing file.
 The object must implement the NSCoding protocol.
 */
- (BOOL)archive:(id<NSCoding>)object overwrite:(BOOL)overwrite;

/**
 Archives the the object in the file, optionally overwriting any existing file.
 The object must implement the NSCoding protocol.
 */
- (BOOL)archive:(id<NSCoding>)object overwrite:(BOOL)overwrite error:(NSError **)error;

/**
 Unarchives the file into an instance of the object that was originally archived.
 */
- (id)unarchive;

/**
 Unarchives the file into an instance of the object that was originally archived.
 */
- (id)unarchive:(NSError **)error;

#pragma mark Keyed Archiving / Unarchiving (Plist)

/**
 Archives the the object in the file as an XML Plist file. The object must implement the NSCoding protocol.
 */
- (BOOL)archiveAsXMLPlist:(id<NSCoding>)object;

/**
 Archives the the object in the file as an XML Plist file, optionally overwriting any existing file.
 The object must implement the NSCoding protocol.
 */
- (BOOL)archiveAsXMLPlist:(id<NSCoding>)object overwrite:(BOOL)overwrite;

/**
 Archives the the object in the file as an XML Plist file, optionally overwriting any existing file.
 The object must implement the NSCoding protocol.
 */
- (BOOL)archiveAsXMLPlist:(id<NSCoding>)object overwrite:(BOOL)overwrite error:(NSError **)error;

/**
 Unarchives the file into an instance of the object that was originally archived, treating the file as an XML Plist.
 */
- (id)unarchiveFromXMLPlist;

/**
 Unarchives the file into an instance of the object that was originally archived, treating the file as an XML Plist.
 */
- (id)unarchiveFromXMLPlist:(NSError **)error;

#pragma mark Reading Specific Types

- (NSString *)readString;

- (NSString *)readStringWithEncoding:(NSStringEncoding)encoding;

#pragma mark Reading/Writing Arrays

- (NSArray *)readArray;

- (BOOL)writeArray:(NSArray *)array;

- (BOOL)writeArray:(NSArray *)array overwrite:(BOOL)overwrite;

#pragma mark Reading/Writing Dictionaries

- (NSDictionary *)readDictionary;

- (BOOL)writeDictionary:(NSDictionary *)dictionary;

- (BOOL)writeDictionary:(NSDictionary *)dictionary overwrite:(BOOL)overwrite;

@end
