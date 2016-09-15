//
//  MFFile.h
//  Obsidian
//
//  Created by Michaël Fortin on 2013-04-12.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFPath.h"

@interface MFFile : MFPath

#pragma mark Creation

+ (instancetype)fileWithPath:(NSString *)path;
+ (instancetype)fileWithFileURL:(NSURL *)url;
+ (instancetype)fileForResource:(NSString *)resourceName withExtension:(NSString *)extension; // Returns a file pointing to a resource in the app bundle matching the specified name and extension.

#pragma mark Creating Other Instances

- (MFFile *)sibling:(NSString *)name; // Returns another file in the same parent directory as the current file.
- (MFFile *)siblingWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

#pragma mark Operations

- (MFFile *)create; // Creates the file if it doesn't exist.
- (MFFile *)copyTo:(MFPath *)destination; // Copies the file in a directory or to the specified file path.
- (MFFile *)copyTo:(MFPath *)destination overwrite:(BOOL)overwrite;
- (MFFile *)copyTo:(MFPath *)destination overwrite:(BOOL)overwrite error:(NSError **)error;
- (MFFile *)moveTo:(MFPath *)destination; // Moves the file in a directory or to the specified file path.
- (MFFile *)moveTo:(MFPath *)destination overwrite:(BOOL)overwrite;
- (MFFile *)moveTo:(MFPath *)destination overwrite:(BOOL)overwrite error:(NSError **)error;

#pragma mark Data Writing / Reading

- (NSData *)readData;
- (NSData *)readData:(NSError **)error;
- (BOOL)writeData:(NSData *)data;
- (BOOL)writeData:(NSData *)data overwrite:(BOOL)overwrite;
- (BOOL)writeData:(NSData *)data overwrite:(BOOL)overwrite error:(NSError **)error;
- (NSOutputStream *)outputStreamToAppend:(BOOL)append;

#pragma mark Keyed Archiving / Unarchiving

- (BOOL)archive:(id<NSCoding>)object; // Archives the the object in the file. The object must implement the NSCoding protocol.
- (BOOL)archive:(id<NSCoding>)object overwrite:(BOOL)overwrite;
- (BOOL)archive:(id<NSCoding>)object overwrite:(BOOL)overwrite error:(NSError **)error;
- (id)unarchive; // Unarchives the file into an instance of the object that was originally archived.
- (id)unarchive:(NSError **)error;

#pragma mark Keyed Archiving / Unarchiving (Plist)

- (BOOL)archiveAsXMLPlist:(id<NSCoding>)object; // Archives the the object in the file as an XML Plist file. The object must implement the NSCoding protocol.
- (BOOL)archiveAsXMLPlist:(id<NSCoding>)object overwrite:(BOOL)overwrite;
- (BOOL)archiveAsXMLPlist:(id<NSCoding>)object overwrite:(BOOL)overwrite error:(NSError **)error;
- (id)unarchiveFromXMLPlist; // Unarchives objects from the file, treating it as an XML Plist archive.
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