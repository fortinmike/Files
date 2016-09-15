//
//  NSString+FilesAdditions.m
//  Obsidian
//
//  Created by Michael Fortin on 12-07-23.
//  Copyright (c) 2012 irradiated.net. All rights reserved.
//

#import <Collector/Collector.h>
#import "NSString+Additions.h"

@implementation NSString (FilesAdditions)

#pragma mark Obtaining Variants

- (NSAttributedString *)attributedCopy;
{
	return [[NSAttributedString alloc] initWithString:self];
}

- (NSString *)stringByRemovingOccurencesOfString:(NSArray *)string
{
	return [self stringByRemovingOccurencesOfStrings:@[string]];
}

- (NSString *)stringByRemovingOccurencesOfStrings:(NSArray *)strings
{
	NSMutableString *modifiedString = [self mutableCopy];
	
	if (![strings ct_areObjectsKindOfClass:[NSString class]])
	{
		DDLogError(@"Array does not contain only strings");
		return nil;
	}
	
	for (NSString *string in strings)
		[modifiedString replaceOccurrencesOfString:string withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [modifiedString length])];
	
	return [modifiedString copy];
}

- (NSString *)stringByCapitalizingFirstWord
{
	return [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[self substringToIndex:1] uppercaseString]];
}

- (NSString *)stringByTrimmingWhitespace
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)stringByJoiningStrings:(NSArray *)strings withSeparator:(NSString *)separator
{
	if ([strings count] == 0) return @"";
	
	NSMutableString *accumulated = [NSMutableString string];
	for (int i = 0; i < [strings count]; i++)
	{
		[accumulated appendString:strings[i]];
		
		if (i < [strings count] - 1)
			[accumulated appendString:separator];
	}
	
	return [accumulated copy];
}

#pragma mark Comparison

- (BOOL)isEqualCaseInsensitive:(NSString *)string
{
	return ([self caseInsensitiveCompare:string] == NSOrderedSame);
}

#pragma mark Checks

- (BOOL)containsOnlyWhitespace
{
	return [[self stringByTrimmingWhitespace] isEqualToString:@""];
}

#pragma mark Path Wildcards

- (NSArray *)stringsByExpandingPathWildcards
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString *standardizedPath = [self stringByStandardizingPath];
	
	NSMutableArray *resultingPaths = [NSMutableArray new];
	
	NSArray *components = [standardizedPath pathComponents];
	for (int i = 0; i < [components count]; i++)
	{
		NSString *component = components[i];
		
		if ([component rangeOfString:@"*"].location != NSNotFound)
		{
			NSString *wildcard = component;
			NSArray *componentsUpToWildcard = [components objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, i)]];
			NSString *pathUpToWildcard = [NSString pathWithComponents:componentsUpToWildcard];
			
			NSError *error = nil;
			NSArray *foundPaths = [fileManager contentsOfDirectoryAtPath:pathUpToWildcard error:&error];
			
			if (!error)
			{
				for (NSString *foundPath in foundPaths)
				{
					if ([foundPath matchesPathWildcard:wildcard])
					{
						NSString *matchingPath = [pathUpToWildcard stringByAppendingPathComponent:foundPath];
						if (i == [components count] - 1)
						{
							[resultingPaths addObject:matchingPath];
						}
						else
						{
							NSArray *remainingComponents = [components ct_objectsInRange:NSMakeRange(i + 1, [components count] - (i + 1))];
							NSString *pathRemainder = [remainingComponents componentsJoinedByString:@"/"];
							NSString *pathToExpand = [matchingPath stringByAppendingPathComponent:pathRemainder];
							[resultingPaths addObjectsFromArray:[pathToExpand stringsByExpandingPathWildcards]];
						}
					}
				}
				break;
			}
			else
			{
				
				DDLogError(@"Could not read path: %@ %@", pathUpToWildcard, error);
				return resultingPaths;
				
			}
		}
	}
	
	if ([resultingPaths count] == 0)
	{
		NSString *path = [self stringByStandardizingPath];
		if ([fileManager fileExistsAtPath:path])
			[resultingPaths addObject:path];
	}
	
	return [resultingPaths copy];
}

- (BOOL)matchesPathWildcard:(NSString *)wildcard
{
	if (wildcard == nil) return NO;
	if ([wildcard isEqualToString:@""]) return NO;
	
	NSArray *components = [wildcard componentsSeparatedByString:@"*"];
	if ([components count] == 0) return NO;
	
	if (![wildcard hasPrefix:@"*"])
	{
		// Look for the first component at the beginning of the string
		if (![self hasPrefix:components[0]]) return NO;
	}
	
	// Look for each component in their order of appearance
	NSRange componentRange = NSMakeRange(0, 0);
	for (NSString *component in components)
	{
		
		if (![component isEqualToString:@""])
		{
			NSUInteger remainingLocation = componentRange.location + componentRange.length;
			NSUInteger remainingLength = [self length] - remainingLocation;
			NSRange remainingRange = NSMakeRange(remainingLocation, remainingLength);
			
			componentRange = [self rangeOfString:component options:NSCaseInsensitiveSearch range:remainingRange];
			if (componentRange.location == NSNotFound) return NO;
		}
		
	}
	
	return YES;
}

#pragma mark Other

- (NSRange)range
{
	return NSMakeRange(0, [self length]);
}

@end
