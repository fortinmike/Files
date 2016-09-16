//
//  Path.m
//  Obsidian
//
//  Created by Michaël Fortin on 2013-04-12.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import "Path.h"
#import "Directory.h"
#import "NSError+FilesAdditions.h"
#import "NSException+FilesAdditions.h"

@implementation Path
{
	NSString *_path;
}

#pragma mark Lifetime

- (id)initWithPath:(NSString *)path
{
	self = [super init];
	if (self)
	{
		if (path == nil || [self candidateHasInvalidPrefix:path] || [self candidateContainsSuccessiveSlashes:path])
		{
			NSString *reason = [NSString stringWithFormat:@"The provided path is invalid: %@", path];
			@throw [NSException exceptionWithReason:@"%@", reason];
		}
		
		_path = [path copy];
	}
	return self;
}

#pragma mark Private Validation

- (BOOL)candidateHasInvalidPrefix:(NSString *)candidatePath
{
    return !([candidatePath hasPrefix:@"/"] || [candidatePath hasPrefix:@"~/"]) && ![candidatePath isEqualToString:@"~"];
}

// TODO: Needs testing!
- (BOOL)candidateContainsSuccessiveSlashes:(NSString *)candidatePath
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/{2,}" options:NSRegularExpressionCaseInsensitive error:nil];
    return [regex matchesInString:candidatePath options:0 range:NSMakeRange(0, [candidatePath length])] > 0;
}

#pragma mark Equality

// See: http://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html

#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))
- (BOOL)isEqual:(id)otherObject
{
	if (![otherObject isKindOfClass:[self class]]) return NO;
	return [[self absolutePath] isEqual:[otherObject absolutePath]];
}

- (NSUInteger)hash
{
	return NSUINTROTATE([[self absolutePath] hash], NSUINT_BIT / 2) ^ [[self class] hash];
}

#pragma mark Description

- (NSString *)description
{
	return [self absolutePath];
}

#pragma mark Information

- (NSString *)path
{
	return [_path stringByAbbreviatingWithTildeInPath];
}

- (NSString *)absolutePath
{
	return [_path stringByStandardizingPath];
}

- (NSArray *)pathComponents
{
	return [[self path] pathComponents];
}

- (NSArray *)absolutePathComponents
{
	return [[self absolutePath] pathComponents];
}

// COV_NF_START
- (NSURL *)fileURL
{
	// File URL must be created in subclasses to specify if pointing to a directory or not.
	// https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSURL_Class/Reference/Reference.html
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}
// COV_NF_END

- (NSString *)name
{
	return [_path lastPathComponent];
}

- (NSString *)nameWithoutExtension
{
	return [[_path lastPathComponent] stringByDeletingPathExtension];
}

- (NSString *)extension
{
	NSString *extension = [_path pathExtension];
	return ([extension isEqualToString:@""] ? nil : extension);
}

#pragma mark On-Disk Inspection

// COV_NF_START
- (BOOL)exists
{
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}
// COV_NF_END

- (BOOL)itemExists
{
	return [[NSFileManager defaultManager] fileExistsAtPath:[self absolutePath]];
}

- (BOOL)isDirectory
{
	NSFileManager *manager = [NSFileManager defaultManager];
	
	BOOL isDirectory;
	BOOL fileExists = [manager fileExistsAtPath:[self absolutePath] isDirectory:&isDirectory];
	
	return (fileExists && isDirectory);
}

- (BOOL)isFile
{
	NSFileManager *manager = [NSFileManager defaultManager];
	
	BOOL isDirectory;
	BOOL fileExists = [manager fileExistsAtPath:[self absolutePath] isDirectory:&isDirectory];
	
	return (fileExists && !isDirectory);
}

#pragma mark Item Attributes

// See this page for information on available keys:
// http://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSFileManager_Class/Reference/Reference.html#//apple_ref/doc/constant_group/File_Attribute_Keys

- (NSDictionary *)attributes
{
	NSFileManager *manager = [NSFileManager defaultManager];
	
	NSError *error;
	NSDictionary *attributes = [manager attributesOfItemAtPath:[self absolutePath] error:&error];
	
	if (error)
	{
		NSLog(@"Could not obtain item attributes for path %@. Error: %@", [self path], error);
		return nil;
	}
	
	return attributes;
}

- (unsigned long long)size
{
	return [[self tryObtainAttribute:NSFileSize] unsignedLongLongValue];
}

- (NSDate *)creationDate
{
	return [self tryObtainAttribute:NSFileCreationDate];
}

- (NSDate *)modificationDate
{
	return [self tryObtainAttribute:NSFileModificationDate];
}

- (id)tryObtainAttribute:(NSString *)fileAttributeKey
{
	NSNumber *attribute = [self attributes][fileAttributeKey];
	
	if (!attribute)
	{
		NSLog(@"Could not obtain file attribute %@ for item at path %@", fileAttributeKey, [self path]);
		return nil;
	}
	
	return attribute;
}

- (void)setExcludeFromBackup:(BOOL)exclude
{
	NSError *error;
	[[self fileURL] setResourceValue:@(exclude) forKey:NSURLIsExcludedFromBackupKey error:&error];
	
	if (error) NSLog(@"Could not exclude %@ from backup. Error: %@", [self path], error);
}

#pragma mark File System Attributes

// See this page for information on available keys:
// https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSFileManager_Class/Reference/Reference.html#//apple_ref/doc/constant_group/File_System_Attribute_Keys

- (NSDictionary *)fileSystemAttributes
{
	NSFileManager *manager = [NSFileManager defaultManager];
	
	NSError *error;
	NSDictionary *attributes = [manager attributesOfFileSystemForPath:[self absolutePath] error:&error];
	
	if (error)
	{
		NSLog(@"Could not obtain file system attributes for path %@", [self path]);
		return nil;
	}
	
	return attributes;
}

- (unsigned long long)fileSystemSize
{
	return [[self tryObtainFileSystemAttribute:NSFileSystemSize] unsignedLongLongValue];
}

- (unsigned long long)fileSystemFreeSize
{
	return [[self tryObtainFileSystemAttribute:NSFileSystemFreeSize] unsignedLongLongValue];
}

- (id)tryObtainFileSystemAttribute:(NSString *)fileSystemAttributeKey
{
	NSNumber *attribute = [self fileSystemAttributes][fileSystemAttributeKey];
	
	if (!attribute)
	{
		NSLog(@"Could not obtain file system attribute %@ for item at path %@", fileSystemAttributeKey, [self path]);
		return nil;
	}
	
	return attribute;
}

#pragma mark Creating Other Instances

- (Directory *)parent
{
	if ([[self absolutePath] isEqualToString:@"/"]) return nil;
	
	return [Directory directoryWithPath:[[self absolutePath] stringByDeletingLastPathComponent]];
}

- (Path *)subitem:(NSString *)name
{
	NSString *path = [[self absolutePath] stringByAppendingPathComponent:name];
	return [[Path alloc] initWithPath:path]; // Can return instances of subclasses!
}

- (Path *)subitemWithNumberSuffixIfExists:(NSString *)name
{
	Path *candidatePath = [self subitem:name];
	
	if (![candidatePath itemExists])
		return candidatePath;
	
	NSString *basename = [candidatePath nameWithoutExtension];
	NSString *extension = [candidatePath extension];
	
	Path *suffixedPath;
	NSUInteger suffixIndex = 1;
	do
	{
		NSString *extensionWithDot = extension ? [@"." stringByAppendingString:extension] : @"";
		NSString *suffixedFileNameString = [NSString stringWithFormat:@"%@%@%@", basename, @(suffixIndex), extensionWithDot];
		suffixedPath = [[Path alloc] initWithPath:[[self subitem:suffixedFileNameString] absolutePath]];
		suffixIndex++;
	}
	while ([suffixedPath itemExists]);
	
	return suffixedPath;
}

#pragma mark Operations

- (BOOL)delete
{
	return [self deleteAndSilenceLogging:NO];
}

- (BOOL)deleteAndSilenceLogging:(BOOL)silenceLogging
{
	BOOL itemExists = [[NSFileManager defaultManager] fileExistsAtPath:[self absolutePath]];
	if (!itemExists) return YES;
	
	NSError *error = nil;
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL success = [manager removeItemAtPath:[self absolutePath] error:&error];
	
	if (error) NSLog(@"%@", error);
	
	return success && !error;
}

// Overriden with more concrete parameter and return types
- (Path *)copyTo:(Path *)destination overwrite:(BOOL)overwrite error:(NSError **)error
{
	NSFileManager *manager = [NSFileManager defaultManager];
	
	if (overwrite)
	{
		BOOL deleted = [destination deleteAndSilenceLogging:YES];
		if (!deleted)
		{
			NSString *description = [NSString stringWithFormat:@"Could not delete item at path %@", [destination absolutePath]];
			NSLog(@"%@", description);
			if (error) *error = [NSError errorWithDescription:@"%@", description];
			return nil;
		}
	}
	
	Directory *parent = [destination parent];
	if ([parent create] == nil)
	{
		NSString *description = [NSString stringWithFormat:@"Could not create parent directory %@", [parent absolutePath]];
		NSLog(@"%@", description);
		if (error) *error = [NSError errorWithDescription:@"%@", description];
		return nil;
	}
	
	NSError *innerError = nil;
	[manager copyItemAtPath:[self absolutePath] toPath:[destination absolutePath] error:&innerError];
	
	if (innerError)
	{
		NSLog(@"%@", [innerError description]);
		if (error) *error = innerError;
		return nil;
	}
	
	return [[Path alloc] initWithPath:[destination absolutePath]];
}

- (Path *)createSymlinkAtPath:(Path *)path
{
	return [self createSymlinkAtPath:path error:nil];
}

- (Path *)createSymlinkAtPath:(Path *)path error:(NSError **)error
{
	NSFileManager *manager = [NSFileManager defaultManager];
	
	[manager createSymbolicLinkAtURL:[path fileURL] withDestinationURL:[self fileURL] error:error];
	
	return !error ? [[[self class] alloc] initWithPath:[path absolutePath]] : nil;
}

- (Path *)createHardLinkAtPath:(Path *)path
{
	return [self createHardLinkAtPath:path error:nil];
}

- (Path *)createHardLinkAtPath:(Path *)path error:(NSError **)error
{
	NSFileManager *manager = [NSFileManager defaultManager];
	
	[manager linkItemAtURL:[self fileURL] toURL:[path fileURL] error:error];
	
	return !error ? [[[self class] alloc] initWithPath:[path absolutePath]] : nil;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	return [[[self class] alloc] initWithPath:_path];
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:_path forKey:@"path"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	return [self initWithPath:[decoder decodeObjectForKey:@"path"]];
}

@end
