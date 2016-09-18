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

- (BOOL)isOfType:(CFStringRef)uti; // Returns whether the UTI of this file matches the specified UTI (use UTI constants if possible)
- (BOOL)conformsToType:(CFStringRef)uti; // Checks whether the file conforms to the UTI (for example, a file of type public.mp3 would conform to public.audio)

#pragma mark Operations

- (BOOL)moveToTrash;
- (void)revealInFinder;

#pragma mark Tags

- (NSArray<Tag *> *)tags; // An array of Tag instances representing the (Mavericks and up) tags that are currently applied to the specified path
- (void)setTags:(NSArray<NSString *> *)tagNames; // Replaces the file's current tags with the specified array of tag names
- (void)addTag:(NSString *)name; // Tags the file with the specified tag name. Won't add the tag if the file already has it.
- (void)removeTag:(NSString *)tagName; // Removes the tag if present
- (void)removeAllTags;
- (void)toggleTag:(NSString *)tagName; // Either adds or removes the tag, depending on whether the file already has the specified tag applied
- (BOOL)hasTag:(NSString *)tagName; // Checks whether the file is tagged with the specified tag name

@end
