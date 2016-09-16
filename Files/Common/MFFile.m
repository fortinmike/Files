//
//  MFFile.m
//  Obsidian
//
//  Created by Michaël Fortin on 2013-04-12.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import "MFFile.h"
#import "MFDirectory.h"
#import "NSError+FilesAdditions.h"
#import "NSException+FilesAdditions.h"

@implementation MFFile

#pragma mark Creation

+ (instancetype)fileWithPath:(NSString *)path
{
	return [[MFFile alloc] initWithPath:path];
}

+ (instancetype)fileWithFileURL:(NSURL *)url
{
	return [MFFile fileWithPath:[url path]];
}

+ (instancetype)fileForResource:(NSString *)resourceName withExtension:(NSString *)extension
{
	NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:extension];
	if (!path) return nil;
	
	return [MFFile fileWithPath:path];
}

#pragma mark Creating Other Instances

- (MFFile *)sibling:(NSString *)name
{
	return [[self parent] file:name];
}

- (MFFile *)siblingWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2)
{
	va_list args;
	va_start(args, format);
	NSString *name = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	
	return [self sibling:name];
}

#pragma mark Lifetime

- (id)initWithPath:(NSString *)path
{
	if ([path hasSuffix:@"/"]) return nil;
	return [super initWithPath:path];
}

#pragma mark Information

// Override
- (NSURL *)fileURL
{
	return [NSURL fileURLWithPath:[self absolutePath] isDirectory:NO];
}

#pragma mark On-Disk Inspection

// Override
- (BOOL)exists
{
	return [super isFile];
}

#pragma mark Operations

- (MFFile *)create
{
	if ([[self parent] create] == nil) return nil;
	
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL fileCreated = [manager createFileAtPath:[self absolutePath] contents:nil attributes:nil];
	
	return (fileCreated ? self : nil);
}

- (MFFile *)copyTo:(MFPath *)destination
{
	return [self copyTo:destination overwrite:NO];
}

- (MFFile *)copyTo:(MFPath *)destination overwrite:(BOOL)overwrite
{
	return [self copyTo:destination overwrite:overwrite error:nil];
}

- (MFFile *)copyTo:(MFPath *)destination overwrite:(BOOL)overwrite error:(NSError **)error
{
	return [self copyTo:destination overwrite:overwrite error:error silenceLogging:NO];
}

- (MFFile *)copyTo:(MFPath *)destination overwrite:(BOOL)overwrite error:(NSError **)error silenceLogging:(BOOL)silenceLogging
{
	if (destination == nil)
		@throw [NSException exceptionWithReason:@"Destination is nil"];
	
	// Comparing absolute paths instead of objects because destination can be either an MFFile or an MFDirectory
	if ([[destination absolutePath] isEqual:[self absolutePath]])
		@throw [NSException exceptionWithReason:@"Trying to copy to same path"];
	
	if ([destination isKindOfClass:[MFDirectory class]])
	{
		MFDirectory *directory = (MFDirectory *)destination;
		
		// If overwriting and we need to create a directory, delete whatever's at the path directory points to
		if (overwrite) [directory deleteAndSilenceLogging:YES];
		
		destination = [directory file:[self name]];
	}
	
	NSError *innerError = nil;
	MFPath *path = [super copyTo:destination overwrite:overwrite error:&innerError];
	
	if (path == nil || innerError)
	{
		NSLog(@"%@", [innerError description]);
		if (error) *error = innerError;
		return nil;
	}
	
	return [MFFile fileWithPath:[path absolutePath]];
}

- (MFFile *)moveTo:(MFPath *)destination
{
	return [self moveTo:destination overwrite:NO];
}

- (MFFile *)moveTo:(MFPath *)destination overwrite:(BOOL)overwrite
{
	return [self moveTo:destination overwrite:overwrite error:nil];
}

- (MFFile *)moveTo:(MFPath *)destination overwrite:(BOOL)overwrite error:(NSError **)error
{
	if (destination == nil)
		@throw [NSException exceptionWithReason:@"Destination is nil"];
	
	// Comparing absolute paths instead of objects because destination can be either an MFFile or an MFDirectory
	if ([[destination absolutePath] isEqual:[self absolutePath]])
		@throw [NSException exceptionWithReason:@"Trying to move to same path"];
	
	if (![self isFile])
	{
		NSString *description = [NSString stringWithFormat:@"Cannot move file from path %@ because path is not a file", [self absolutePath]];
		NSLog(@"%@", description);
		if (error) *error = [NSError errorWithDescription:@"%@", description];
		return nil;
	}
	
	NSError *innerError = nil;
	MFFile *outputFile = [self copyTo:destination overwrite:overwrite error:&innerError silenceLogging:YES];
	
	if (innerError)
	{
		NSLog(@"%@", [innerError description]);
		if (error) *error = innerError;
		return nil;
	}
	
	BOOL deleted = [self deleteAndSilenceLogging:YES];
	
	if (!deleted)
	{
		NSString *description = [NSString stringWithFormat:@"Could not delete source file %@ after move", [self absolutePath]];
		NSLog(@"%@", description);
		if (error) *error = [NSError errorWithDescription:@"%@", description];
		return nil;
	}
	
	return outputFile;
}

#pragma mark Data Writing / Reading

- (NSData *)readData
{
	return [self readData:nil];
}

- (NSData *)readData:(NSError **)error
{
	NSData *data = [NSData dataWithContentsOfFile:[self absolutePath]];
	
	if (!data)
	{
		NSString *description = [NSString stringWithFormat:@"Could not read data from %@", [self absolutePath]];
		NSLog(@"%@", description);
		if (error) *error = [NSError errorWithDescription:@"%@", description];
		return nil;
	}
	
	return data;
}

- (BOOL)writeData:(NSData *)data
{
	return [self writeData:data overwrite:NO];
}

- (BOOL)writeData:(NSData *)data overwrite:(BOOL)overwrite
{
	return [self writeData:data overwrite:overwrite error:nil];
}

- (BOOL)writeData:(NSData *)data overwrite:(BOOL)overwrite error:(NSError **)error
{
	return [self writeData:data overwrite:overwrite error:error silenceLogging:NO];
}

- (BOOL)writeData:(NSData *)data overwrite:(BOOL)overwrite error:(NSError **)error silenceLogging:(BOOL)silenceLogging
{
	if (data == nil) @throw [NSException exceptionWithReason:@"No data to write!"];
	
	if (!overwrite && [self itemExists])
	{
		NSString *description = [NSString stringWithFormat:@"Can't write data: A file already exists at path %@", [self absolutePath]];
		NSLog(@"%@", description);
		if (error) *error = [NSError errorWithDescription:@"%@", description];
		return NO;
	}
	
	if (overwrite)
	{
		if (![self deleteAndSilenceLogging:YES])
		{
			NSString *description = [NSString stringWithFormat:@"Could not delete existing file at path %@", [self absolutePath]];
			NSLog(@"%@", description);
			if (error) *error = [NSError errorWithDescription:@"%@", description];
			return NO;
		}
	}
	
	MFDirectory *parent = [self parent];
	if (![parent create])
	{
		NSString *description = [NSString stringWithFormat:@"Could not create intermediary directories for path %@", [parent absolutePath]];
		NSLog(@"%@", description);
		if (error) *error = [NSError errorWithDescription:@"%@", description];
		return NO;
	}
	
	return [data writeToFile:[self absolutePath] atomically:YES];
}

- (NSOutputStream *)outputStreamToAppend:(BOOL)append
{
	return [NSOutputStream outputStreamToFileAtPath:[self absolutePath] append:append];
}

#pragma mark Keyed Archiving / Unarchiving

- (BOOL)archive:(id<NSCoding>)object
{
	return [self archive:object overwrite:NO];
}

- (BOOL)archive:(id<NSCoding>)object overwrite:(BOOL)overwrite
{
	return [self archive:object overwrite:overwrite error:nil];
}

- (BOOL)archive:(id<NSCoding>)object overwrite:(BOOL)overwrite error:(NSError **)error
{
	return [self archiveInternal:object overwrite:overwrite format:NSPropertyListBinaryFormat_v1_0 error:error];
}

- (id)unarchive
{
	return [self unarchive:nil];
}

- (id)unarchive:(NSError **)error
{
	return [self unarchiveInternalWithError:error];
}

#pragma mark Keyed Archiving / Unarchiving (Plist)

- (BOOL)archiveAsXMLPlist:(id<NSCoding>)object
{
	return [self archiveAsXMLPlist:object overwrite:NO];
}

- (BOOL)archiveAsXMLPlist:(id<NSCoding>)object overwrite:(BOOL)overwrite
{
	return [self archiveAsXMLPlist:object overwrite:overwrite error:nil];
}

- (BOOL)archiveAsXMLPlist:(id<NSCoding>)object overwrite:(BOOL)overwrite error:(NSError **)error
{
	return [self archiveInternal:object overwrite:overwrite format:NSPropertyListXMLFormat_v1_0 error:error];
}

- (id)unarchiveFromXMLPlist
{
	return [self unarchiveFromXMLPlist:nil];
}

- (id)unarchiveFromXMLPlist:(NSError **)error
{
	return [self unarchiveInternalWithError:error];
}

#pragma mark Keyed Archiving / Unarchiving (Internal)

- (BOOL)archiveInternal:(id<NSCoding>)object overwrite:(BOOL)overwrite format:(NSPropertyListFormat)format error:(NSError **)error
{
	NSError *innerError = nil;
	
	NSMutableData *data = [NSMutableData data];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver setOutputFormat:format];
	[archiver encodeObject:object forKey:@"root"];
	[archiver finishEncoding];
	
	BOOL success = [self writeData:data overwrite:overwrite error:&innerError silenceLogging:YES];
	
	if (innerError)
	{
		if (error) *error = innerError;
		return NO;
	}
	
	return success;
}

- (id<NSCoding>)unarchiveInternalWithError:(NSError **)error
{
	NSError *innerError = nil;
	id<NSCoding> object = nil;
	
	@try
	{
		NSData *data = [self readData:&innerError];
		
		if (!data)
		{
			if (error) *error = innerError;
			return nil;
		}
		
		object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		
		if (!object)
		{
			NSString *description = [NSString stringWithFormat:@"No object returned after unarchiving data from %@", [self absolutePath]];
			NSLog(@"%@", description);
			if (error) *error = [NSError errorWithDescription:@"%@", description];
		}
	}
	@catch (NSException *exception)
	{
		NSString *description = [NSString stringWithFormat:@"Exception unarchiving data from file %@ %@", [self absolutePath], exception];
		NSLog(@"%@", description);
		if (error) *error = [NSError errorWithDescription:@"%@", description];
	}
	@finally
	{
		return object;
	}
}

#pragma mark Specific Type Reading

- (NSString *)readString
{
	return [self readStringWithEncoding:NSUTF8StringEncoding];
}

- (NSString *)readStringWithEncoding:(NSStringEncoding)encoding
{
	NSError *error;
	NSString *string = [NSString stringWithContentsOfFile:[self absolutePath] encoding:encoding error:&error];
	if (error) NSLog(@"Could not read contents of file %@ with encoding %lu", [self path], (unsigned long)encoding);
	return string;
}

#pragma mark Reading/Writing Arrays

- (NSArray *)readArray
{
	NSArray *array = [NSArray arrayWithContentsOfFile:[self absolutePath]];
	if (!array) NSLog(@"Could not load array from file %@", [self path]);
	return array;
}

- (BOOL)writeArray:(NSArray *)array
{
	return [array writeToFile:[self absolutePath] atomically:YES];
}

- (BOOL)writeArray:(NSArray *)array overwrite:(BOOL)overwrite
{
	if (!overwrite && [self exists]) return NO;
	return [array writeToFile:[self absolutePath] atomically:YES];
}

#pragma mark Reading/Writing Dictionaries

- (NSDictionary *)readDictionary
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[self absolutePath]];
	if (!dictionary) NSLog(@"Could not load dictionary from file %@", [self path]);
	return dictionary;
}

- (BOOL)writeDictionary:(NSDictionary *)dictionary
{
	return [dictionary writeToFile:[self absolutePath] atomically:YES];
}

- (BOOL)writeDictionary:(NSDictionary *)dictionary overwrite:(BOOL)overwrite
{
	if (!overwrite && [self exists]) return NO;
	return [dictionary writeToFile:[self absolutePath] atomically:YES];
}

@end
