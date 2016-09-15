//
//  MFTag.h
//  Obsidian
//
//  Created by Michaël Fortin on 2014-02-13.
//  Copyright (c) 2014 irradiated.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFTag : NSObject

@property (readonly) NSString *name;
@property (readonly) NSColor *color;
@property (readonly) NSColor *darkerColor;
@property (readonly) NSUInteger colorNumber;

#pragma mark Lifetime

- (id)initWithName:(NSString *)name colorNumber:(NSUInteger)colorNumber;

@end
