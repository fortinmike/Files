//
//  NSObject+Directory_OSX.m
//  Obsidian
//
//  Created by Michaël Fortin on 10/29/2013.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import "Directory+macOS.h"

@implementation Directory (OSX)

#pragma mark System Directories

// COV_NF_START

+ (instancetype)root
{
	return [self directoryWithPath:@"/"];
}

+ (instancetype)volumes
{
	return [self directoryWithPath:@"/Volumes"];
}

+ (instancetype)home
{
	return [self directoryWithPath:@"~"];
}

+ (instancetype)desktop
{
	return [self directoryWithPath:@"~/Desktop"];
}

+ (instancetype)downloads
{
	return [self directoryWithPath:@"~/Downloads"];
}

+ (instancetype)trash
{
	return [self directoryWithPath:@"~/.Trash"];
}

+ (instancetype)userLevelPreferences
{
	return [self directoryWithPath:@"~/Library/Preferences"];
}

+ (instancetype)systemLevelPreferences
{
	return [self directoryWithPath:@"/Library/Preferences"];
}

+ (instancetype)appSpecificApplicationSupport
{
	NSString *appBundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	return [self directoryWithPath:[NSString stringWithFormat:@"~/Library/Application Support/%@", appBundleIdentifier]];
}

+ (instancetype)userLevelApplicationSupport
{
	return [self directoryWithPath:@"~/Library/Application Support"];
}

+ (instancetype)systemLevelApplicationSupport
{
	return [self directoryWithPath:@"/Library/Application Support"];
}

+ (instancetype)appBundle
{
	return [self directoryWithPath:[[NSBundle mainBundle] bundlePath]];
}

+ (instancetype)resources
{
	return [self directoryWithPath:[[NSBundle mainBundle] resourcePath]];
}

+ (instancetype)resourcesInBundle:(NSBundle *)bundle
{
	return [self directoryWithPath:[bundle resourcePath]];
}

+ (instancetype)resourcesInBundleForClass:(Class)class
{
	return [self resourcesInBundle:[NSBundle bundleForClass:class]];
}

+ (instancetype)applicationScripts
{
	NSURL *scriptsURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationScriptsDirectory
															   inDomain:NSUserDomainMask
													  appropriateForURL:nil create:NO error:nil];
	
	return [self directoryWithFileURL:scriptsURL];
}

+ (instancetype)temp
{
	NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	return [self directoryWithPath:[NSString stringWithFormat:@"~/Library/Caches/%@", bundleIdentifier]];
}

#pragma mark On-Disk Inspection

- (BOOL)isBundle
{
	NSString *expectedUTI = @"com.apple.bundle";
	BOOL conforms = UTTypeConformsTo((__bridge CFStringRef)([self type]), (__bridge CFStringRef)(expectedUTI));
	return conforms;
}

- (BOOL)isApplicationBundle
{
	return [[self type] isEqualToString:@"com.apple.application-bundle"];
}

- (NSArray *)filesConformingToType:(CFStringRef)type
{
	return [[self files] ct_where:^BOOL(File *file) { return [file conformsToType:type]; }];
}

@end
