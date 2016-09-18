//
//  Path+macOS.m
//  Obsidian
//
//  Created by Michaël Fortin on 11/23/2013.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import <sys/xattr.h>
#import "Path+macOS.h"
#import "Directory.h"
#import "NSArray+FilesAdditions.h"

@implementation Path (OSX)

#pragma mark On-Disk Inspection

- (NSImage *)icon
{
	return [[NSWorkspace sharedWorkspace] iconForFile:[self absolutePath]];
}

- (NSString *)type
{
	return [[NSWorkspace sharedWorkspace] typeOfFile:[self absolutePath] error:nil];
}

- (BOOL)isOfType:(CFStringRef)uti
{
	return UTTypeEqual((__bridge CFStringRef)([self type]), uti);
}

- (BOOL)conformsToType:(CFStringRef)uti
{
	return UTTypeConformsTo((__bridge CFStringRef)([self type]), uti);
}

#pragma mark Operations

- (BOOL)moveToTrash
{
	return [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
														source:[[self parent] absolutePath]
												   destination:@""
														 files:[NSArray arrayWithObject:[self name]]
														   tag:nil];
}

- (void)revealInFinder
{
	[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[self fileURL]]];
}

#pragma mark Tags

// Reference:
// http://arstechnica.com/apple/2013/10/os-x-10-9/9/
// http://superuser.com/questions/645827/how-does-maverickss-finder-store-tags
// http://stackoverflow.com/questions/1072308/parse-plist-nsstring-into-nsdictionary
// http://www.cocoanetics.com/2012/03/reading-and-writing-extended-file-attributes/

- (NSArray *)tags
{
	if (![self runningMavericksOrLater]) return @[];
	
	// Obtain the extended attribute's value using xattr.h functions
	const char *attrName = [@"com.apple.metadata:_kMDItemUserTags" UTF8String];
	const char *filePath = [[self absolutePath] fileSystemRepresentation];
	long bufferLength = getxattr(filePath, attrName, NULL, 0, 0, 0);
	char *buffer = malloc(bufferLength);
	getxattr(filePath, attrName, buffer, 255, 0, 0);
	
	if (buffer == NULL) return @[];
	
	// Create an NSData instance for easy manipulation
	NSData *data = [[NSData alloc] initWithBytes:buffer length:bufferLength];
	free(buffer);
	
	// De-serialize the data as a binary plist
	NSString *error;
	NSPropertyListFormat format;
	NSArray *plist = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable
																format:&format errorDescription:&error];
	
	// Extract tags and colors
	NSArray *tags = [plist ct_map:^id(NSString *value)
	{
		NSArray *components = [value componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		
		NSString *name = components[0];
		NSUInteger colorNumber = [components[1] integerValue];
		
		return [[Tag alloc] initWithName:name colorNumber:colorNumber];
	}];
	
	return tags ? tags : @[];
}

- (void)setTags:(NSArray *)tagNames
{
	[[self fileURL] setResourceValue:tagNames forKey:NSURLTagNamesKey error:nil];
}

- (void)addTag:(NSString *)tagName
{
	[self setTags:[[[[self tags] ct_map:^id(Tag *tag) { return tag.name; }] arrayByAddingObject:tagName] ct_distinct]];
}

- (void)removeTag:(NSString *)tagName
{
	[self setTags:[[[self tags] ct_map:^id(Tag *tag) { return tag.name; }] ct_arrayByRemovingObject:tagName]];
}

- (void)removeAllTags
{
	[self setTags:@[]];
}

- (void)toggleTag:(NSString *)tagName
{
	[self hasTag:tagName] ? [self removeTag:tagName] : [self addTag:tagName];
}

- (BOOL)hasTag:(NSString *)tagName
{
	return [[self tags] ct_any:^BOOL(Tag *tag) { return [tag.name isEqualToString:tagName]; }];
}
    
#pragma mark Helpers
    
- (BOOL)runningMavericksOrLater
{
    return (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_8);
}

@end
