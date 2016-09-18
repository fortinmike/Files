//
//  Path+macOS.h
//  Obsidian
//
//  Created by Michaël Fortin on 11/23/2013.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Path.h"
#import "Tag.h"

@interface Path (OSX)

#pragma mark On-Disk Inspection

- (NSImage *)icon;
- (NSString *)type;

// Note: Use system-defined constants when available for the methods below:
// https://developer.apple.com/library/mac/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html

/**
 Returns whether the UTI of this file matches the specified UTI (use UTI constants if possible).
 */
- (BOOL)isOfType:(CFStringRef)uti;

/**
 Checks whether the file conforms to the UTI (for example, a file of type public.mp3 would conform to public.audio).
 */
- (BOOL)conformsToType:(CFStringRef)uti;

#pragma mark Operations

- (BOOL)moveToTrash;
- (void)revealInFinder;

#pragma mark Tags

/**
 An array of Tag instances representing the (Mavericks and up) tags that are currently applied to the specified path.
 */
- (NSArray<Tag *> *)tags;

/**
 Replaces the item's current tags with the specified array of tag names.
 */
- (void)setTags:(NSArray<NSString *> *)tagNames;

/**
 Tags the item with the specified tag name. Won't add the tag if the file already has it.
 */
- (void)addTag:(NSString *)name;

/**
 Removes the tag if present.
 */
- (void)removeTag:(NSString *)tagName;

/**
 Removes all tags.
 */
- (void)removeAllTags;

/**
 Either adds or removes the tag, depending on whether the file already has the specified tag applied.
 */
- (void)toggleTag:(NSString *)tagName;

/**
 Checks whether the file is tagged with the specified tag name.
 */
- (BOOL)hasTag:(NSString *)tagName;

@end
