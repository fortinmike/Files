//
//  NSString+FilesAdditions.h
//  Obsidian
//
//  Created by Michael Fortin on 12-07-23.
//  Copyright (c) 2012 irradiated.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FilesAdditions)

#pragma mark Obtaining Variants

- (NSAttributedString *)attributedCopy;
- (NSString *)stringByRemovingOccurencesOfString:(NSString *)string;
- (NSString *)stringByRemovingOccurencesOfStrings:(NSArray *)strings;
- (NSString *)stringByCapitalizingFirstWord;
- (NSString *)stringByTrimmingWhitespace;
+ (NSString *)stringByJoiningStrings:(NSArray *)strings withSeparator:(NSString *)separator;

#pragma mark Comparison

- (BOOL)isEqualCaseInsensitive:(NSString *)string;

#pragma mark Checks

- (BOOL)containsOnlyWhitespace;

#pragma mark Path Wildcards

- (NSArray *)stringsByExpandingPathWildcards;
- (BOOL)matchesPathWildcard:(NSString *)wildcard;

#pragma mark Other

- (NSRange)range;

@end
