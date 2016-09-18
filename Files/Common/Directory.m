//
//  Directory.m
//  Obsidian
//
//  Created by Michaël Fortin on 2013-04-12.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import "Directory.h"
#import "File.h"
#import "NSError+FilesAdditions.h"
#import "NSException+FilesAdditions.h"

@implementation Directory

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

- (NSArray<Path *> *)items
{
	return [self itemsOfKind:nil];
}

- (NSArray<File *> *)files
{
	return [self itemsOfKind:[File class]];
}

- (NSArray<File *> *)filesWithExtension:(NSString *)extension
{
	NSMutableArray *filesWithExtension = [NSMutableArray array];
	
	for (File *file in [self files])
	{
		if ([[file extension] isEqualToString:extension])
			[filesWithExtension addObject:file];
	}
	
	return [filesWithExtension copy];
}

- (NSArray<Directory *> *)subdirectories
{
	return [self itemsOfKind:[Directory class]];
}

- (NSArray *)itemsOfKind:(Class)kind
{
	NSFileManager *manager = [NSFileManager defaultManager];
	
	NSError *error = nil;
	NSArray *itemNames = [manager contentsOfDirectoryAtPath:[self absolutePath] error:&error];
	
	if (error)
	{
		NSLog(@"Error reading contents of directory at path: %@ %@", [self absolutePath], [error description]);
		return nil;
	}
	
	NSMutableArray *items = [NSMutableArray array];
	for (NSString *itemName in itemNames)
	{
		BOOL itemIsDirectory;
		NSString *itemPath = [[self absolutePath] stringByAppendingPathComponent:itemName];
		[manager fileExistsAtPath:itemPath isDirectory:&itemIsDirectory];
		
		Path *item = (itemIsDirectory ? [Directory directoryWithPath:itemPath] : [File fileWithPath:itemPath]);
		
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

- (Directory *)subdirectory:(NSString *)name
{
	return [Directory directoryWithPath:[[self subitem:name] absolutePath]];
}

- (Directory *)subdirectoryWithFormat:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);
	NSString *name = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	
	return [self subdirectory:name];
}

- (Directory *)subdirectoryWithNumericSuffixIfExists:(NSString *)name
{
	Path *path = [self subitemWithNumericSuffixIfExists:name];
	return [Directory directoryWithPath:[path absolutePath]];
}

#pragma mark Creating Files

- (File *)file:(NSString *)name
{
	return [File fileWithPath:[[self subitem:name] absolutePath]];
}

- (File *)fileWithFormat:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);
	NSString *name = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	
	return [self file:name];
}

- (File *)fileWithName:(NSString *)name extension:(NSString *)extension
{
	NSString *extensionWithDot = extension ? [@"." stringByAppendingString:extension] : @"";
	return [self file:[name stringByAppendingString:extensionWithDot]];
}

- (File *)fileWithNumberSuffixIfExists:(NSString *)name
{
	Path *path = [self subitemWithNumericSuffixIfExists:name];
	return [File fileWithPath:[path absolutePath]];
}

#pragma mark Operations

- (BOOL)deleteContents
{
	if (![self isDirectory]) return NO;
	
	__block BOOL success = YES;
	
	NSArray *items = [self items];
	
	for (Path *item in items)
		success &= [item delete];
	
	return success;
}

- (Directory *)create
{
    if ([self isDirectory]) return self;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    [manager createDirectoryAtPath:[self absolutePath] withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (error)
    {
        NSLog(@"Could not create directory: %@", error);
        return nil;
    }
    
    return self;
}

- (Directory *)copyContentsTo:(Directory *)destination
{
	return [self copyContentsTo:destination overwrite:NO];
}

- (Directory *)copyContentsTo:(Directory *)destination overwrite:(BOOL)overwrite
{
	return [self copyContentsTo:destination overwrite:overwrite error:nil];
}

- (Directory *)copyContentsTo:(Directory *)destination overwrite:(BOOL)overwrite error:(NSError **)error
{
	if (destination == nil)
		@throw [NSException exceptionWithReason:@"Destination is nil"];
	
	if ([destination isEqual:self])
		@throw [NSException exceptionWithReason:@"Trying to copy contents to same path"];
	
	if (![self isDirectory])
	{
		NSString *description = [NSString stringWithFormat:@"Cannot copy directory from path %@ because it is not a directory!", [self absolutePath]];
		NSLog(@"%@", description);
		if (error) *error = [NSError errorWithDescription:@"%@", description];
		return nil;
	}
		
	if (![destination create])
	{
		NSString *description = [NSString stringWithFormat:@"Could not create destination directory %@.", [destination absolutePath]];
		NSLog(@"%@", description);
		if (error) *error = [NSError errorWithDescription:@"%@", description];
		return nil;
	}
	
	NSMutableArray *errors = [NSMutableArray array];
	
	for (Path *item in [self items])
	{
		Path *subitem = nil;
		if ([item isKindOfClass:[Directory class]])
		{
			subitem = [destination subdirectory:[item name]];
		}
		else if ([item isKindOfClass:[File class]])
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
		NSLog(@"%@", [innerError description]);
		if (error) *error = innerError;
		return nil;
	}
	
	return destination;
}

- (Directory *)copyTo:(Directory *)destination
{
	return [self copyTo:destination overwrite:NO];
}

- (Directory *)copyTo:(Directory *)destination overwrite:(BOOL)overwrite
{
	return [self copyTo:destination overwrite:overwrite error:nil];
}

- (Directory *)copyTo:(Path *)destination overwrite:(BOOL)overwrite error:(NSError **)error
{
    if (destination == nil)
    @throw [NSException exceptionWithReason:@"Destination is nil"];
    
    if ([destination isEqual:self])
    @throw [NSException exceptionWithReason:@"Trying to copy to same path"];
    
    NSError *innerError = nil;
    Path *path = [super copyTo:destination overwrite:overwrite error:&innerError];
    
    if (innerError && error)
    {
        *error = innerError;
        return nil;
    }
    
    return [Directory directoryWithPath:[path absolutePath]];
}

- (Directory *)moveTo:(Directory *)destination
{
	return [self moveTo:destination overwrite:NO];
}

- (Directory *)moveTo:(Directory *)destination overwrite:(BOOL)overwrite
{
	return [self moveTo:destination overwrite:overwrite error:nil];
}

- (Directory *)moveTo:(Directory *)destination overwrite:(BOOL)overwrite error:(NSError **)error
{
	if (destination == nil)
		@throw [NSException exceptionWithReason:@"Destination is nil"];
	
	if ([destination isEqual:self])
		@throw [NSException exceptionWithReason:@"Trying to move to same path"];
	
	if (![self isDirectory])
	{
		NSString *description = [NSString stringWithFormat:@"Cannot move directory from path %@ because path is not a directory", [self absolutePath]];
		NSLog(@"%@", description);
		if (error) *error = [NSError errorWithDescription:@"%@", description];
		return nil;
	}
	
	NSError *innerError = nil;
	Directory *outputDirectory = [self copyTo:destination overwrite:overwrite error:&innerError];
	
	if (innerError && error)
	{
		*error = innerError;
		return nil;
	}
	
	BOOL deleted = [self delete];
	
	if (!deleted)
	{
		NSString *description = [NSString stringWithFormat:@"Could not delete source directory %@ after move", [self absolutePath]];
		NSLog(@"%@", description);
		if (error) *error = [NSError errorWithDescription:@"%@", description];
		return nil;
	}
	
	return outputDirectory;
}

@end
