//
//  File+macOS.m
//  Obsidian
//
//  Created by Michaël Fortin on 11/23/2013.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import "File+macOS.h"
#import "Path+macOS.h"
#import "Directory+macOS.h"

@implementation File (OSX)

#pragma mark Creation

+ (instancetype)fileForResource:(NSString *)resourceName ofType:(CFStringRef)type
{
	return [self fileForResource:resourceName ofType:type inBundle:[NSBundle mainBundle]];
}

+ (instancetype)fileForResource:(NSString *)resourceName ofType:(CFStringRef)type inBundle:(NSBundle *)bundle
{
	NSArray *resources = [[[Directory resourcesInBundle:bundle] files] ct_where:^BOOL(File *file)
	{
		return [[file nameWithoutExtension] isEqualToString:resourceName];
	}];
	
	return [resources ct_first:^BOOL(id object) { return [object conformsToType:type]; }];
}

+ (instancetype)fileForResource:(NSString *)resourceName ofType:(CFStringRef)type inBundleForClass:(Class)class
{
	return [self fileForResource:resourceName ofType:type inBundle:[NSBundle bundleForClass:class]];
}

#pragma mark Reading Specific Types

- (NSImage *)readImage
{
	return [[NSImage alloc] initWithContentsOfFile:[self absolutePath]];
}

@end
