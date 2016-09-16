//
//  File+iOS.m
//  Obsidian
//
//  Created by Michaël Fortin on 11/23/2013.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import "File+iOS.h"

@implementation File (iOS)

#pragma mark Reading Specific Types

- (UIImage *)readImage
{
	UIImage *image = [UIImage imageWithContentsOfFile:[self absolutePath]];
	if (!image) NSLog(@"Could not load image from file %@", [self path]);
	return image;
}

@end
