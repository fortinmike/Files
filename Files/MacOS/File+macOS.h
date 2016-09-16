//
//  File+macOS.h
//  Obsidian
//
//  Created by Michaël Fortin on 11/23/2013.
//  Copyright (c) 2013 irradiated.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "File.h"

@interface File (OSX)

#pragma mark Creation

+ (instancetype)fileForResource:(NSString *)resourceName ofType:(CFStringRef)type;
+ (instancetype)fileForResource:(NSString *)resourceName ofType:(CFStringRef)type inBundle:(NSBundle *)bundle;
+ (instancetype)fileForResource:(NSString *)resourceName ofType:(CFStringRef)type inBundleForClass:(Class)class;

#pragma mark Reading Specific Types

- (NSImage *)readImage;

@end
