//
//  Directory+iOS.m
//  Obsidian
//
//  Created by Michaël Fortin on 11/23/2013.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import "Directory+iOS.h"

@implementation Directory (iOS)

#pragma mark System Directories

+ (instancetype)appBundle
{
	return [self directoryWithPath:[[NSBundle mainBundle] bundlePath]];
}

+ (instancetype)library
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	return [self directoryWithPath:path];
}

+ (instancetype)applicationSupport
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *path = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	return [self directoryWithPath:path];
}

+ (instancetype)caches
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	return [self directoryWithPath:path];
}

+ (instancetype)documents
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	return [self directoryWithPath:path];
}

+ (instancetype)resources
{
	return [self directoryWithPath:[[NSBundle mainBundle] resourcePath]];
}

+ (instancetype)resourcesInBundle:(NSBundle *)bundle
{
	return [self directoryWithPath:[bundle resourcePath]];
}

+ (instancetype)temp
{
	return [self directoryWithPath:NSTemporaryDirectory()];
}

@end
