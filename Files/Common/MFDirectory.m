//
//  MFDirectory.m
//  Obsidian
//
//  Created by Michaël Fortin on 2013-04-12.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import "MFDirectory.h"
#import "MFFile.h"
#import "NSError+FilesAdditions.h"
#import "NSException+FilesAdditions.h"

@implementation MFDirectory

#pragma mark Creation

+ (instancetype)directoryWithPath:(NSString *)path
{
	return [[self alloc] initWithPath:path];
}

+ (instancetype)directoryWithFileURL:(NSURL *)url
{
	return [self directoryWithPath:[url path]];
}

#pragma mark Information

// Override
- (NSURL *)fileURL
{
	return [NSURL fileURLWithPath:[self absolutePath] isDirectory:YES];
}

#pragma mark On-Disk Inspection

// Override
- (BOOL)exists
{
	return [super isDirectory];
}

- (BOOL)isEmpty
{
	if (![self isDirectory]) return NO;
	return [[self items] count] == 0;
}

- (NSArray *)items
{
	return [self itemsOfKind:nil];
}

- (NSArray *)files
{
	return [self itemsOfKind:[MFFile class]];
}

- (NSArray *)filesWithExtension:(NSString *)extension
{
	NSMutableArray *filesWithExtension = [NSMutableArray array];
	
	for (MFFile *file in [self files])
	{
		if ([[file extension] isEqualToString:extension])
			[filesWithExtension addObject:file];
	}
	
	return [filesWithExtension copy];
}

- (NSArray *)subdirectories
{
	return [self itemsOfKind:[MFDirectory class]];
}

- (NSArray *)itemsOfKind:(Class)kind
{
	NSFileManager *manager = [NSFileManager defaultManager];
	
	NSError *error = nil;
	NSArray *itemNames = [manager contentsOfDirectoryAtPath:[self absolutePath] error:&error];
	
	if (error)
	{
		DDLogError(@"Error reading contents of directory at path: %@ %@", [self absolutePath], [error description]);
		return nil;
	}
	
	NSMutableArray *items = [NSMutableArray array];
	for (NSString *itemName in itemNames)
	{
		BOOL itemIsDirectory;
		NSString *itemPath = [[self absolutePath] stringByAppendingPathComponent:itemName];
		[manager fileExistsAtPath:itemPath isDirectory:&itemIsDirectory];
		
		MFPath *item = (itemIsDirectory ? [MFDirectory directoryWithPath:itemPath] : [MFFile fileWithPath:itemPath]);
		
		if (item == nil) continue;
		
		// Add the item to the array or not depending on the kind of item wanted
		if (kind == nil)
		{
			[items addObject:item];
		}
		else if ([item isKindOfClass:kind])
		{
			[items addObject:item];
		}
	}
	
	return [items copy];
}

#pragma mark Creating Other Directories

- (MFDirectory *)subdirectory:(NSString *)name
{
	return [MFDirectory directoryWithPath:[[self subitem:name] absolutePath]];
}

- (MFDirectory *)subdirectoryWithFormat:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);
	NSString *name = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	
	return [self subdirectory:name];
}

- (MFDirectory *)subdirectoryWithNumberSuffixIfExists:(NSString *)name
{
	MFPath *path = [self subitemWithNumberSuffixIfExists:name];
	return [MFDirectory directoryWithPath:[path absolutePath]];
}

#pragma mark Creating Files

- (MFFile *)file:(NSString *)name
{
	return [MFFile fileWithPath:[[self subitem:name] absolutePath]];
}

- (MFFile *)fileWithFormat:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);
	NSString *name = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	
	return [self file:name];
}

- (MFFile *)fileWithName:(NSString *)name extension:(NSString *)extension
{
	NSString *extensionWithDot = extension ? [@"." stringByAppendingString:extension] : @"";
	return [self file:[name stringByAppendingString:extensionWithDot]];
}

- (MFFile *)fileWithNumberSuffixIfExists:(NSString *)name
{
	MFPath *path = [self subitemWithNumberSuffixIfExists:name];
	return [MFFile fileWithPath:[path absolutePath]];
}

#pragma mark Operations

- (BOOL)deleteContents
{
	if (![self isDirectory]) return NO;
	
	__block BOOL success = YES;
	
	NSArray *items = [self items];
	
	for (MFPath *item in items)
		success &= [item deleteAndSilenceLogging:YES];
	
	if (success) DDLogVerbose(@"Deleted contents of directory %@", [self path]);
	
	return success;
}

- (MFDirectory *)create
{
	return [self createAndSilenceLogging:NO];
}

- (MFDirectory *)createAndSilenceLogging:(BOOL)silenceLogging
{
	if ([self isDirectory]) return self;
	
	NSFileManager *manager = [NSFileManager defaultManager];
	
	NSError *error = nil;
	[manager createDirectoryAtPath:[self absolutePath] withIntermediateDirectories:YES attributes:nil error:&error];
	
	if (error)
	{
		DDLogError(@"Could not create directory: %@", error);
		return nil;
	}
	
	if (!silenceLogging) DDLogVerbose(@"Created directory %@", [self path]);
	
	return self;
}

- (MFDirectory *)copyContentsTo:(MFDirectory *)destination
{
	return [self copyContentsTo:destination overwrite:NO];
}

- (MFDirectory *)copyContentsTo:(MFDirectory *)destination overwrite:(BOOL)overwrite
{
	return [self copyContentsTo:destination overwrite:overwrite error:nil];
}

- (MFDirectory *)copyContentsTo:(MFDirectory *)destination overwrite:(BOOL)overwrite error:(NSError **)error
{
	if (destination == nil)
		@throw [NSException exceptionWithReason:@"Destination is nil"];
	
	if ([destination isEqual:self])
		@throw [NSException exceptionWithReason:@"Trying to copy contents to same path"];
	
	if (![self isDirectory])
	{
		NSString *description = [NSString stringWithFormat:@"Cannot copy directory from path %@ because it is not a directory!", [self absolutePath]];
		DDLogError(@"%@", description);
		if (error) *error = [NSError errorWithDescription:description];
		return nil;
	}
		
	if (![destination create])
	{
		NSString *description = [NSString stringWithFormat:@"Could not create destination directory %@.", [destination absolutePath]];
		DDLogError(@"%@", description);
		if (error) *error = [NSError errorWithDescription:description];
		return nil;
	}
	
	NSMutableArray *errors = [NSMutableArray array];
	
	for (MFPath *item in [self items])
	{
		MFPath *subitem = nil;
		if ([item isKindOfClass:[MFDirectory class]])
		{
			subitem = [destination subdirectory:[item name]];
		}
		else if ([item isKindOfClass:[MFFile class]])
		{
			subitem = [destination file:[item name]];
		}
		
		NSError *error;
		[item copyTo:subitem overwrite:overwrite error:&error];
		
		if (error) [errors addObject:error];
	}
	
	if ([errors count] > 0)
	{
		NSError *innerError = errors[0];
		DDLogError(@"%@", [innerError description]);
		if (error) *error = innerError;
		return nil;
	}
	
	DDLogVerbose(@"Copied contents of directory %@ to %@", [self path], [destination path]);
	
	return destination;
}

- (MFDirectory *)copyTo:(MFDirectory *)destination
{
	return [self copyTo:destination overwrite:NO];
}

- (MFDirectory *)copyTo:(MFDirectory *)destination overwrite:(BOOL)overwrite
{
	return [self copyTo:destination overwrite:overwrite error:nil];
}

- (MFDirectory *)copyTo:(MFPath *)destination overwrite:(BOOL)overwrite error:(NSError **)error
{
	return [self copyTo:destination overwrite:overwrite error:error silenceLogging:NO];
}

- (MFDirectory *)copyTo:(MFPath *)destination overwrite:(BOOL)overwrite error:(NSError **)error silenceLogging:(BOOL)silenceLogging
{
	if (destination == nil)
		@throw [NSException exceptionWithReason:@"Destination is nil"];
	
	if ([destination isEqual:self])
		@throw [NSException exceptionWithReason:@"Trying to copy to same path"];
	
	NSError *innerError = nil;
	MFPath *path = [super copyTo:destination overwrite:overwrite error:&innerError];
	
	if (innerError && error)
	{
		*error = innerError;
		return nil;
	}
	
	if (!silenceLogging) DDLogVerbose(@"Copied directory %@ to %@", [self path], [destination path]);
	
	return [MFDirectory directoryWithPath:[path absolutePath]];
}

- (MFDirectory *)moveTo:(MFDirectory *)destination
{
	return [self moveTo:destination overwrite:NO];
}

- (MFDirectory *)moveTo:(MFDirectory *)destination overwrite:(BOOL)overwrite
{
	return [self moveTo:destination overwrite:overwrite error:nil];
}

- (MFDirectory *)moveTo:(MFDirectory *)destination overwrite:(BOOL)overwrite error:(NSError **)error
{
	if (destination == nil)
		@throw [NSException exceptionWithReason:@"Destination is nil"];
	
	if ([destination isEqual:self])
		@throw [NSException exceptionWithReason:@"Trying to move to same path"];
	
	if (![self isDirectory])
	{
		NSString *description = [NSString stringWithFormat:@"Cannot move directory from path %@ because path is not a directory", [self absolutePath]];
		DDLogError(@"%@", description);
		if (error) *error = [NSError errorWithDescription:description];
		return nil;
	}
	
	NSError *innerError = nil;
	MFDirectory *outputDirectory = [self copyTo:destination overwrite:overwrite error:&innerError silenceLogging:YES];
	
	if (innerError && error)
	{
		*error = innerError;
		return nil;
	}
	
	BOOL deleted = [self deleteAndSilenceLogging:YES];
	
	if (!deleted)
	{
		NSString *description = [NSString stringWithFormat:@"Could not delete source directory %@ after move", [self absolutePath]];
		DDLogError(@"%@", description);
		if (error) *error = [NSError errorWithDescription:description];
		return nil;
	}
	
	DDLogVerbose(@"Moved directory %@ to %@", [self path], [destination path]);
	
	return outputDirectory;
}

@end
